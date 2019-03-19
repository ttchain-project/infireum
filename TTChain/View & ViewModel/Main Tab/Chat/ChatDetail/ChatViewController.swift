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

final class ChatViewController: KLModuleViewController, KLVMVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardView: ChatKeyboardView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var blockviewHeight: NSLayoutConstraint!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var viewToHideKeyboard: UIView!
    private lazy var profileBarButtonButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "iconCommunicationUserDark.png"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            switch self.viewModel.input.roomType {
            case .group, .channel:
                
                guard let userGroupInfoModel = self.viewModel.groupInfoModel.value else { return }
                let viewModel = GroupInformationViewModel(userGroupInfoModel: userGroupInfoModel)
                let viewController = GroupInformationViewController.init(viewModel: viewModel)
                self.show(viewController, sender: nil)
            case .pvtChat:
                self.toUserProfileVC(forFriend:self.viewModel.getFriendsModel(for:self.viewModel.input.uid!)!)
            }
        }).disposed(by: bag)
        return barButtonButton
    }()
    
    private lazy var qrCodeBarButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "tt_QRCode_icon"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            switch self.viewModel.input.roomType {
            case .channel:
                guard let userGroupInfoModel = self.viewModel.groupInfoModel.value else { return }
                let vc = UserIMQRCodeViewController.instance(from: UserIMQRCodeViewController.Config(uid:userGroupInfoModel.groupID, title:LM.dls.group_qr_code))
                self.navigationController?.pushViewController(vc)
            default: return
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
        var chatAvatar:UIImage?
        var uid: String?
    }
    
    typealias Constructor = Config
    
    func config(constructor: ChatViewController.Config) {
        view.layoutIfNeeded()
        //
        viewModel = ViewModel.init(
            input: ChatViewModel.Input.init(
                roomType: constructor.roomType,
                chatTitle: constructor.chatTitle,
                roomID: constructor.roomID,
                chatAvatar: constructor.chatAvatar,
                messageText: self.keyboardView.textField, uid: constructor.uid
            ),
            output: ())
        
        viewModel.blockSubject.subscribe(onNext: {
            [weak self] status in
            guard let `self` = self else { return }
            self.keyboardView.endEditing(true)
//            self.alert(title: LM.dls.chat_room_has_blocked, button: LM.dls.g_ok)
            self.blockviewHeight.constant = status ? 44 : 0
            self.view.layoutIfNeeded()
            self.keyboardView.isBlock = status
        }).disposed(by: bag)
        
        initTableView()
        initKeyboardView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        setUpScrennShotDetection()
    }
    
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
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_2)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 18))
        changeNavShadowVisibility(true)
        tableView.backgroundColor = palette.nav_bg_clear
        changeLeftBarButton(target: self, selector: #selector(backButtonTapped), tintColor: palette.nav_item_2, image:#imageLiteral(resourceName: "arrowNavBlack") )
        self.viewToHideKeyboard.backgroundColor = palette.bgView_main
        
        navigationItem.rightBarButtonItems = viewModel.input.roomType == .channel ? [profileBarButtonButton,qrCodeBarButton] : [profileBarButtonButton]
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
        
        tableView.rx.klrx_tap.drive(onNext: { _ in
            self.view.endEditing(true)
        }).disposed(by: bag)
    }
    
    func bindViewModel() {

        viewModel.messages.distinctUntilChanged().bind(to: tableView.rx.items) {
            [unowned self]
            tv,row,messageModel in
            
            var cell: UITableViewCell
            var leftImage: UIImage?
            
            switch self.viewModel.input.roomType {
            case .group,.channel:
                leftImage = self.viewModel.memberAvatarMapping[messageModel.userName ?? ""]
            case .pvtChat:
                leftImage = self.viewModel.input.chatAvatar
            }
            
            switch messageModel.msgType {
            case .general,.audioCall(_):
                let chatCell = tv.dequeueReusableCell(withIdentifier: ChatMessageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageTableViewCell
                
                chatCell.config(forMessage: messageModel, leftImage: leftImage, leftImageAction: { id in
                    guard let friendModel = self.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self.toUserProfileVC(forFriend: friendModel)
                })
                
                chatCell.rx.longPressGesture().skip(1).subscribe(onNext: { (_) in
                    if case .audioCall = messageModel.msgType {
                        return
                    }
                    self.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: chatCell.bag)
                cell = chatCell
                
            case .file,.voiceMessage:
                let chatImgCell = tv.dequeueReusableCell(withIdentifier: ChatMessageImageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageImageTableViewCell
                
                chatImgCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: { id in
                    guard let friendModel = self.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self.toUserProfileVC(forFriend: friendModel)
                })
                chatImgCell.msgImageView!.rx.klrx_tap.drive(onNext: { _ in
                    if case.file = messageModel.msgType {
                        self.toImageViewer(for: messageModel)
                    }else {
                        self.playAudio(messageModel: messageModel)
                    }
                }).disposed(by: chatImgCell.bag)
                
                chatImgCell.rx.longPressGesture().skip(1).subscribe(onNext: { (_) in
                    messageModel.messageImage = chatImgCell.msgImageView.image
                    self.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: chatImgCell.bag)
                
                cell = chatImgCell
            case .receipt :
                let receiptCell = tv.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ReceiptTableViewCell
                
                receiptCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: { id in
                    guard let friendModel = self.viewModel.getFriendsModel(for: messageModel.userName ?? "") else {
                        return
                    }
                    self.toUserProfileVC(forFriend: friendModel)
                })
                
                receiptCell.rx.longPressGesture().skip(1).subscribe(onNext: { (_) in
                    self.showOptionsForLongGesture(for: messageModel)
                }).disposed(by: receiptCell.bag)
                
                receiptCell.bgView.rx.klrx_tap.asDriver().drive(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    let dict = messageModel.msgType.messageDict
                    self.toTransferByReceipt(dict:dict)
                }).disposed(by: receiptCell.bag)
                
                cell = receiptCell
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
            .asObservable().map { status in
                if status {
                    self.keyboardView.privateChatDurationTitleLabel.text = LM.dls.secret_chat_on
                }else {
                    self.keyboardView.privateChatDurationTitleLabel.text = ""
                }
                return !status
            }
            .bind(to: self.keyboardView.privateChatBannerView.rx.isHidden)
            .disposed(by: bag)
        
        Observable.just(self.viewModel.privateChat.privateChatDuration).asObservable().subscribe(onNext: { (duration) in
            
        }).disposed(by: bag)
    }
    
    @objc func backButtonTapped() {
//        self.viewModel.postChatSection()
        self.viewModel.timerSub?.dispose()
        self.navigationController?.popViewController(animated: true)
    }
    
    func initKeyboardView() {
        
        keyboardView.config(input: ChatKeyboardView.Input(roomType:self.viewModel.input.roomType),
                            output: ChatKeyboardView.Output.init(didChangeViewHeight: { [weak self] (value) in
                                guard let `self` = self else {
                                    return
                                }
                                self.view.setNeedsLayout()
                                self.keyboardViewHeight.constant = value
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.view.layoutIfNeeded()
                                })
                            }, onSelectChatFunction: { [unowned self]function in
                                switch function.type {
                                case .startSecretChat:
                                    self.toChatSecretViewController()
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
                                case .makeAudioCall:
                                    self.makeAudioCall()
                                default:
                                    print("Pending implementation")
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
        
        let delete = UIAlertAction.init(title:LM.dls.delete,style:.default) { (_) in
            //to Delete Message
            self.viewModel.deleteChatMessage(messageModel:message)
        }
        let cancelButton = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        let forward = UIAlertAction.init(title:LM.dls.forward,style:.default) { [unowned self] (_) in
            let vc = ForwardListContainerViewController.init()
            vc.config(constructor: ForwardListContainerViewController.Config(messageModel: message))
            self.navigationController?.pushViewController(vc)
            vc.onForwardChatToSelection.asObservable().subscribe(onNext: { [unowned self] (model) in
                self.refreshChatViewForForwardedChat(withMessage: message, chatList: model)
            }).disposed(by: vc.bag)
        }
        
        let alertVC = UIAlertController.init(title: LM.dls.message_action, message: "", preferredStyle: .actionSheet)
        
        if message.isUserSender() {
            alertVC.addAction(delete)
        }
        switch message.msgType {
        case .general:
            alertVC.addAction(actionCopy)
            alertVC.addAction(forward)
            break
        case .file:
            alertVC.addAction(actionCopyFileURL)
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
    
    fileprivate func displayCamera(forSource sourceType:UIImagePickerController.SourceType ) {
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
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
    
    private func setUpView() {
        
    }
    
    private func setUpScrennShotDetection() {
        NotificationCenter.default.rx.notification(Notification.Name.UIApplicationUserDidTakeScreenshot).subscribe(onNext: {
            [unowned self] _ in
            if self.viewModel.privateChat.isPrivateChatOn.value {
                DLogInfo("User Capture screen with private chat.")
                
            }
        }).disposed(by: bag)
    }
    
    private func refreshChatViewForForwardedChat(withMessage message:MessageModel, chatList:ChatListPage) {
        var roomType: RoomType?
        var chatTitle: String = ""
        var roomId:String = ""
        var chatAvatar: UIImage?
        var uid: String? = nil
        switch chatList {
        case is CommunicationListModel:
            let commModel = chatList as! CommunicationListModel
            roomType = commModel.roomType
            chatTitle = commModel.displayName
            roomId = commModel.roomId
            chatAvatar = commModel.avatar
            uid = commModel.privateMessageTargetUid
        case is FriendModel:
            let friendModel = chatList as! FriendInfoModel
            chatTitle = friendModel.nickName
            roomType = .pvtChat
            roomId = friendModel.roomId
            chatAvatar = friendModel.avatar
            uid = friendModel.uid
        case is UserGroupInfoModel:
            let groupModel = chatList as! UserGroupInfoModel
            chatTitle = groupModel.groupName
            roomType = groupModel.roomType
            roomId = groupModel.imGroupId
            chatAvatar = groupModel.groupIcon
            uid = nil
        default:
            print("CommunicationListModel")
        }
        self.viewModel.timerSub?.dispose()
        self.bag = DisposeBag()
        self.config(constructor: ChatViewController.Config.init(roomType: roomType!, chatTitle: chatTitle, roomID: roomId, chatAvatar: chatAvatar, uid: uid))
        
        switch message.msgType {
        case .general :
            self.viewModel.sendMessage(txt:message.msg)
        case .file:
            guard let image = message.messageImage else {
                return
            }
            self.viewModel.sendImageAsMessage(image: image)
        case .receipt,.audioCall(_),.voiceMessage:
            return
        }
    }
    
    func makeAudioCall() {
        let config = AudioCallViewController.Config.init(roomId: self.viewModel.input.roomID, calleeName: self.viewModel.input.chatTitle, roomType: .pvtChat, callAction: CallAction.startCall,streamId: nil)
        
        let audioCallVC = AudioCallViewController.instance(from: config)
        self.present(audioCallVC, animated: true, completion: nil)
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
        
        var image : UIImage!
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = img
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = img
        }
        let resizedImg = image.scaleImage(toSize: targetSize(for: image))!
        self.viewModel.sendImageAsMessage(image:resizedImg)
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func targetSize(for originImg:UIImage) -> CGSize {
        let originSize = originImg.size
        enum Longer {
            case w
            case h
        }
        
        var targetSize: CGSize = .zero
        let longer : Longer = (originSize.width >= originSize.height) ? .w : .h
        switch longer {
        case .w:
            targetSize.width = min(originSize.width, 480)
            let compressRatio = targetSize.width / originSize.width
            targetSize.height = originSize.height * compressRatio
        case .h:
            targetSize.height = min(originSize.height, 480)
            let compressRatio = targetSize.height / originSize.height
            targetSize.width = originSize.width * compressRatio
        }
        
        return targetSize
    }
}
