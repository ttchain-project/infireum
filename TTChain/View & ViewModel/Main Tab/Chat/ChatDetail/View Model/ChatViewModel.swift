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
        var chatAvatar:String?
        var messageText:UITextField
        var uid: String?
    }
    
    struct Output {
        
    }
    
    let outputMessageSubject = PublishSubject<String>.init()
    var input: Input
    var output: Void
    
    private lazy var _messages: BehaviorRelay<[MessageModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    public var messages: Observable<[MessageModel]> {
        return _messages.asObservable().share()
    }
    
    public var chatMessages:[MessageModel] {
        return  _messages.value
    }
    
    public var shouldScrollToBottom: PublishSubject<Void> = PublishSubject.init()
    public var shouldRefreshCellsForDataUpdate: PublishSubject<Void> = PublishSubject.init()
    var bag: DisposeBag = DisposeBag()
    
    lazy var timer : Observable<NSInteger> = { return Observable<NSInteger>.interval(3, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()
    
    var timerSub: Disposable?
    var groupInfoModel: BehaviorRelay<UserGroupInfoModel?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    public var memberAvatarMapping: [String:String?] = [:]
    
    public lazy var isGroup:Bool = {
       return self.input.roomType != .pvtChat
    }()
    
    var privateChat : PrivateChatSetup
    
    let blockSubject = PublishSubject<Bool>()
    
    required init(input: Input, output: Void) {
        self.input = input
        self.privateChat = PrivateChatSetup.init()
        
        if self.input.roomType != RoomType.pvtChat {
            self.getGroupDetails()
        }else {
            self.isBlocked()
        }
//        self.timerSub =
            timer.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            self.fetchAllMessagesForPrivateChat()
        }).disposed(by: bag)
        
        self.groupInfoModel.asObservable().subscribe(onNext: {[weak self] (model) in
            guard model?.membersArray != nil else {
                return
            }
            for member in (model?.membersArray!)! {
                self?.memberAvatarMapping[member.uid] = member.avatarUrl
            }
            self?.shouldRefreshCellsForDataUpdate.onNext(())
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
            let model = FriendInfoModel.init(uid: memberId, nickName: self.input.chatTitle, roomId: self.input.roomID, headhShotImgString: self.input.chatAvatar ?? "")
            return model
        }
    }
    
    func fetchAllMessagesForPrivateChat() {
        Server.instance.getChatHistory(forRoom: self.input.roomID, roomType: self.input.roomType).asObservable().subscribe(onNext: { [unowned self] (response) in
            switch response {
            case .failed(error: let error):
                print(error)                
            case .success(let chatHistory):
                let prevCount = self._messages.value.count
                self._messages.accept(chatHistory.messageArray.reversed())
                if (prevCount != chatHistory.messageArray.count) {
                    self.shouldScrollToBottom.onNext(())
                }
                if (self._messages.value.last != chatHistory.messageArray.first) {
                    self.shouldScrollToBottom.onNext(())
                }
            }
        }).disposed(by: bag)
    }
    
    func getGroupDetails() {
        Server.instance.getGroupInfo(forRoomID: self.input.roomID).asObservable().subscribe(onNext: { [weak self] (response) in
            switch response {
            case .failed(error: let error):
                print(error)
            case .success(let model):
                self?.groupInfoModel.accept(model.groupInfo)
                self?.input.roomType = model.groupInfo.roomType
            }
        }).disposed(by: bag)
    }
    
    func sendImageAsMessage(image:UIImage) {
        guard let imgData = UIImageJPEGRepresentation(image, 0.5) else {
            return
        }
        DLogInfo("Trying to send Image message \(image)")

       self.sendDataAsMessage(data: imgData,fileName: "image.jpeg")
    }
    
    func sendVoiceMessage(data:Data) {
        DLogDebug("\(data.count)")
        self.sendDataAsMessage(data: data,fileName: "audioRecording.3gpp")
    }
    
    
    
    func sendReceiptMessage(for walletAddress: String , identifier: String, amount: String) {
        let message = "{\"address\":\"" + walletAddress + "\",\"amount\":\"" + amount + "\",\"coinID\":\"" + identifier + "\"}"
        
        guard canPostMessage() else {
            return
        }
        let parameter = IMSendCoinRequestAPI.Parameter.init(roomId: self.input.roomID, isGroup: isGroup, msg: message)
        
        Server.instance.sendCoinRequestMessage(parameter: parameter).asObservable().subscribe(onNext: {[unowned self] (result) in
            switch result {
            case .failed(error: let error):
                DLogError(error)
            case .success(let message):
                DLogInfo("Message sent successfully \(parameter.msg) \(message.status)")
                self.fetchAllMessagesForPrivateChat()
                if message.status {
                    if self.privateChat.isPrivateChatOn.value {
                    }
                } else {
                    self.blockSubject.onNext((true))
                }
            }
        }).disposed(by: bag)
    }

    func sendForwardedMessages(messages:[MessageModel]) {
        
        for message in messages {
            switch message.msgType {
            case .general,.urlMessage :
                self.sendMessage(txt:message.msg)
            case .image:
                if let url = URL.init(string:message.msg) {
                    KLRxImageDownloader.instance.download(source: url) {[weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .failed:
                            break
                        case .success(let img):
                            self.sendImageAsMessage(image: img)
                        }
                    }
                }
                continue
            case .file:
                if let url = URL.init(string: message.msg) {
                    FileDownloader.instance.download(source: url) {[weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .failed:
                            break
                        case .success(let data):
                            self.sendDataAsMessage(data: data, fileName:"file.\(url.lastPathComponent)")
                        }
                    }
                }
            case .voiceMessage:
                if let url = URL.init(string: message.msg) {
                    FileDownloader.instance.download(source: url) {[weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .failed:
                            break
                        case .success(let data):
                            self.sendVoiceMessage(data: data)
                        }
                    }
                }
            default:
                continue
            }
        }
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
        
        guard let user = IMUserManager.manager.userModel.value,canPostMessage() else {
            return
        }
        
        let parameter = IMSendMessageAPI.Parameter.init(uid: user.uID, roomId: self.input.roomID, isGroup: isGroup, msg: txt)
        DLogInfo("Trying to send message \(parameter.msg)")

        Server.instance.sendMessage(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let error):
                DLogError(error)
            case .success(let message):
                DLogInfo("Message sent successfully \(parameter.msg) \(message.status)")
                self.fetchAllMessagesForPrivateChat()
                if message.status {
                    if self.privateChat.isPrivateChatOn.value {
                    }
                } else {
                    self.blockSubject.onNext((true))
                }
            }
        }).disposed(by: bag)
    }
    
    func sendDataAsMessage(data:Data, fileName:String) {
        guard let user = IMUserManager.manager.userModel.value,canPostMessage() else {
            return
        }
        let param = UploadFileAPI.Parameters.init(uid: user.uID,
                                                  isGroup: self.isGroup,
                                                  image: data,roomId: self.input.roomID,
                                                  fileName:fileName)
        
        Server.instance.uploadFile(parameters:param).asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .failed(error: let error):
                DLogError(error)
            case .success(let message):
                DLogInfo(message)
                self?.fetchAllMessagesForPrivateChat()
                
            }
        }).disposed(by: bag)
    }
    
    private func isBlocked() {
        guard let uid = self.input.uid else {
            return
        }
        guard let user = IMUserManager.manager.userModel.value else {
            return
        }
        
        Server.instance.searchUser(uid: user.uID, targetUid: uid).asObservable().subscribe(onNext: {[weak self] (response) in
            switch response {
            case .success(let model):
                self?.blockSubject.onNext((model.isBlock))
            case .failed(_):
                print("Failed")
            }
        } ).disposed(by: bag)
    }
    
    func canPostMessage() -> Bool {
        let status = self.groupInfoModel.value?.isPostMsg ?? true
        if !status {
            self.outputMessageSubject.onNext(LM.dls.alert_post_message_restriction)
        }
        return status
    }
    
    func getPrivateChatStatus() {
        let parameter = GetSelfDestructingStatusAPI.Parameter.init(roomId: self.input.roomID, roomType: self.input.roomType.rawValue)
        Server.instance.getDestructMessageSetting(parameter: parameter).asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .failed(error:let error) :
                print(error)
            case .success(let model):
                self?.privateChat.isPrivateChatOn.accept(model.isOpenSelfDestructingMessage)
                self?.privateChat.privateChatDuration = model.privateChatType
            }
        }).disposed(by: bag)
    }
    func deleteChatMessage(messageModel:MessageModel) {
        Server.instance.deleteMessage(messageId:messageModel.messageId, roomID:messageModel.roomId).asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .failed(error:let error) :
                print(error)
            case .success(_):
                self?.fetchAllMessagesForPrivateChat()
            }
        }).disposed(by: bag)
    }
    
    func redEnvelopeAction(forRedEnvId redEnvMessage:RedEnvelope, navigateTo toViewController:@escaping (UIViewController) -> ()) {
        let parameter = RedEnvelopeInfoAPI.Parameters.init(redEnvelopeId: redEnvMessage.identifier)
        Server.instance.getRedEnvelopeInfo(parameter: parameter).asObservable().subscribe(onNext: {[weak self] (response) in
            guard self != nil else {
                return
            }
            switch response {
            case .success(let model):
                let info = model.redEnvelopeInfo
                var vc:UIViewController!
                if [Tokens.getUID(),Tokens.getRocketChatUserID()].contains(redEnvMessage.senderUID) {
                    let viewModel = RedEnvelopeDetailViewModel.init(identifier: redEnvMessage.identifier, information: info)
                    
                    let redEnvVC = RedEnvelopeDetailViewController.init(viewModel: viewModel)
                    
                   vc = UINavigationController.init(rootViewController: redEnvVC)
                    viewModel.output.actionSubject.subscribe(onNext: { (action) in
                        switch action {
                        case .dismiss:
                            vc.dismiss(animated: true, completion: nil)
                        case .history:
                            print("History")
                        }
                    }).disposed(by: viewModel.disposeBag)
                    
                }else {
                    
                    let viewModel = RedEvelopeInfoViewModel.init(identifier: redEnvMessage.identifier, information: info)
                    vc = ReceiveRedEnvelopeViewController.init(viewModel: viewModel)
                    
                    viewModel.output.actionSubject.subscribe(onNext: { (_) in
                        vc.dismiss(animated: true, completion: nil)
                    }).disposed(by: viewModel.disposeBag)
                }
                
                toViewController(vc)
                
            case .failed(error:let error):
                print(error)
            }
        }).disposed(by: bag)
    }
    
}
