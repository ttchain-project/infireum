//
//  ChatViewModel.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/25.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources



struct PrivateChatSetup {
    var isPrivateChatOn : BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var privateChatDuration : PrivateChatSettingViewModel.PrivateChatDuration? = nil
    var startTime:Date? = nil
    var endTime:Date? = nil
}

struct TimeFromNow {
    var currentTime : Date {
       return Date.init(timeIntervalSinceNow: 0)
    }
    var tenMinutesFromNow :Date { return Date.init(timeIntervalSinceNow: 600) }
    var thirtyMinutesFromNow : Date {
        return Date.init(timeIntervalSinceNow: 1800)
        
    }
}

class ChatViewModel: KLRxViewModel {
    
    struct Input {
        var roomType:RoomType
        var chatTitle:String
        var roomID:String
        var chatAvatar:UIImage?
        var messageText:UITextField
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Void
    
    private lazy var _messages: BehaviorRelay<[MessageModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    public var messages: Observable<[MessageModel]> {
       return _messages.asObservable().share()
    }
    
    public var shouldScrollToBottom: PublishSubject<Void> = PublishSubject.init()
    public var shouldRefreshCellsForDataUpdate: PublishSubject<Void> = PublishSubject.init()
    var bag: DisposeBag = DisposeBag()
    
    lazy var timer : Observable<NSInteger> = { return Observable<NSInteger>.interval(5, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()
    
    var timeFromNow : TimeFromNow = TimeFromNow.init()
    
    var timerSub: Disposable?
    var groupInfoModel: BehaviorRelay<UserGroupInfoModel?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    public var memberAvatarMapping: [String:UIImage] = [:]
    
    var privateChat : PrivateChatSetup {
        didSet {
            if let duration = privateChat.privateChatDuration {
                switch duration {
                case .pvt_10_minutes:
                    privateChat.startTime = timeFromNow.currentTime
                    privateChat.endTime = timeFromNow.tenMinutesFromNow
                case .pvt_30_minutes:
                    privateChat.startTime = timeFromNow.currentTime
                    privateChat.endTime = timeFromNow.thirtyMinutesFromNow
                case .singleConversation:
                    privateChat.startTime = timeFromNow.currentTime
                }
            }
        }
    }
    
    required init(input: Input, output: Void) {
        self.input = input
        self.privateChat = PrivateChatSetup.init()
        
        if self.input.roomType != RoomType.pvtChat {
            self.getGroupDetails()
        }
        self.timerSub = timer.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            self.fetchAllMessages()
        })
        
        self.groupInfoModel.asObservable().subscribe(onNext: { (model) in
            guard model?.membersArray != nil else {
                return
            }
            for member in (model?.membersArray!)! {
                self.memberAvatarMapping[member.uid] = member.avatar
            }
            self.shouldRefreshCellsForDataUpdate.onNext(())
        }).disposed(by: bag)
        self.concatInput()
        self.concatOutput()
        fetchAllMessages()
    }
    
    func concatInput() {
    }
    func concatOutput() {}
    
    func getFriendsModel(for memberId:String) -> FriendModel? {
        switch self.input.roomType {
        case .group, .channel:
            let groupMemberModel = self.groupInfoModel.value?.membersArray?.filter { $0.uid == memberId }.first
            if (groupMemberModel?.isBlocked)! {
                return nil
            }
            return groupMemberModel
        case .pvtChat:
            let model = FriendInfoModel.init(uid: memberId, nickName: self.input.chatTitle, roomId: self.input.roomID, headhShotImgString: "")
            model.avatar = self.input.chatAvatar
            return model
        }
    }
    
    func fetchAllMessages() {
        Server.instance.getChatHistory(forRoom: self.input.roomID, roomType: self.input.roomType).asObservable().subscribe(onNext: { [unowned self] (response) in
            switch response {
            case .failed(error: let error):
                print(error)
                self.timerSub?.dispose()
            case .success(let chatHistory):
                let prevCount = self._messages.value.count
                self._messages.accept(chatHistory.messageArray.reversed())
                if (prevCount != chatHistory.messageArray.count) {
                    self.shouldScrollToBottom.onNext(())
                }
            }
        }).disposed(by: bag)
    }
    
    func getGroupDetails() {
        Server.instance.getGroupInfo(forRoomID: self.input.roomID).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .failed(error: let error):
                print(error)
            case .success(let model):
                self.groupInfoModel.accept(model.groupInfo)
            }
        }).disposed(by: bag)
    }
    
    func sendMessage() {
        var string = self.input.messageText.text
        string = string?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed = string else {
            return
        }
        Server.instance.sendChatMessage(message: trimmed, forRoom:self.input.roomID).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let error):
                print(error)
            case .success(let message):
                print(message)
                if self.privateChat.isPrivateChatOn.value {
                    if self.privateChat.privateChatDuration != .singleConversation {
                        self.sendDestroyMessage(messageID: message.msgId)
                    }
                }
            }
        }).disposed(by: bag)
    }
    
    func sendDestroyMessage(messageID:String) {
        guard self.privateChat.privateChatDuration != nil, let endTime = self.privateChat.endTime else {
            return
        }
        let endTimeString = DateFormatter.dateString(from: endTime, withFormat:C.IMDateFormat.dateFormatForIM)
        
        Server.instance.destructMessage(messageID: messageID, expireTime: endTimeString).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .failed(error: let error):
                print(error)
            case .success( _):
                print("message destructionSend")
            }
        } ).disposed(by: bag)
    }
    
    func postChatSection() {
        guard self.privateChat.privateChatDuration == .singleConversation else{
            return
        }
        
          guard  let startTimeDate = self.privateChat.startTime
            else {
                return
        }
        let startTimeString = DateFormatter.dateString(from: startTimeDate, withFormat:C.IMDateFormat.dateFormatForIM)
        let endTimeString = DateFormatter.dateString(from: timeFromNow.currentTime, withFormat:C.IMDateFormat.dateFormatForIM)
        
        Server.instance.postMessageSection(roomID: self.input.roomID, startTime:startTimeString, endTime:endTimeString).asObservable()
            .subscribe(onNext: { response in
            switch response {
            case .failed(error: let error):
                print(error)
            case .success( _):
                print("message")
            }
        }).disposed(by: bag)
    }
}
