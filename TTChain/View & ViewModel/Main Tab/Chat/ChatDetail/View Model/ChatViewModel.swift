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
    var oneMinutesFromNow : Date {
        return Date.init(timeIntervalSinceNow: 60)
        
    }
}

class ChatViewModel: KLRxViewModel {
    
    struct Input {
        var roomType:RoomType
        var chatTitle:String
        var roomID:String
        var chatAvatar:UIImage?
        var messageText:UITextField
        var uid: String?
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
                case .pvt_1_minutes:
                    privateChat.startTime = timeFromNow.currentTime
                    privateChat.endTime = timeFromNow.oneMinutesFromNow
                case .singleConversation:
                    privateChat.startTime = timeFromNow.currentTime
                }
            }
        }
    }
    
    let blockSubject = PublishSubject<Void>()
    
    required init(input: Input, output: Void) {
        self.input = input
        self.privateChat = PrivateChatSetup.init()
        
        if self.input.roomType != RoomType.pvtChat {
            self.getGroupDetails()
        }
        self.timerSub = timer.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            self.fetchAllMessagesForPrivateChat()
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
        fetchAllMessagesForPrivateChat()
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
    
    func fetchAllMessagesForPrivateChat() {
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
        
        guard let user = IMUserManager.manager.userModel.value else {
            return
        }
        var message = trimmed

        let parameter = IMSendMessageAPI.Parameter.init(uid: user.uID, roomId: self.input.roomID, isGroup: self.input.roomType == .pvtChat ? false : true, msg: message)
        
        repeat {
            Server.instance.sendMessage(parameters: parameter).asObservable().subscribe(onNext: { (result) in
                switch result {
                case .failed(error: let error):
                    DLogError(error)
                case .success(let message):
                    DLogInfo(message)
                    if message.status {
                        if self.privateChat.isPrivateChatOn.value {
//                            if self.privateChat.privateChatDuration != .singleConversation, let id = message.msgId {
//                                self.sendDestroyMessage(messageID: id)
//                            }
                        }
                    } else {
                        self.blockSubject.onNext(())
                    }
                }
            }).disposed(by: bag)
            if message.count > 500 {
                message = String(message[message.index(message.startIndex, offsetBy: 500)..<message.endIndex])
                if message.count < 500 {
                    Server.instance.sendChatMessage(message: message, forRoom:self.input.roomID).asObservable().subscribe(onNext: { (result) in
                        switch result {
                        case .failed(error: let error):
                            DLogError(error)
                        case .success(let message):
                            DLogInfo(message)
                            if message.status {
                                if self.privateChat.isPrivateChatOn.value {
//                                    if self.privateChat.privateChatDuration != .singleConversation, let id = message.msgId {
//                                        self.sendDestroyMessage(messageID: id)
//                                    }
                                }
                            } else {
                                self.blockSubject.onNext(())
                            }
                        }
                    }).disposed(by: bag)
                }
            }
        } while message.count > 500
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
    
    private func isBlocked() {
        
    }
}
