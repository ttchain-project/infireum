//
//  AddedFriendViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/23.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class InviteFriendViewController: KLModuleViewController, KLVMVC {

    @IBOutlet weak var userNameLabel: UILabel! {
        didSet { userNameLabel.text = nil }
    }
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.rx.text.orEmpty.skip(1).throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged().subscribe(onNext: {
                [unowned self] text in
                guard let uid = IMUserManager.manager.userModel.value?.uID, let _ = UUID(uuidString: text) else {
                    self.userImageView.image = nil
                    self.userNameLabel.text = nil
                    self.confirmButton.isEnabled = false
                    self.confirmButton.backgroundColor = UIColor.owSilver
                    return
                }
                self.searchUserBag = DisposeBag()
                Server.instance.searchUser(uid: uid, targetUid: text).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let value):
                        self.userImageView.image = value.imUser.headImg
                        self.userNameLabel.text = value.imUser.nickName
                        self.confirmButton.isEnabled = !(value.isFriend || value.isBlock)
                        self.confirmButton.backgroundColor = self.confirmButton.isEnabled ? UIColor.owAzure : UIColor.owSilver
                    case .failed(error: let error): EZToast.present(on: self, content: error.localizedDescription)
                    }
                }).disposed(by: self.searchUserBag)
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var qrcodeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton! {
        didSet {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor.owSilver
        }
    }
    
    typealias Constructor = Void
    var viewModel: InviteFriendViewModel!
    var bag: DisposeBag = DisposeBag()
    private var searchUserBag: DisposeBag = DisposeBag()
    private var inviteBag = DisposeBag()
    
    func config(constructor: Void) {
        viewModel = InviteFriendViewModel.init(input: InviteFriendViewModel.Input(), output: InviteFriendViewModel.Output())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        tabBarController?.tabBar.isHidden = true
        textField.text = String()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        qrcodeButton.rx.tap.asDriver().drive(onNext: { (button) in
            //
//            let viewController = OWQRCodeViewController()
//            viewController.navigationController?.navigationBar.backIndicatorImage = UIImage()
//            viewController.title = "掃碼"
////            viewController.scanningType
//            self.show(viewController, sender: self)
            
//            OWQRCodeViewController._Constructor.init(purpose: OWQRCodeViewController.Purpose.restoreIdentity, resultCallback: <#T##OWQRCodeViewController.ResultCallback##OWQRCodeViewController.ResultCallback##(OWStringValidator.ValidationResultType, OWQRCodeViewController.Purpose, OWQRCodeViewController.ScanningType) -> Void#>, isTypeLocked: <#T##Bool#>)
            let qrCode = OWQRCodeViewController.navInstance(from: OWQRCodeViewController._Constructor(
                purpose: .general(nil),
                resultCallback: { [weak self]
                    (result, purpose, scanningType) in
                    print(result)
                    print(purpose)
                    print(scanningType)
//                    switch result {
//                    case .identityQRCode(rawContent: let raw):
//
////                        self.qrCodeVCNav?.dismiss(animated: true, completion: {
////                            self?.startQRCodeDecryptionFlow(withRawContent: raw)
////                        })
//                    default: break
//                    }
                },
                isTypeLocked: true
            ))
            
//            qrCodeVCNav = qrCode
            self.present(qrCode, animated: true, completion: nil)
            
        }).disposed(by: bag)
        
        confirmButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { (button) in
                guard let text = self.textField.text else {
                    return
                }
                
                if text.count > 0 {
                    self.showStep1AlertDialog()
                }
            })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        textField.placeholder = lang.dls.add_friend_placeholder_friend_id
        title = lang.dls.add_friend_title
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bg_2)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 15))
        changeBackBarButton(toColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
    }
    func showStep1AlertDialog() {
        let alertController = UIAlertController.init(title: LM.dls.add_friend_alert_title, message: LM.dls.add_friend_alert_message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = LM.dls.add_friend_placeholder_message
        })
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.g_confirm, style: .default, handler: { (action) in
            if let textFields = alertController.textFields, let textField = textFields.first, let text = textField.text {
                self.showStep2AlertDialog(rocketChatUID: self.textField.text!, welcomeMessage: text)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    func showStep2AlertDialog(rocketChatUID: String, welcomeMessage: String) {
        guard let myselfRocketChatUID = RocketChatManager.manager.rocketChatUser.value?.name else { return }
        inviteBag = DisposeBag()
        IMUserManager.manager.inviteFriend(myselfRocketChatUID: myselfRocketChatUID, friendRocketChatUID: rocketChatUID, welcomeMessage: welcomeMessage).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success: self.showAlert(title: LM.dls.add_friend_alert_success, message: nil, completion: { [weak self] (_) in
                self?.navigationController?.popViewController()
            })
            case .failed(error: let error): EZToast.present(on: self, content: error.localizedDescription)
            }
        }).disposed(by: inviteBag)
    }
    
}