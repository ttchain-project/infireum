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
    @IBOutlet weak var qrCodeTapBase: UIView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeSepline: UIView!
    @IBOutlet weak var qrCodeDescLabel: UILabel!
    
    @IBOutlet weak var pKeyTapBase: UIView!
    @IBOutlet weak var pKeyLabel: UILabel!
    @IBOutlet weak var pKeySepline: UIView!
    @IBOutlet weak var pKeyDescLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindAction()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindAction() {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
}
