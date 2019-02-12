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
    var privateChatDuration : PrivateChatDuration? = nil
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
    
    lazy var timer : Observable<NSInteger> = { return Observable<NSInteger>.interval(3, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()
    
    var timerSub: Disposable?
    var groupInfoModel: BehaviorRelay<UserGroupInfoModel?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    public var memberAvatarMapping: [String:UIImage] = [:]
    
    var privateChat : PrivateChatSetup
    
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
        self.getPrivateChatStatus()
    }
    
    func concatInput() {
    }
    func concatOutput() {}
    
    func getFriendsModel(for memberId:String) -> FriendModel? {
        switch self.input.roomType {
        case .group, .channel:
            guard let groupMemberModelArray = self.groupInfoModel.value?.membersArray?.filter({ $0.uid == memberId }) else {
                return nil
            }
            if groupMemberModelArray.count <= 0 {
                return nil
            }
            let groupMemberModel = groupMemberModelArray[0]
            if let isBlocked = groupMemberModel.isBlocked, isBlocked {
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
    
    func sendImageAsMessage(image:UIImage) {
        guard let user = IMUserManager.manager.userModel.value,let imgData = UIImageJPEGRepresentation(image, 0.5) else {
            return
        }
        let param = UploadFileAPI.Parameters.init(uid: user.uID, isGroup: self.input.roomType == .pvtChat ? false : true, image: imgData, roomId: self.input.roomID)
        Server.instance.uploadFile(parameters:param).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let error):
                DLogError(error)
            case .success(let message):
                DLogInfo(message)
                self.fetchAllMessagesForPrivateChat()

            }
        }).disposed(by: bag)
    }
    
    func sendReceiptMessage(for walletAddress: String , identifier: String, amount: String) {
        let message = "{\"address\":\"" + walletAddress + "\",\"amount\":\"" + amount + "\",\"coinID\":\"" + identifier + "\"}"
        self.sendMessage(txt: message)
    }

    
    func sendMessage() {
        var string = self.input.messageText.text
        self.input.messageText.text = ""
        self.input.messageText.sendActions(for: .valueChanged)
        string = string?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed = string else {
            return
        }
        
        var message = trimmed

        
        repeat {
            self.sendMessage(txt: message)
            if message.count > 500 {
                message = String(message[message.index(message.startIndex, offsetBy: 500)..<message.endIndex])
                if message.count < 500 {
                    self.sendMessage(txt: message)
                }
            }
        } while message.count > 500
    }
    
    
    func sendMessage(txt:String) {
        
        guard let user = IMUserManager.manager.userModel.value else {
            return
        }
        
        let parameter = IMSendMessageAPI.Parameter.init(uid: user.uID, roomId: self.input.roomID, isGroup: self.input.roomType == .pvtChat ? false : true, msg: txt)

        Server.instance.sendMessage(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let error):
                DLogError(error)
            case .success(let message):
                DLogInfo(message)
                self.fetchAllMessagesForPrivateChat()
                if message.status {
                    if self.privateChat.isPrivateChatOn.value {
                    }
                } else {
                    self.blockSubject.onNext(())
                }
            }
        }).disposed(by: bag)
    }
    
    private func isBlocked() {
        
    }
    
    func getPrivateChatStatus() {
        let parameter = GetSelfDestructingStatusAPI.Parameter.init(roomId: self.input.roomID, roomType: self.input.roomType.rawValue)
        Server.instance.getDestructMessageSetting(parameter: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error:let error) :
                print(error)
            case .success(let model):
                self.privateChat.isPrivateChatOn.accept(model.isOpenSelfDestructingMessage)
                self.privateChat.privateChatDuration = model.privateChatType
            }
        }).disposed(by: bag)
    }
    func deleteChatMessage(messageModel:MessageModel) {
        Server.instance.deleteMessage(messageId:messageModel.messageId, roomID:messageModel.roomId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error:let error) :
                print(error)
            case .success(_):
                self.fetchAllMessagesForPrivateChat()
            }
        }).disposed(by: bag)
    }
}
