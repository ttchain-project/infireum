//
//  ImportWalletTypeChooseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/18.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class ImportWalletTypeChooseViewController: KLModuleViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createWalletTapBase: UIView!
    @IBOutlet weak var createWalletLabel: UILabel!
    @IBOutlet weak var createWalletSepline: UIView!
    @IBOutlet weak var createWalletDescLabel: UILabel!
    
    @IBOutlet weak var qrCodeTapBase: UIView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeSepline: UIView!
    @IBOutlet weak var qrCodeDescLabel: UILabel!
    
    @IBOutlet weak var pKeyTapBase: UIView!
    @IBOutlet weak var pKeyLabel: UILabel!
    @IBOutlet weak var pKeySepline: UIView!
    @IBOutlet weak var pKeyDescLabel: UILabel!

    var hud:KLHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindAction()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindAction() {
        
        createWalletTapBase.rx.klrx_tap.drive(onNext : {
            [unowned self] in
            self.toCreateWalletOptions()
        }).disposed(by: bag)
        
        pKeyTapBase.rx.klrx_tap
            .drive(onNext: {
                [unowned self] in
                self.toUsingPkey()
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
        titleLabel.text = dls.importWallet_sourceChoose_label_title
        
        createWalletLabel.text = dls.create_new_wallet
        createWalletDescLabel.text = dls.create_new_wallet_desc
        
        qrCodeLabel.text = dls.importWallet_sourceChoose_label_use_identity_qrcode
        qrCodeDescLabel.text = dls.importWallet_sourceChoose_label_identity_qrcode_desc
        
        pKeyLabel.text = dls.importWallet_sourceChoose_label_use_pKey
        pKeyDescLabel.text = dls.importWallet_sourceChoose_label_user_pKey_desc
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_clear)
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil
        )
        
        titleLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 18))
        
        createWalletLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        createWalletDescLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12.5))
        createWalletSepline.backgroundColor = palette.sepline
        
        
        qrCodeLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        qrCodeDescLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12.5))
        qrCodeSepline.backgroundColor = palette.sepline
        
        pKeyLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        pKeyDescLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12.5))
        pKeySepline.backgroundColor = palette.sepline
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func toCreateWalletOptions() {
        let createBTCWallet = UIAlertAction.init(title: LM.dls.create_new_btc_wallet, style: .default) { (action) in
            self.createWallet(forChainType: .btc)
        }
        let createETHWallet = UIAlertAction.init(title: LM.dls.create_new_eth_wallet, style: .default) { (action) in
            self.createWallet(forChainType: .eth)
        }
        let cancelOption = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        let alertVC = UIAlertController.init(title: LM.dls.create_new_wallet, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(createBTCWallet)
        alertVC.addAction(createETHWallet)
        alertVC.addAction(cancelOption)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func toUsingQRCode() {
        presentQRCodeScannerVC()
    }
    
    private weak var qrCodeVCNav: UINavigationController?
    private func presentQRCodeScannerVC() {
        let qrCode = OWQRCodeViewController.navInstance(from: OWQRCodeViewController._Constructor(
            purpose: .restoreIdentity,
            resultCallback: { [weak self]
                (result, purpose, scanningType) in
                switch result {
                case .identityQRCode(rawContent: let raw):
                    self?.qrCodeVCNav?.dismiss(animated: true, completion: {
                        self?.startQRCodeDecryptionFlow(withRawContent: raw)
                    })
                default: break
                }
        },
            isTypeLocked: true
        ))
        
        qrCodeVCNav = qrCode
        present(qrCode, animated: true, completion: nil)
    }
    
    private var decryFlow: IdentityQRCodeDecryptionFlow?
    private var encryFlow: IdentityQRCodeEncryptionFlow?
    
    private func startQRCodeDecryptionFlow(withRawContent raw: String) {
        decryFlow = IdentityQRCodeDecryptionFlow.start(
            purpose: .importWallet,
            infoRawContent: raw,
            onViewController: self,
            onComplete: {
                [weak self]
                (result) in
                switch result {
                case .cancel, .importFailure: break
                case .importSucceed:
                    self?.notifyQRCodeUpdated()
                }
                
        })
    }
    
    private func notifyQRCodeUpdated() {
        encryFlow = IdentityQRCodeEncryptionFlow.start(
            launchType: .importWallet,
            identity: Identity.singleton!,
            onViewController: self,
            onComplete: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func toUsingPkey() {
        let vc = ImportChainTypeChooseViewController.instance()
        navigationController?.pushViewController(vc)
    }
    
    private func createWallet(forChainType chain:ChainType) {
        
        let predForWallet = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: chain.rawValue))
        guard let wallets = DB.instance.get(type: Wallet.self, predicate: predForWallet, sorts: nil) else {
            return
        }
        guard let wallet = wallets.filter ({ $0.isFromSystem }).first else {
            return
        }
        
        askUserInputPwdBeforeBackup(withHint: wallet.pwdHint)
            .subscribe(onSuccess: { [unowned self] (pwd) in
                let dls = LM.dls
                if wallet.isWalletPwd(rawPwd: pwd) {
                    guard let mnemonic = wallet.attemptDecryptMnemonic(withRawPwd: pwd) else {
                        self.showSimplePopUp(
                            with: dls.myIdentity_error_unable_to_decrypt_mnemonic,
                            contents: "",
                            cancelTitle: dls.g_confirm,
                            cancelHandler: nil
                        )
                        
                        return errorDebug(response: ())
                    }
                    self.startWalletCreation(forChain: chain, mnemonic: mnemonic, pwd: pwd, pwdHint: wallet.pwdHint!)
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
                title: dls.create_new_wallet,
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
    
    func startWalletCreation(forChain chain: ChainType, mnemonic:String, pwd:String, pwdHint:String) {
        self.hud = KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init( width: 100,height: 100)))
        
        self.hud?.startAnimating(inView: self.view)
        
        WalletCreator.createNewWallet(forChain: chain, mnemonic: mnemonic, pwd: pwd, pwdHint: pwdHint)
            .subscribe(onSuccess: { [unowned self] (status) in
                self.hud?.stopAnimating()
                OWRxNotificationCenter.instance.notifyWalletsImported()
                self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
    }
}
