//
//  IdentityBackupTypeChooseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/18.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class IdentityBackupTypeChooseViewController: KLModuleViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrCodeTapBase: UIView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeSepline: UIView!
    @IBOutlet weak var qrCodeDescLabel: UILabel!
    
    @IBOutlet weak var mneTapBase: UIView!
    @IBOutlet weak var mneLabel: UILabel!
    @IBOutlet weak var mneSepline: UIView!
    @IBOutlet weak var mneDescLabel: UILabel!
    
    static func instance(mnemonic: String?) ->  IdentityBackupTypeChooseViewController {
        let vc = xib(vc: IdentityBackupTypeChooseViewController.self)
        vc.config(mnemonic: mnemonic)
        
        return vc
    }
    
    static func navInstance(mnemonic: String?) -> UINavigationController {
        return UINavigationController.init(rootViewController: instance(mnemonic: mnemonic))
    }
    
    private(set) var mnemonic: String?
    private func config(mnemonic: String?) {
        self.mnemonic = mnemonic
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bindAction()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindAction() {
        mneTapBase.rx.klrx_tap
            .drive(onNext: {
                [unowned self] in
                self.toUsingMnemonic()
            })
            .disposed(by: bag)
        
        qrCodeTapBase.rx.klrx_tap
            .drive(onNext: {
                [unowned self] in
                self.toUsingQRCode()
            })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        titleLabel.text = dls.backupWallet_sourceChoose_label_title
        qrCodeLabel.text = dls.backupWallet_sourceChoose_label_use_identity_qrcode
        qrCodeDescLabel.text = dls.backupWallet_sourceChoose_label_identity_qrcode_desc
        
        mneLabel.text = dls.backupWallet_sourceChoose_label_use_mnemonic
        mneDescLabel.text = dls.backupWallet_sourceChoose_label_user_mnemonic_desc
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil
        )
        
        titleLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 18))
        qrCodeLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        qrCodeDescLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12.5))
        qrCodeSepline.backgroundColor = palette.sepline
        
        mneLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        mneDescLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12.5))
        mneSepline.backgroundColor = palette.sepline
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
    
    private func toUsingQRCode() {
        startQRCodeEncryptionFlow()
    }
    
    private var flow: IdentityQRCodeEncryptionFlow?
    private func startQRCodeEncryptionFlow() {
        flow = IdentityQRCodeEncryptionFlow.start(
            launchType: .backupIdentity,
            identity: Identity.singleton!,
            onViewController: self,
            onComplete: { _ in }
        )
    }
    
    private func toUsingMnemonic() {
        guard let mnemonic = self.mnemonic else {
            self.backup()
            return
        }
        let vc = BackupWalletMnemonicDisplayViewController.instance(source: .backupIdentity(mnemonic))
        
        navigationController?.pushViewController(vc)
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
                textField.isSecureTextEntry = true
                tf.rx.text
                    .map { $0?.count ?? 0 }
                    .map { $0 > 0 }
                    .bind(to: confirm.rx.isEnabled)
                    .disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func backup() {
          //NOTE: As we need to check the pwd, but pwd is related to wallet.
          //      Since there's no pwd for identity now, must make sure that all
          //      the pwds are same, so we can guarantee that the system has no
          //      pwd-updating features yet.
          guard let identity = Identity.singleton ,let wallets = identity.wallets?.array as? [Wallet] else {
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
                    self.mnemonic = mnemonic
                    self.toUsingMnemonic()
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
}

