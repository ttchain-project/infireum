//
//  WalletPKeyQRCodeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletPKeyQRCodeViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var noteBase: UIView!
    @IBOutlet weak var noteTitle_scan: UILabel!
    @IBOutlet weak var noteContent_scan: UILabel!
    @IBOutlet weak var noteTitle_safeEnv: UILabel!
    @IBOutlet weak var noteContent_safeEnv: UILabel!
    
    private var titleLabels: [UILabel] {
        return [noteTitle_scan, noteTitle_safeEnv]
    }
    
    private var contentLabels: [UILabel] {
        return [noteContent_scan, noteContent_safeEnv]
    }
    
    @IBOutlet weak var qrCodeShadowBase: UIView!
    @IBOutlet weak var qrCodeBase: UIView!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var displayBtn: UIButton!
    
    typealias ViewModel = WalletPKeyQRCodeViewModel
    var viewModel: WalletPKeyQRCodeViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let wallet: Wallet
    }
    
    typealias Constructor = Config
    func config(constructor: WalletPKeyQRCodeViewController.Config) {
        view.layoutIfNeeded()
        
        let pKey = constructor.wallet.pKey
        viewModel = ViewModel.init(
            input: WalletPKeyQRCodeViewModel.InputSource(
                privateKey: pKey
            ),
            output: ()
        )
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
        bindView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        qrCode.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        viewModel.pKeyQRCode.drive(qrCode.rx.image).disposed(by: bag)
    }
    
    private func bindView() {
        qrCode.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.qrCode.isHidden = true
        })
        .disposed(by: bag)
        
        displayBtn.rx.tap.asDriver()
        .drive(
            onNext: {
                [unowned self] in
                self.qrCode.isHidden = false
            }
        )
        .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        noteTitle_scan.text = "僅供直接掃描"
        noteTitle_safeEnv.text = "在安全環境下使用"
        
        
        noteContent_scan.text = "二維碼禁止保存、截圖、以及拍照。僅供用戶在安全環境下直接掃描來方便的導入錢包"
        noteContent_safeEnv.text = "請在確保四周無人及無攝像頭的情況下使用。二維碼一旦被他人獲取將造成不可挽回的資產損失"
        
        displayBtn.setTitleForAllStates("顯示二維碼")
    }
    
    override func renderTheme(_ theme: Theme) {
        noteBase.backgroundColor = theme.palette.specific(color: .owPaleGrey)
        titleLabels.forEach { (label) in
            label.set(textColor: theme.palette.label_asAppMain, font: .owMedium(size: 12))
        }
        
        contentLabels.forEach { (label) in
            label.set(textColor: theme.palette.label_sub, font: .owRegular(size: 12))
        }
        
        qrCodeShadowBase.addShadow(
            ofColor: theme.palette.specific(color: .owBlack20),
            radius: 1,
            offset: CGSize.init(width: 0, height: 1),
            opacity: 1
        )
        
        qrCodeBase.set(backgroundColor: theme.palette.bgView_sub, borderInfo: (color: theme.palette.bgView_border, width: 1))
        qrCodeBase.cornerRadius = 5
        
        
        displayBtn.cornerRadius = 5
        displayBtn.setPureText(
            color: theme.palette.btn_bgFill_enable_text,
            font: .owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
    }
}
