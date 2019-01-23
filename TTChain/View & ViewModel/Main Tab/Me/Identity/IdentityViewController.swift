//
//  IdentityViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class IdentityViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let identity: Identity
    }
    
    typealias Constructor = Config
    typealias ViewModel = IdentityViewModel
    var viewModel: IdentityViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: IdentityViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: IdentityViewModel.InputSource(
                identity: constructor.identity,
                backupIdentityInput: backupBtn.rx.tap.asDriver(),
                clearIdentityInput: clearIdentityBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindViewModel() {
        viewModel.name.bind(to: nameContentLabel.rx.text).disposed(by: bag)
        viewModel.id.bind(to: idContentLabel.rx.text).disposed(by: bag)
        
        nameContentLabel.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.showEditNameAlert()
        })
        .disposed(by: bag)
        
        viewModel.onStartBackupIdentity.drive(onNext: {
            [unowned self] identity in
            self.backup(identity: identity)
        })
        .disposed(by: bag)
        
        viewModel.onStartClearIdentity.drive(onNext: {
            [unowned self] identity in
            self.clear(identity: identity)
        })
        .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.myIdentity_title
        nameTitleLabel.text = dls.myIdentity_label_name
        idTitleLabel.text = dls.myIdentity_label_identityID
        
        backupBtn.setTitleForAllStates(dls.myIdentity_btn_backup_identity)
        clearIdentityBtn.setTitleForAllStates(dls.myIdentity_btn_exit_current_identity)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        
        view.backgroundColor = palette.bgView_sub
        nameTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        idTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        
        nameContentLabel.set(textColor: palette.application_main, font: .owRegular(size: 17))
        idContentLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        
        backupBtn.set(color: palette.application_main, font: UIFont.owRegular(size: 17))
        clearIdentityBtn.set(color: palette.application_alert, font: UIFont.owRegular(size: 17))
    }
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameContentLabel: UILabel!
    
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var idContentLabel: UILabel!
    
    @IBOutlet weak var backupBtn: UIButton!
    @IBOutlet weak var clearIdentityBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - Route
    private func showEditNameAlert() {
        let palette = TM.palette
        let dls = LM.dls
        let alert = UIAlertController.init(
            title: dls.myIdentity_alert_changeName_title,
            message: dls.myIdentity_alert_changeName_content,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction.init(title: dls.g_cancel,
                                        style: .cancel,
                                        handler: nil)
        var textField: UITextField!
        let confirm = UIAlertAction.init(title: dls.g_confirm,
                                         style: .default) {
            [unowned self] (_) in
            if let name = textField.text, name.count > 0 {
                switch name.ow_isValidIdentityName {
                case .valid:
                    self.viewModel.updateName(to: name)
                case .incorrectFormat(desc: let desc):
                    self.showSimplePopUp(with: dls.myIdentity_error_name_invalid_format,
                                         contents: desc,
                                         cancelTitle: dls.g_cancel,
                                         cancelHandler: nil)
                }
            }
        }
        
        alert.addTextField { (tf) in
            tf.delegate = self
            tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
            tf.set(placeholder: dls.myIdentity_placeholder_changeName)
            textField = tf
            tf.rx.text
                .map {
                    text -> Bool in
                    if let _text = text {
                        return _text.count > 0 && _text.count <= 30
                    }else {
                        return false
                    }
                }
                .bind(to: confirm.rx.isEnabled)
                .disposed(by: self.bag)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    private func backup(identity: Identity) {
        //NOTE: As we need to check the pwd, but pwd is related to wallet.
        //      Since there's no pwd for identity now, must make sure that all
        //      the pwds are same, so we can guarantee that the system has no
        //      pwd-updating features yet.
        
        guard let wallets = identity.wallets?.array as? [Wallet] else {
            return
        }
        
        let systemWallets = wallets.filter { $0.isFromSystem }
        let pwdSet = Set.init(systemWallets.map { $0.ePwd! })
        guard pwdSet.count == 1 else { return }
        let sampleWallet = systemWallets[0]
        let pwdHintSet = Set.init(systemWallets.map { $0.pwdHint! })
        guard pwdHintSet.count == 1 else { return errorDebug(response: ()) }

        askUserInputPwdBeforeBackup(withHint: pwdHintSet.first)
            .subscribe(onSuccess: { [unowned self] (pwd) in
                let dls = LM.dls
                if sampleWallet.isWalletPwd(rawPwd: pwd) {
                    guard let mnemonic = systemWallets[0].attemptDecryptMnemonic(withRawPwd: pwd) else {
                        self.showSimplePopUp(
                            with: dls.myIdentity_error_unable_to_decrypt_mnemonic,
                            contents: "",
                            cancelTitle: dls.g_confirm,
                            cancelHandler: nil
                        )
                        
                        return errorDebug(response: ())
                    }
                    
                    self.toBackupIdetityMnemonicView(of: mnemonic)
                }else {
                    self.showSimplePopUp(
                        with: "",
                        contents: dls.myIdentity_error_pwd_is_wrong,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: nil
                    )
                }
            })
            .disposed(by: bag)
    }
    
    private func askUserInputPwdBeforeBackup(withHint hint: String?) -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_backup_identity_title,
                message: dls.myIdentity_alert_input_pwd_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .default) {
                (_) in
                if let pwd = textField.text, pwd.count > 0 {
                    handler(.success(pwd))
                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:(hint != nil) ? dls.qrCodeImport_alert_placeholder_pwd(hint!) : dls.myIdentity_placeholder_pwd)
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func toBackupIdetityMnemonicView(of mnemonic: String) {
        let vc = IdentityBackupTypeChooseViewController.navInstance(mnemonic: mnemonic)
        
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    private func clear(identity: Identity) {
        //NOTE: As we need to check the pwd, but pwd is related to wallet.
        //      Since there's no pwd for identity now, must make sure that all
        //      the pwds are same, so we can guarantee that the system has no change
        //      pwd features yet.
        
        guard let wallets = identity.wallets?.array as? [Wallet] else {
            return
        }
        
        let systemWallets = wallets.filter { $0.isFromSystem }
        let pwdSet = Set.init(systemWallets.map { $0.ePwd! })
        let pwdHintSet = Set.init(systemWallets.map { $0.pwdHint! })
        
        //Pwd count check is in here, if the check failed,
        //system might add some new pwd change feature in it,
        //so the logic in here should be modified.
        guard pwdSet.count == 1 else { return errorDebug(response: ()) }
        guard pwdHintSet.count == 1 else { return errorDebug(response: ()) }
        let sampleWallet = systemWallets[0]
        
        
        showClearIdentityNoteAlert()
            .flatMap { [unowned self] _ -> Single<String> in
                self.askUserInputPwdBeforeClear(withHint: pwdHintSet.first)
            }
            .subscribe(onSuccess: {
                [unowned self] (pwd) in
                if sampleWallet.isWalletPwd(rawPwd: pwd) {
                    self.clearIdentity(identity)
                }else {
                    let dls = LM.dls
                    self.showSimplePopUp(with: "",
                                         contents: dls.myIdentity_error_pwd_is_wrong,
                                         cancelTitle: dls.g_cancel,
                                         cancelHandler: nil)
                }
            })
            .disposed(by: bag)
        
    }
    
    private func showClearIdentityNoteAlert() -> Single<Bool> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_clearIdentity_title,
                message: dls.myIdentity_alert_clearIdentity_ensure_wallet_backup_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel) {
                (_) in
                //Just to terminate the sequence
                handler(.error(GTServerAPIError.apiReject))
            }
            
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .destructive) {
                (_) in
                handler(.success(true))
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func askUserInputPwdBeforeClear(withHint hint: String?) -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_clearIdentity_verify_pwd_title,
                message: dls.myIdentity_alert_clearIdentity_verify_pwd_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .destructive) {
                (_) in
                if let pwd = textField.text, pwd.count > 0 {
                    handler(.success(pwd))
                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:(hint != nil) ? dls.qrCodeImport_alert_placeholder_pwd(hint!) : dls.myIdentity_placeholder_pwd)
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private lazy var clearHUD: KLHUD = {
        let hud = KLHUD.init(
            type: KLHUD.HUDType.spinner,
            frame: CGRect.init(origin: .zero,
                               size: CGSize.init(width: 100, height: 100)),
            descText: LM.dls.myIdentity_hud_exiting
        )
        
        return hud
    }()
    
    private func clearIdentity(_ identity: Identity) {
        clearHUD.startAnimating(inView: self.view)
        identity.clear()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            [unowned self] in
            self.clearHUD.updateType(KLHUD.HUDType.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")),
                                     text: LM.dls.myIdentity_hud_exited)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                [unowned self] in
                self.clearHUD.stopAnimating()
                OWRxNotificationCenter.instance.notifyIdentityCleared()
                IMUserManager.manager.clearIMUser()

            })
        }
    }
    
}

extension IdentityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let finalText: String
        if let text = textField.text {
            finalText = (text as NSString).replacingCharacters(in: range, with: string)
        }else {
            finalText = string
        }
        
        return !finalText.hasPrefix(" ")
    }
}
