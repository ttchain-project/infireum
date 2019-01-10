//
//  BackupWalletNoteViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class BackupWalletNoteViewController: KLModuleViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainNoteLabel: UILabel!
    @IBOutlet weak var subNoteLabel: UILabel!
    
    @IBOutlet weak var nextStepBtn: UIButton!
    
    var result: IdentityCreateViewModel.CreateResult!
    
    static func instance(source: IdentityCreateViewModel.CreateResult) -> BackupWalletNoteViewController {
        let vc = xib(vc: self)
        vc.config(source: source)
        return vc
    }
    
    private func config(source: IdentityCreateViewModel.CreateResult) {
        result = source
    }

    private func toMainTab() {
        let tab = xib(vc: MainTabBarViewController.self)
        present(tab, animated: true, completion: {
            IMUserManager.launch()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        titleLabel.text = dls.backupWallet_title
        mainNoteLabel.text = dls.backupWallet_label_mainNote
        subNoteLabel.text = dls.backupWallet_label_subNote
        //TODO: Change button title
        nextStepBtn.setTitleForAllStates(dls.qrCodeExport_btn_backup_qrcode)
    }
    
    override func renderTheme(_ theme: Theme) {
        title = nil
        changeLeftBarButtonToDismissToRoot(tintColor: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"))
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bg_1)
        
        titleLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 18))
        mainNoteLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 14))
        subNoteLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 14))
        nextStepBtn.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
    }
    
    @IBAction func nextStep(_ sender: UIButton) {
//        let vc = BackupWalletMnemonicDisplayViewController.instance(source: .createIdentity(result)
//        )
//        navigationController?.pushViewController(vc)
        
        self.createIdentity()
    }
    
    
    private var flow: IdentityQRCodeEncryptionFlow?
    private func startQRCodeBackupFlow() {
        flow = IdentityQRCodeEncryptionFlow.start(
            launchType: .create,
            identity: Identity.singleton!,
            onViewController: self,
            onComplete: { [weak self] _ in
                self?.toMainTab()
                self?.flow = nil
        })
    }

    
    private func createIdentity() {
        guard let id = Identity.create(mnemonic: result.mnemonic, name: result.name, pwd: result.pwd, hint: result.pwdHint) else {
            #if DEBUG
            fatalError()
            #else
            showSimplePopUp(with: LM.dls.sortMnemonic_error_create_user_fail,
                            contents: "",
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
            return
            #endif
        }
        
        let sources = result.walletsResource.map {
            res -> (address: String, pKey: String, mnenomic: String?, isFromSystem: Bool, name: String, pwd: String, pwdHint: String, chainType: ChainType, mainCoinID: String) in
            return (address: res.address,
                    pKey: res.pKey,
                    mnenomic: result.mnemonic,
                    isFromSystem: true,
                    name: Wallet.defaultName(ofMainCoin: res.mainCoin),
                    pwd: result.pwd,
                    pwdHint: result.pwdHint,
                    chainType: res.mainCoin.owChainType,
                    mainCoinID: res.mainCoin.walletMainCoinID!)
        }
        
        guard Wallet.create(identity: id, sources: sources) != nil else {
            #if DEBUG
            fatalError()
            #else
            showSimplePopUp(with: LM.dls.sortMnemonic_error_create_wallet_fail,
                            contents: "",
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
            return
            #endif
        }
        
        startQRCodeBackupFlow()
    }
}
