//
//  UserProfileViewController.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserProfileViewController: KLModuleViewController, KLVMVC {
    
    var viewModel: UserProfileViewModel!
    func config(constructor: UserProfileViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: (),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()

        self.user = constructor.user
        self.purpose = constructor.purpose
        
        userNameLabel.text = user?.nickName
        
        changeUserInterface(purpose: purpose)
        
        self.sendRequestButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
           self.showStep1AlertDialog()
        }).disposed(by: bag)
    }
    
    typealias ViewModel = UserProfileViewModel
    var bag: DisposeBag = DisposeBag.init()
    private var switchDisposeBag = DisposeBag()
    private var setRecoverBag = DisposeBag()
    
    var user: FriendModel? = nil {
        didSet {
            userIconImageView.image = user?.avatar
            userIdLabel.text = user?.uid
            if let groupMember = user as? GroupMemberModel {
                blockUserSwitch.isOn = groupMember.isBlocked ?? false
            } else if let uid = user?.uid, uid == IMUserManager.manager.userModel.value?.uID {
                Server.instance.getUserData(uID: uid).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .failed(error: _): return
                    case .success(let value):
                        guard let url = URL.init(string: value.headImg) else {
                            return
                        }
                        self.userIconImageView.af_setImage(withURL: url)
                        
                    }
                }).disposed(by: bag)
            } else {
                guard let uid = IMUserManager.manager.userModel.value?.uID, let targetUid = user?.uid else { return }
                Server.instance.searchUser(uid: uid, targetUid: targetUid).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .failed(error: _): return
                    case .success(let value):
                        self.blockUserSwitch.isOn = value.isBlock
                        self.userIconImageView.image = value.imUser.headImg
                        self.userIdLabel.text = value.imUser.uID
                    }
                }).disposed(by: bag)
            }
        }
    }
    var purpose: Purpose = .myself
    
    struct Config {
        let purpose: Purpose
        let user: FriendModel?
    }
    
    enum Purpose {
        case myself
        case myFriend
        case notMyFriend
    }
    
    
    typealias Constructor = Config
    
    
    
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var editUserNameButton: UIButton!
    @IBOutlet weak var userIdView: UIView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var copyUserIdButton: UIButton! {
        didSet {
            copyUserIdButton.rx.tap.subscribe({
                [unowned self] _ in
                UIPasteboard.general.string = self.userIdLabel.text
                EZToast.present(on: self, content: "複製成功")
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var blockUserView: UIView!
    @IBOutlet weak var relationShipTiitleLabel: UILabel!
    @IBOutlet weak var blockUserLabel: UILabel!
    @IBOutlet weak var blockUserSwitch: UISwitch!{
        didSet {
            blockUserSwitch.rx.isOn.subscribe(onNext: {
                [unowned self] isOn in
                guard let uid = IMUserManager.manager.userModel.value?.uID, let blockedUid = self.user?.uid else { return }
                Server.instance.blockUser(parameters: BlockUserAPI.Parameters(uid: uid, blockedUid: blockedUid, action: isOn ? BlockUserAPI.Parameters.Action.block : BlockUserAPI.Parameters.Action.unblock)).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .failed(error: let error):
                        EZToast.present(on: self, content: error.localizedDescription)
                        self.blockUserSwitch.isOn = !isOn
                    case .success:
                        DLogInfo("switch block status for \(blockedUid) to \(isOn)")
                    }
                }).disposed(by: self.switchDisposeBag)
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var logoutIMLabel: UILabel!
    
    
    @IBOutlet weak var sendRequestButton: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func renderTheme(_ theme: Theme) {
        
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bg_1)
        renderNavTitle(color: theme.palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        changeNavShadowVisibility(true)

        userNameLabel.set(
            textColor: theme.palette.label_main_2,
            font: UIFont.owRegular(size: 12)
        )
        userIdLabel.set(
            textColor: theme.palette.label_main_1,
            font: UIFont.owRegular(size: 12)
        )
        relationShipTiitleLabel.set(
            textColor: theme.palette.label_sub,
            font: UIFont.owRegular(size: 12)
        )
        blockUserLabel.set(
            textColor: theme.palette.label_main_1,
            font: UIFont.owRegular(size: 12)
        )
        logoutIMLabel.set(
            textColor: theme.palette.label_main_1,
            font: UIFont.owRegular(size: 12)
        )
        
        sendRequestButton.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 15),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        createRightBarButton(target: self, selector: #selector(toQRCode), image: #imageLiteral(resourceName: "iconCommunicationQrcode"), toColor: theme.palette.application_main)
        self.blockUserSwitch.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
    }
    
    func changeUserInterface(purpose: Purpose) {
        switch purpose {
        case .myself:
            blockUserView.isHidden      = true
            logoutView.isHidden         = false
            sendRequestButton.isHidden  = true
//            editUserNameButton.isHidden = false
            break
        case .myFriend:
            blockUserView.isHidden      = false
            logoutView.isHidden         = true
            sendRequestButton.isHidden  = true
//            editUserNameButton.isHidden = true
            break
        case .notMyFriend:
            blockUserView.isHidden      = true
            logoutView.isHidden         = true
            sendRequestButton.isHidden  = false
//            editUserNameButton.isHidden = true
            break
        }
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.user_profile_title
        sendRequestButton.setTitle(dls.user_profile_button_add_friend, for: .normal)
        blockUserLabel.text = dls.user_profile_block_user
        logoutIMLabel.text = dls.user_profile_transfer_account
    }
    
    @objc func toQRCode() {
        guard let user = user else {
            #if Debug
            fatalError("user should not be nil.")
            #endif
            return
        }
        let vc = UserIMQRCodeViewController.instance(from: user)
        self.navigationController?.pushViewController(vc)
//        let vc = xib(vc: UserIMQRCodeViewController.self)
//        vc.config(constructor: user)
//        let screen = UIScreen.main.bounds
//        let width = screen.width * 0.9
//        let height = screen.height * 0.56
//        let form = vc.formSheetVC(
//            size: CGSize.init(width: width,
//                              height: height)
//        )
//
//        present(form, animated: true, completion: nil)
    }
    
    @IBAction func clickTransferButton(_ sender: UIButton) {
        setRecoverBag = DisposeBag()
        let alertController = UIAlertController(title: LM.dls.user_profile_alert_transfer_account_title, message: LM.dls.user_profile_alert_transfer_account_message, preferredStyle: .alert)
        alertController.addTextField { (textFiled) in
            textFiled.placeholder = LM.dls.user_profile_placeholder_transfer_account
        }
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_confirm, style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text, let id = IMUserManager.manager.userModel.value?.uID else { return }
            Server.instance.setRecoveryPassword(withIMUserId: id, recoveryPassword: text).asObservable().subscribe(onNext: {
                [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success: DLogDebug("set recovery key successful.")
                case .failed(error: let error):
                    DLogError(error)
                    EZToast.present(on: self, content: error.localizedDescription)
                }
            }).disposed(by: self.setRecoverBag)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showStep1AlertDialog() {
        let alertController = UIAlertController.init(title: LM.dls.add_friend_alert_title, message: LM.dls.add_friend_alert_message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = LM.dls.add_friend_placeholder_message
        })
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_confirm, style: .default, handler: { (action) in
            if let textFields = alertController.textFields, let textField = textFields.first, let text = textField.text {
                self.showStep2AlertDialog(rocketChatUID: self.user!.uid, welcomeMessage: text)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showStep2AlertDialog(rocketChatUID: String, welcomeMessage: String) {
        guard let myselfRocketChatUID = RocketChatManager.manager.rocketChatUser.value?.name else { return }
        IMUserManager.manager.inviteFriend(myselfRocketChatUID: myselfRocketChatUID, friendRocketChatUID: rocketChatUID, welcomeMessage: welcomeMessage).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success: self.showAlert(title: LM.dls.add_friend_alert_success, message: nil, completion: {  (_) in
//                self?.changeUserInterface(purpose: .myFriend)
            })
            case .failed(error: let error):
                EZToast.present(on: self, content: error.localizedDescription)
            }
        }).disposed(by: bag)
    }
}
