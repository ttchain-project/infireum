//
//  ChatViewController.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import IQKeyboardManagerSwift
import PhotosUI
import AVFoundation
import CoreServices.UTCoreTypes


enum ChatEntryPoint {
    case notification
    case chatList
}
final class ChatViewController: KLModuleViewController, KLVMVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardView: ChatKeyboardView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var blockviewHeight: NSLayoutConstraint!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var viewToHideKeyboard: UIView!
    private lazy var profileBarButtonButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "chat_info_icon"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            switch self.viewModel.input.roomType {
            case .group, .channel:
                
                guard let userGroupInfoModel = self.viewModel.groupInfoModel.value else { return }
                var action:CreateNewGroupViewController.Config.GroupAction = .Normal
                if let user = IMUserManager.manager.userModel.value, userGroupInfoModel.groupOwnerUID == user.uID {
                    action = .Edit
                }
                
                let vc = CreateNewGroupViewController.instance(from: CreateNewGroupViewController.Config(groupAction: action, groupModel: userGroupInfoModel))
                self.navigationController?.pushViewController(vc,animated:true)
            case .pvtChat:
                self.toUserProfileVC(forFriend:self.viewModel.getFriendsModel(for:self.viewModel.input.uid!)!)
            }
        }).disposed(by: bag)
        return barButtonButton
    }()
    
    
    private lazy var secretChatBarButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "secret_chat_timer"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            switch self.viewModel.input.roomType {
            case .pvtChat:
                self.toChatSecretViewController()
            default:
                return
            }
        }).disposed(by: bag)
        return barButtonButton
    }()
    
    let IQKeyboardManagerEnableStatus = IQKeyboardManager.shared.enable
    private var friendInfoModel: FriendInfoModel?
    var viewModel: ChatViewModel!
    var bag: DisposeBag = DisposeBag()
    var imagePicker: UIImagePickerController!
    
    var player:AVPlayer?
    
    struct Config {
        var roomType:RoomType
        var chatTitle:String
        var roomID:String
        var chatAvatar:String?
        var uid: String?
        var entryPoint:ChatEntryPoint
    }
    
    typealias Constructor = Config
    
    private var chatEntryPoint: ChatEntryPoint?
    
    func config(constructor: ChatViewController.Config) {
        view.layoutIfNeeded()
        //
        viewModel = ViewModel.init(
            input: ChatViewModel.Input.init(
                roomType: constructor.roomType,
                chatTitle: constructor.chatTitle,
                roomID: constructor.roomID,
                chatAvatar: constructor.chatAvatar,
                messageText: self.keyboardView.textField,
                uid: constructor.uid
            ),
            output: ())
        self.chatEntryPoint = constructor.entryPoint
        
        
        initTableView()
        initKeyboardView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
    
        self.viewModel.outputMessageSubject.asObservable().subscribe(onNext:{[unowned self] message in
            self.showAlert(title: "", message: message)
        }).disposed(by:bag)
        
        self.tableView.contentInset.bottom = 40
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = IQKeyboardManagerEnableStatus
        self.player = nil
    }

    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 18))
        changeNavShadowVisibility(true)
        tableView.backgroundColor = UIColor.CSS.whiteSmoke
        changeLeftBarButton(target: self, selector: #selector(backButtonTapped), tintColor: palette.nav_item_2, image:#imageLiteral(resourceName: "btn_previous_light") )
        self.viewToHideKeyboard.backgroundColor = palette.btn_bgFill_enable_bg
        
        navigationItem.rightBarButtonItems = viewModel.input.roomType == .channel ? [profileBarButtonButton] : [profileBarButtonButton,secretChatBarButton]
        navigationItem.rightBarButtonItem?.tintColor = palette.nav_item_2
        self.blockedLabel.set(textColor: .white, font: .owMedium(size: 14))
        self.blockView.set(backgroundColor: .owPinkRed)
    }
    
    override func renderLang(_ lang: Lang) {
        self.title = self.viewModel.input.chatTitle
        self.blockedLabel.text = lang.dls.chat_room_has_blocked
    }
    
    func initTableView() {
        tableView.register(ChatMessageTableViewCell.nib, forCellReuseIdentifier: ChatMessageTableViewCell.nameOfClass)
        tableView.register(ChatMessageImageTableViewCell.nib, forCellReuseIdentifier: ChatMessageImageTableViewCell.nameOfClass)
        tableView.register(ReceiptTableViewCell.nib, forCellReuseIdentifier: ReceiptTableViewCell.nameOfClass)
        tableView.register(RedEnvTableViewCell.nib, forCellReuseIdentifier: RedEnvTableViewCell.nameOfClass)
        tableView.register(RceiveRedEnvelopeTableViewCell.nib, forCellReuseIdentifier: RceiveRedEnvelopeTableViewCell.nameOfClass)
        tableView.register(UnknownFileTableViewCell.nib, forCellReuseIdentifier: UnknownFileTableViewCell.nameOfClass)
        
        tableView.rx.klrx_tap.drive(onNext: { [unowned self] _ in
            self.view.endEditing(true)
        }).disposed(by: bag)
    }
    
    func bindViewModel() {
        
        viewModel.messages.distinctUntilChanged().bind(to: tableView.rx.items) {
            [unowned self]
            tv,row,messageModel in
            
            var cell: UITableViewCell
            var leftImage: String?
            
            switch self.viewModel.input.roomType {
            case .group,.channel:
                leftImage = self.viewModel.memberAvatarMapping[messageModel.userName ?? ""] ?? ""
            case .pvtChat:
                leftImage = self.viewModel.input.chatAvatar
            }
            
            switch messageModel.msgType {
            case .general,.audioCall(_),.urlMessage:
                let chatCell = tv.dequeueReusableCell(withIdentifier: ChatMessageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageTableViewCell
                
                chatCell.config(forMessage: messageModel, leftImage: leftImage, leftImageAction: {[weak self] id in
                    guard let friendModel = self?.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self?.toUserProfileVC(forFriend: friendModel)
                })
                chatCell.leftMessageLabel.rx.klrx_tap.asDriver().drive(onNext: { _ in
                    if case .urlMessage = messageModel.msgType {
                        guard let urlMessage = messageModel.msg.getURLIfPresent() else {
                            return
                        }
                        guard let url = URL.init(string: urlMessage) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }).disposed(by: chatCell.bag)
                chatCell.rightMessageLabel.rx.klrx_tap.asDriver().drive(onNext: { _ in
                    
                    if case .urlMessage = messageModel.msgType {
                        guard let urlMessage = messageModel.msg.getURLIfPresent() else {
                            return
                        }
                        guard let url = URL.init(string: urlMessage) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    
                    
                }).disposed(by: chatCell.bag)
                
                chatCell.rx.longPressGesture().skip(1).subscribe(onNext: {[weak self] (_) in
                    if case .audioCall = messageModel.msgType {
                        return
                    }
                    self?.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: chatCell.bag)
                cell = chatCell
                
            case .image,.voiceMessage:
                
                let chatImgCell = tv.dequeueReusableCell(withIdentifier: ChatMessageImageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageImageTableViewCell
                
                chatImgCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: {[weak self] id in
                    guard let friendModel = self?.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self?.toUserProfileVC(forFriend: friendModel)
                })
                chatImgCell.msgImageView!.rx.klrx_tap.drive(onNext: {[weak self] _ in
                    if case .image = messageModel.msgType {
                        self?.toImageViewer(for: messageModel)
                    }else {
                        self?.playAudio(messageModel: messageModel)
                    }
                }).disposed(by: chatImgCell.bag)
                
                chatImgCell.rx.longPressGesture().skip(1).subscribe(onNext: {[weak self] (_) in
                    messageModel.messageImage = chatImgCell.msgImageView.image
                    self?.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: chatImgCell.bag)
                
                cell = chatImgCell
                
            case .file :
                let unknownFileCell = tv.dequeueReusableCell(withIdentifier: UnknownFileTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! UnknownFileTableViewCell
                unknownFileCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: {[weak self] id in
                    guard let friendModel = self?.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self?.toUserProfileVC(forFriend: friendModel)
                })
                unknownFileCell.rx.longPressGesture().skip(1).subscribe(onNext: { [weak self] (_) in
                    messageModel.messageImage = unknownFileCell.msgImageView.image
                    self?.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: unknownFileCell.bag)
                unknownFileCell.msgImageView.rx.klrx_tap.asDriver().drive(onNext: {[weak self] (_) in
                    self?.toFileViewer(messageModel: messageModel)
                }).disposed(by: unknownFileCell.bag)
                cell = unknownFileCell
                
            case .receipt :
                let receiptCell = tv.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ReceiptTableViewCell
                
                receiptCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: {[weak self] id in
                    guard let friendModel = self?.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self?.toUserProfileVC(forFriend: friendModel)
                })
                
                receiptCell.rx.longPressGesture().skip(1).subscribe(onNext: {[weak self] (_) in
                    self?.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: receiptCell.bag)
                
                receiptCell.bgView.rx.klrx_tap.asDriver().drive(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    let dict = messageModel.msgType.messageDict
                    self.toTransferByReceipt(dict:dict)
                }).disposed(by: receiptCell.bag)
                
                cell = receiptCell
            case .createRedEnvelope:
                let redEnvCell = tv.dequeueReusableCell(withIdentifier: RedEnvTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! RedEnvTableViewCell
                
                redEnvCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: { id in
                    guard let friendModel = self.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self.toUserProfileVC(forFriend: friendModel)
                })
                
                redEnvCell.bgView.rx.klrx_tap.asDriver().drive(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    guard let redEnvMessage = messageModel.msgType.redEnvelopeMessage else {
                        return
                    }
                    self.toRedEnvelope(forMessage: redEnvMessage)
                }).disposed(by: redEnvCell.bag)
                
                cell = redEnvCell
            case .receiveRedEnvelope:
                let rcvRedEnvCell = tv.dequeueReusableCell(withIdentifier: RceiveRedEnvelopeTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! RceiveRedEnvelopeTableViewCell
                rcvRedEnvCell.config(message: messageModel)
                
                rcvRedEnvCell.bgView.rx.klrx_tap.asDriver().drive(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    guard let redEnvMessage = messageModel.msgType.redEnvelopeMessage, redEnvMessage.senderUID == Tokens.getUID() else {
                        return
                    }
                    self.toRedEnvelope(forMessage: redEnvMessage)
                }).disposed(by: rcvRedEnvCell.bag)
                
                cell = rcvRedEnvCell
            }
            
            return cell
        }.disposed(by: bag)
        
        viewModel.shouldScrollToBottom.asObservable().subscribe(onNext: {[unowned self] in
            self.tableView.scrollToLastRow()
        })
            .disposed(by: bag)
        
        viewModel.shouldRefreshCellsForDataUpdate.asObservable().subscribe(onNext: {[unowned self] in
            self.tableView.reloadData()
        }).disposed(by: bag)
        
        self.viewModel.privateChat.isPrivateChatOn
            .asObservable().map {[weak self] status in
                if status {
                    self?.keyboardView.privateChatDurationTitleLabel.text = LM.dls.secret_chat_on
                    self?.secretChatBarButton.tintColor = .owPumpkinOrange
                }else {
                    self?.keyboardView.privateChatDurationTitleLabel.text = ""
                    self?.secretChatBarButton.tintColor = .white
                }
                return !status
            }
            .bind(to: self.keyboardView.privateChatBannerView.rx.isHidden)
            .disposed(by: bag)
    
        viewModel.blockSubject.subscribe(onNext: {
            [weak self] status in
            guard let `self` = self else { return }
            self.keyboardView.endEditing(true)
            self.blockviewHeight.constant = status ? 44 : 0
            self.view.layoutIfNeeded()
            self.keyboardView.isBlock = status
        }).disposed(by: bag)
        
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initKeyboardView() {
        
        keyboardView.config(input: ChatKeyboardView.Input(roomType:self.viewModel.input.roomType),
                            output: ChatKeyboardView.Output.init(didChangeViewHeight: { [weak self] (value) in
                                guard let `self` = self else {
                                    return
                                }
                                self.view.setNeedsLayout()
                                self.keyboardViewHeight.constant = value
                                UIView.animate(withDuration: 0.25, animations: {
                                    self.view.layoutIfNeeded()
                                })
                            }, onSelectChatFunction: { [unowned self]function in
                                switch function.type {
                                case .addPhoto:
                                    guard PhotoAuthHandler.hasAuthedPhotoLibrary else {
                                        return
                                    }
                                    self.displayCamera(forSource: .photoLibrary)
                                case .openCamera:
                                    guard PhotoAuthHandler.hasAuthedCamera else {
                                        return
                                    }
                                    self.displayCamera(forSource: .camera)
                                case .addReceipt:
                                    self.toAddReciept()
                                case .redEnv:
                                    self.toCreateRedEnv()
                                case .sendDocument:
                                    self.openDocumentViewer()
                                default:
                                    break
                                }
                                }, onVoiceMessageSuccess: { [unowned self] data in
                                    self.viewModel.sendVoiceMessage(data: data)
                            }))
        
        keyboardView
            .sendButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: {[unowned self] in
                self.viewModel.sendMessage()
            })
            .disposed(by: bag)
        
        keyboardView.textField.rx.controlEvent([.editingDidBegin,.editingDidEnd])
            .asObservable()
            .subscribe(onNext: {[unowned self] _ in
              self.tableView.scrollToLastRow()
            })
            .disposed(by: bag)
        
    }
    
    func toChatSecretViewController() {
        let vc =
            PrivateChatSettingViewController.instance(from: PrivateChatSettingViewController.Config(selectedDurationIfAny:self.viewModel.privateChat.privateChatDuration,
             privateModeStatusIfAny:self.viewModel.privateChat.isPrivateChatOn.value,
             roomId: self.viewModel.input.roomID,
             roomType:self.viewModel.input.roomType,
             uId:self.viewModel.input.uid!)
        )
        
        vc.onChatSecretChoicesComplete.asObservable().subscribe(onNext: {[unowned self] (duration, isSelected) in
            self.viewModel.privateChat.privateChatDuration = duration
            self.viewModel.privateChat.isPrivateChatOn.accept(isSelected)
        }).disposed(by: bag)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func toAddReciept() {
        let recieptVC = ReceiptRequestViewController.instance()
        self.navigationController?.pushViewController(recieptVC, animated: true)
        
        recieptVC.onSelectingCoin.asObservable().subscribe(onNext: { [unowned self] (walletAddress,identifier,amount) in
            self.viewModel.sendReceiptMessage(for: walletAddress, identifier: identifier, amount: amount)
        }).disposed(by: bag)
    }
    
    func showOptionsForLongGesture(for message:MessageModel) {
        
        let actionCopy = UIAlertAction.init(title: LM.dls.g_copy, style: .default) { (_) in
            UIPasteboard.general.string = message.msg
        }
        
        let actionCopyFileURL = UIAlertAction.init(title:LM.dls.copy_file_url, style: .default) { (_) in
            UIPasteboard.general.string = message.msg
        }
        
        let downloadAction = UIAlertAction.init(title:LM.dls.download_file_title, style: .default) { (_) in
            guard let url = URL.init(string:message.msg) else {
                return
            }
            FileDownloader.instance.download(source:url , onComplete: { [weak self] (result) in
                if let `self` = self {
                    EZToast.present(on: self, content: LM.dls.file_download_successful_message)
                }
            })
            
        }
        let delete = UIAlertAction.init(title:LM.dls.delete,style:.default) {[weak self] (_) in
            //to Delete Message
            self?.viewModel.deleteChatMessage(messageModel:message)
        }
        let cancelButton = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        
        let forward = UIAlertAction.init(title:LM.dls.forward,style:.default) { [unowned self] (_) in
            let config = ForwarMessageViewController.Config.init(messages: self.viewModel.chatMessages,
                                                                 roomId: self.viewModel.input.roomID,
                                                                 avatarImage: self.viewModel.input.chatAvatar,
                                                                 memberAvatarMapping: self.viewModel.memberAvatarMapping,
                                                                 forwardMessagesSelected: { [weak self] chatListModel, messages in
                                                                    guard let `self` = self else {
                                                                        return
                                                                    }
                                                                    self.refreshChatViewForForwardedChat(withMessage: messages, chatList: chatListModel)
            })
            
            let vc = ForwarMessageViewController.navInstance(from: config)
            self.present(vc, animated: false, completion: nil)
        }
        
        let alertVC = UIAlertController.init(title: LM.dls.message_action, message: "", preferredStyle: .actionSheet)
        
        if message.isUserSender() {
            alertVC.addAction(delete)
        }
        switch message.msgType {
        case .general,.urlMessage:
            alertVC.addAction(actionCopy)
            alertVC.addAction(forward)
            break
        case .file:
            alertVC.addAction(actionCopyFileURL)
            alertVC.addAction(downloadAction)
            alertVC.addAction(forward)

        case .voiceMessage:
            alertVC.addAction(forward)
        case .image:
            alertVC.addAction(actionCopy)
            alertVC.addAction(forward)
        default:
            break
        }
        if alertVC.actions.count == 0 {
            return
        }
        alertVC.addAction(cancelButton)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func toImageViewer(for message:MessageModel) {
        guard let url = URL.init(string: message.msg) else {
            return
        }
        let vc = ChatImageViewController.instance(from: ChatImageViewController.Config(image: url))
        self.show(vc, sender: nil)
    }
    
    func playAudio(messageModel:MessageModel) {
        guard let url = URL.init(string: messageModel.msg) else {
            return
        }
        self.player = nil
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error{
            print(error)
        }
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem:playerItem)
        player!.volume = 1.0
        player!.play()
    }
    
    func toTransferByReceipt(dict : [String:String]) {
        guard let coinId = dict["coinID"], let address = dict["address"], let amount = dict["amount"] else {
            return
        }
        guard let coin = Coin.getCoin(ofIdentifier: coinId) else {
            return
        }
        guard let asset = Identity.singleton?.getAllAssets(of: coin).first else {
            return
        }
        let config = WithdrawalBaseViewController.Config.init(asset: asset, defaultToAddress: address, defaultAmount: amount)

        let vc = WithdrawalBaseViewController.instance(from: config)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func toCreateRedEnv() {
        
        guard self.viewModel.canPostMessage() else {
            return
        }
        let cordinator = RedEnvelopeCordinator.init()
        
        var type: CreateRedEnvelopeViewModel.CreateType = .normal
        var memberCount : Int = 0
        if self.viewModel.input.roomType != .pvtChat {
            type = .group
            memberCount = self.viewModel.groupInfoModel.value?.membersArray?.count ?? 0
        }
        
        cordinator.showCreateRedEnvelope(memberCount: memberCount, type: type, identifier: self.viewModel.input.roomID, presenterVC: self)
        
    }
    
    fileprivate func displayCamera(forSource sourceType:UIImagePickerController.SourceType ) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false

        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func openDocumentViewer() {
        let importMenu = UIDocumentPickerViewController.init(documentTypes: [String(kUTTypePDF),String(kUTTypeImage)], in: .import)
        importMenu.delegate = self
        importMenu.allowsMultipleSelection = false
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true, completion: nil)
    }
    
    
    func toUserProfileVC(forFriend friend: FriendModel) {
        
        var purpose : UserProfileViewController.Purpose
        if friend is GroupMemberModel {
            let friends = friend as! GroupMemberModel
            purpose = friends.isFriend! ? .myFriend : .notMyFriend
        }else {
            purpose = .myFriend
        }
        let config = UserProfileViewController.Config.init(purpose: purpose, user: friend)
        let viewController = UserProfileViewController.instance(from: config)
        self.show(viewController, sender: nil)
        viewController.blockStatusChanged.bind(to: self.viewModel.blockSubject).disposed(by:viewController.bag)
    }
    
    func toFileViewer(messageModel:MessageModel) {
        guard let fileURL = URL.init(string: messageModel.msg) else {
            return
        }
        let vc = ExploreDetailWebViewController.instance(from: ExploreDetailWebViewController.Config(model:nil,url:fileURL))
        self.navigationController?.pushViewController(vc)
    }
    
    private func refreshChatViewForForwardedChat(withMessage messages:[MessageModel], chatList:ChatListPage) {
        var roomType: RoomType?
        var chatTitle: String = ""
        var roomId:String = ""
        var chatAvatar: String?
        var uid: String? = nil
        switch chatList {
        case is CommunicationListModel:
            let commModel = chatList as! CommunicationListModel
            roomType = commModel.roomType
            chatTitle = commModel.displayName
            roomId = commModel.roomId
            chatAvatar = commModel.img
            uid = commModel.privateMessageTargetUid
        case is FriendModel:
            let friendModel = chatList as! FriendInfoModel
            chatTitle = friendModel.nickName
            roomType = .pvtChat
            roomId = friendModel.roomId
            chatAvatar = friendModel.avatarUrl
            uid = friendModel.uid
        case is UserGroupInfoModel:
            let groupModel = chatList as! UserGroupInfoModel
            chatTitle = groupModel.groupName
            roomType = groupModel.roomType
            roomId = groupModel.imGroupId
            chatAvatar = groupModel.headImg
            uid = nil
        default:
            print("CommunicationListModel")
        }
        self.viewModel.timerSub?.dispose()
        self.bag = DisposeBag()
        self.config(constructor: ChatViewController.Config.init(roomType: roomType!, chatTitle: chatTitle, roomID: roomId, chatAvatar: chatAvatar, uid: uid,entryPoint: .chatList))
        
        self.viewModel.sendForwardedMessages(messages:messages)
    }
    
    func makeAudioCall() {
        let config = AudioCallViewController.Config.init(roomId: self.viewModel.input.roomID, calleeName: self.viewModel.input.chatTitle,calleeImage:self.viewModel.input.chatAvatar, roomType: .pvtChat, callAction: CallAction.startCall,streamId: nil)
        
        let audioCallVC = AudioCallViewController.instance(from: config)
        self.present(audioCallVC, animated: true, completion: nil)
    }

    func toRedEnvelope(forMessage message: RedEnvelope) {
        let cordinator = RedEnvelopeCordinator.init()
        cordinator.redEnvelopeAction(forRedEnvId: message, onNavVC: self)
    }
}

extension UITableView {
    func scrollToLastRow() {
        if self.numberOfRows() > 0 {
            let indexPath = IndexPath.init(row: self.numberOfRows() - 1, section: 0)
            DispatchQueue.main.async {
                self.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        let viewController = PhotoCropperViewController.init(withImage: img) { (image) in
            self.viewModel.sendImageAsMessage(image:image)
            picker.dismiss(animated: true, completion: nil)
        }
        picker.pushViewController(viewController)
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                if ["jpeg","jpg","png"].contains(url.pathExtension) {
                    if let image = UIImage.init(data: data)  {
                        self.viewModel.sendImageAsMessage(image: image)
                    }
                }else {
                    self.viewModel.sendDataAsMessage(data: data, fileName: "\(url.lastPathComponent)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}
