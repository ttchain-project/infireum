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
    
    static func instance(mnemonic: String) ->  IdentityBackupTypeChooseViewController {
        let vc = xib(vc: IdentityBackupTypeChooseViewController.self)
        vc.config(mnemonic: mnemonic)
        
        return vc
    }
    
    static func navInstance(mnemonic: String) -> UINavigationController {
        return UINavigationController.init(rootViewController: instance(mnemonic: mnemonic))
    }
    
    private(set) var mnemonic: String!
    private func config(mnemonic: String) {
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
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bar_tint)
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil
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
        let vc = BackupWalletMnemonicDisplayViewController.instance(source: .backupIdentity(mnemonic))
        
        navigationController?.pushViewController(vc)
    }
}

