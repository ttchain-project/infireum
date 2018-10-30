//
//  BackupWalletMnemonicVerifyViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import Cartography

class BackupWalletMnemonicVerifyViewController: KLModuleViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainNoteLabel: UILabel!
    @IBOutlet weak var targetBase: UIView!
    @IBOutlet weak var targetBaseHeight: NSLayoutConstraint!
    
    fileprivate lazy var targetVC: OWMnemonicViewController = {
        let vc = OWMnemonicViewController.instance(
            from: OWMnemonicViewController.Setup(
                targetMnemonic: source.mnemonic,
                sourceMnemonic: "",
                delete: { (word) in
                    self.sourceVC.insert(word: word)
                },
                match: {
                    [unowned self]
                    isMatch in
                    self.isMatched = isMatch ?? false
                },
                requiredHeight: { [unowned self] (height) in
                    self.targetBaseHeight.constant = height
                    self.view.layoutIfNeeded()
                },
                empty: nil
            )
        )
        
        return vc
    }()
        
    @IBOutlet weak var sourceBase: UIView!
    @IBOutlet weak var sourceBaseHeight: NSLayoutConstraint!
    
    fileprivate lazy var sourceVC: OWMnemonicViewController = {
        let vc = OWMnemonicViewController.instance(
            from: OWMnemonicViewController.Setup(
                targetMnemonic: source.mnemonic,
                sourceMnemonic: MnemonicHelper.random(source: source.mnemonic),
                delete: { [unowned self] (word) in
                    self.targetVC.insert(word: word)
                },
                match: nil,
                requiredHeight: { [unowned self] (height) in
                    self.sourceBaseHeight.constant = height
                    self.view.layoutIfNeeded()
                },
                empty: {
                    [unowned self]
                    isEmpty in
                    self.handleSourceClear(isEmpty: isEmpty)
                }
            )
        )
        
        return vc
    }()
    
    @IBOutlet weak var completeBtn: UIButton!
    
    static func instance(source: MnemonicAuthSource) -> BackupWalletMnemonicVerifyViewController {
        let vc = xib(vc: self)
        vc.config(source: source)
        return vc
    }
    
    
    fileprivate var source: MnemonicAuthSource!
    fileprivate var isMatched: Bool = false
    
    private func config(source: MnemonicAuthSource) {
        view.layoutIfNeeded()
        self.source = source
        
        setupTarget()
        setupSource()
    }
    
    private func setupSource() {
        addChildViewController(sourceVC)
        sourceBase.addSubview(sourceVC.view)
        sourceVC.didMove(toParentViewController: self)
        constrain(sourceVC.view) { (v) in
            let s = v.superview!
            v.top == s.top
            v.bottom == s.bottom
            v.leading == s.leading
            v.trailing == s.trailing
        }
    }
    
    private func setupTarget() {
        addChildViewController(targetVC)
        targetBase.addSubview(targetVC.view)
        targetVC.didMove(toParentViewController: self)
        constrain(targetVC.view) { (v) in
            let s = v.superview!
            v.top == s.top
            v.bottom == s.bottom
            v.leading == s.leading
            v.trailing == s.trailing
        }
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
    
    override func renderTheme(_ theme: Theme) {
        title = nil
        changeBackBarButton(toColor: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"))
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bg_1)
        titleLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 18))
        mainNoteLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        handleSourceClear(isEmpty: false)
        targetBase.backgroundColor = theme.palette.bgView_sub
        
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        titleLabel.text = dls.sortMnemonic_title
        mainNoteLabel.text = dls.sortMnemonic_desc
        completeBtn.setTitleForAllStates(dls.g_done)
    }
    
    private func handleSourceClear(isEmpty: Bool) {
        completeBtn.isEnabled = isEmpty
        
        if isEmpty {
            completeBtn.set(
                textColor: TM.palette.btn_bgFill_enable_text,
                font: UIFont.owRegular(size: 14),
                backgroundColor: TM.palette.btn_bgFill_enable_bg
            )
        }else {
            completeBtn.set(
                textColor: TM.palette.btn_bgFill_disable_text,
                font: UIFont.owRegular(size: 14),
                backgroundColor: TM.palette.btn_bgFill_disable_bg
            )
        }
    }
    
    
    @IBAction func complete(_ sender: UIButton) {
        guard isMatched else {
            showSimplePopUp(with: "",
                            contents: LM.dls.sortMnemonic_error_mnemonic_wrong_order,
                            cancelTitle: LM.dls.g_ok,
                            cancelHandler: nil)
            return
        }
        
        switch source! {
        case .backupIdentity:
            popToRoot(sender: nil)
        case .createIdentity(let source):
            guard let id = Identity.create(mnemonic: source.mnemonic, name: source.name, pwd: source.pwd, hint: source.pwdHint) else {
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
            
            let sources = source.walletsResource.map {
                res -> (address: String, pKey: String, mnenomic: String?, isFromSystem: Bool, name: String, pwd: String, pwdHint: String, chainType: ChainType, mainCoinID: String) in
                return (address: res.address,
                        pKey: res.pKey,
                        mnenomic: source.mnemonic,
                        isFromSystem: true,
                        name: Wallet.defaultName(ofMainCoin: res.mainCoin),
                        pwd: source.pwd,
                        pwdHint: source.pwdHint,
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
    
    private func toMainTab() {
        let tab = xib(vc: MainTabBarViewController.self)
        present(tab, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - QRCode Backup Flow
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
}


extension BackupWalletMnemonicVerifyViewController {
    
}
