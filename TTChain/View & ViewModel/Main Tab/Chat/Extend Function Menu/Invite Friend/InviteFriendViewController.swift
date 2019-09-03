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
                self.searchUser(text: text)
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
    
    typealias Constructor = Config
    struct Config {
        let userId:String?
    }
    var viewModel: InviteFriendViewModel!
    var bag: DisposeBag = DisposeBag()
    private var searchUserBag: DisposeBag = DisposeBag()
    private var inviteBag = DisposeBag()
    
    func config(constructor: Config) {
        self.view.layoutIfNeeded()
        viewModel = InviteFriendViewModel.init(input: InviteFriendViewModel.Input(), output: InviteFriendViewModel.Output())
        if let userId = constructor.userId {
            self.textField.text = userId
            self.searchUser(text: userId)
        }
    }
    
    private func searchUser(text: String) {
        guard let uid = IMUserManager.manager.userModel.value?.uID, let _ = UUID(uuidString: text) else {
            userImageView.image = nil
            userNameLabel.text = nil
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor.owSilver
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
                self.confirmButton.backgroundColor = self.confirmButton.isEnabled ? UIColor.cloudBurst : UIColor.owSilver
            case .failed(error: let error): EZToast.present(on: self, content: error.descString)
            }
        }).disposed(by: searchUserBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        tabBarController?.tabBar.isHidden = true
        textField.text = String()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        qrcodeButton.rx.tap.asDriver().drive(onNext: { (button) in
            let qrCode = OWQRCodeViewController.navInstance(from: OWQRCodeViewController._Constructor(
                purpose: .userId,
                resultCallback: { [weak self]
                    (result, purpose, scanningType) in
                    print(result)
                    print(purpose)
                    print(scanningType)
                    switch result {
                    case .userId(let id):
                        self?.textField.text = id
                        self?.searchUser(text: id)
                    default: return
                    }
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
        self.navigationItem.title = lang.dls.add_friend_title
        self.titleLabel.text = lang.dls.account
        self.confirmButton.setTitle(lang.dls.g_confirm, for: .normal)
    }
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_2, barTint: theme.palette.nav_bar_tint)
        
        changeLeftBarButton(target: self, selector: #selector(popOrDismiss), tintColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"))
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
        guard let myselfRocketChatUID = RocketChatManager.manager.rocketChatUser.value?.name else {
            EZToast.present(on: self, content: LM.dls.g_something_went_wrong)
            return
        }
        inviteBag = DisposeBag()
        IMUserManager.manager.inviteFriend(myselfRocketChatUID: myselfRocketChatUID, friendRocketChatUID: rocketChatUID, welcomeMessage: welcomeMessage).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success: self.showAlert(title: LM.dls.add_friend_alert_success, message: nil, completion: { [weak self] (_) in
                self?.popOrDismiss()
            })
            case .failed(error: let error):
                switch error {
                case .incorrectResult(let code, let errorString):
                    if code == "9048" {
                        self.showSimplePopUp(with: "", contents: errorString, cancelTitle: LM.dls.g_cancel, cancelHandler: { (_) in
                            self.popOrDismiss()
                        })
                    }
                default:
                    EZToast.present(on: self, content: error.descString)
                }
            }
        }).disposed(by: inviteBag)
    }
    
    @objc func popOrDismiss() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popViewController()
        }else if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController()
        }
    }
}
