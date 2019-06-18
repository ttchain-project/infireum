//
//  WalletPrivateKeyInfoViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletPrivateKeyInfoViewController: KLModuleViewController, KLVMVC {

    @IBOutlet weak var noteTitle_offlineSave: UILabel!
    @IBOutlet weak var noteContent_offlineSave: UILabel!
    @IBOutlet weak var noteTitle_userInternet: UILabel!
    @IBOutlet weak var noteContent_userInternet: UILabel!
    @IBOutlet weak var noteTitle_tools: UILabel!
    @IBOutlet weak var noteContent_tools: UILabel!
    
    private var titleLabels: [UILabel] {
        return [noteTitle_tools, noteTitle_offlineSave, noteTitle_userInternet]
    }
    
    private var contentLabels: [UILabel] {
        return [noteContent_tools, noteContent_offlineSave, noteContent_userInternet]
    }
    
    @IBOutlet weak var pKeyBase: UIView!
    @IBOutlet weak var pKeyLabel: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var showPvtKeyBtn: UIButton!
    
    typealias ViewModel = WalletPrivateKeyInfoViewModel
    var viewModel: WalletPrivateKeyInfoViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let wallet: Wallet
    }
    
    typealias Constructor = Config
    func config(constructor: WalletPrivateKeyInfoViewController.Config) {
        view.layoutIfNeeded()
        
        let pKey = constructor.wallet.pKey
        viewModel = ViewModel.init(
            input: WalletPrivateKeyInfoViewModel.InputSource(
                privateKey: pKey,
                copyPKeyInput: copyBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        self.pKeyLabel.isHidden = true
        self.copyBtn.isHidden = true
        
        viewModel.pKey.drive(pKeyLabel.rx.text).disposed(by: bag)
        viewModel.addressCopied.drive(onNext: {
            [unowned self] _ in
            EZToast.present(on: self, content: LM.dls.copied_successfully)
        })
            .disposed(by: bag)
       
        showPvtKeyBtn.rx.klrx_tap.drive(onNext:{
            self.pKeyLabel.isHidden = false
            self.copyBtn.isHidden = false
            self.showPvtKeyBtn.isHidden = true
        }).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        noteTitle_offlineSave.text = "* " + dls.exportPKey_label_offline_save
        noteTitle_userInternet.text = "* " +  dls.exportPKey_label_dont_trans_by_internet
        noteTitle_tools.text =   "* " + dls.exportPKey_label_pwd_manage_tool_save
        
        noteContent_offlineSave.text = dls.exportPKey_label_offline_save_message
        noteContent_userInternet.text = dls.exportPKey_label_dont_trans_by_internet_message
        noteContent_tools.text = dls.exportPKey_label_pwd_manage_tool_save_message
        
        showPvtKeyBtn.setTitleForAllStates(dls.display_pvt_key_btn_title)
    }
    
    override func renderTheme(_ theme: Theme) {
        titleLabels.forEach { (label) in
            label.set(textColor: .bittersweet, font: .owMedium(size: 16))
        }
        
        contentLabels.forEach { (label) in
            label.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        }
        
        pKeyBase.set(backgroundColor: theme.palette.bgView_main, borderInfo: (color: theme.palette.bgView_border, width: 1))
        pKeyBase.cornerRadius = 5
        
        pKeyLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 10))
        
        copyBtn.cornerRadius = 25
        copyBtn.backgroundColor = UIColor.init(hexString: "F7BE73")
        showPvtKeyBtn.setPureText(color: theme.palette.label_sub, font: .owRegular(size: 10))
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
