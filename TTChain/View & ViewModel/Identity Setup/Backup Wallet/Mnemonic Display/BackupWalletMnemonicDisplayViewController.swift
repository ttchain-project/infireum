//
//  BackupWalletMnemonicDisplayViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

enum MnemonicAuthSource {
    case createIdentity(IdentityCreateViewModel.CreateResult)
    case backupIdentity(String)
    
    var mnemonic: String {
        switch self {
        case .createIdentity(let r):
            return r.mnemonic
        case .backupIdentity(let mnemonic):
            return mnemonic
        }
    }
}

class BackupWalletMnemonicDisplayViewController: KLModuleViewController {
    var source: MnemonicAuthSource!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainNoteLabel: UILabel!
    @IBOutlet weak var mnemonicBase: UIView!
    @IBOutlet weak var mnemonicLabel: UILabel!
    
    @IBOutlet weak var nextStepBtn: UIButton!
    
    
    static func instance(source: MnemonicAuthSource) -> BackupWalletMnemonicDisplayViewController {
        let vc = xib(vc: self)
        vc.config(source: source)
        return vc
    }
    
    private func config(source: MnemonicAuthSource) {
        self.source = source
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
        changeBackBarButton(toColor: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"))
        titleLabel.set(
            textColor: theme.palette.label_main_1,
            font: .owMedium(size: 18)
        )
        
        mainNoteLabel.set(
            textColor: theme.palette.label_main_1,
            font: .owRegular(size: 14)
        )
        
        mnemonicBase.backgroundColor = theme.palette.specific(color: .owWhiteTwo)
        
        if let str = (mnemonicLabel.attributedText?.string ?? mnemonicLabel.text) {
            let style = NSMutableParagraphStyle.init()
            style.lineSpacing = 20
            
            let newAttr = NSAttributedString.init(
                string: str,
                attributes: [
                    NSAttributedStringKey.paragraphStyle : style,
                    NSAttributedStringKey.foregroundColor : theme.palette.label_main_1,
                    NSAttributedStringKey.font : UIFont.owRegular(size: 14)
                    ]
            )
            
            mnemonicLabel.attributedText = newAttr
        }
        
        nextStepBtn.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        titleLabel.text = dls.backupMnemonic_title
        mainNoteLabel.text = dls.backupMnemonic_desc
        let style = NSMutableParagraphStyle.init()
        style.lineSpacing = 20
        mnemonicLabel.attributedText = NSAttributedString.init(
            string: source.mnemonic,
            attributes: [
                NSAttributedStringKey.paragraphStyle : style,
                NSAttributedStringKey.foregroundColor : TM.palette.label_main_1,
                NSAttributedStringKey.font : UIFont.owRegular(size: 14)
            ]
        )
        if case .backupIdentity? = self.source {
            nextStepBtn.setTitleForAllStates(dls.g_copy)

        }else {
            nextStepBtn.setTitleForAllStates(dls.g_next)

        }
    }

    @IBAction func nextStep(_ sender: UIButton) {
        
        if case .backupIdentity? = self.source {
            UIPasteboard.general.string = self.source.mnemonic
            EZToast.present(on: self, content: LM.dls.copied_successfully)
        }else {
            let vc = BackupWalletMnemonicVerifyViewController.instance(source: source)
            navigationController?.pushViewController(vc)

        }
    }


}
