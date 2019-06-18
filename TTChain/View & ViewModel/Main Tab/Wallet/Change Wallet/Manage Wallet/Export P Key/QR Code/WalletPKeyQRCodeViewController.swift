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
//        viewModel.pKeyQRCode.drive(qrCode.rx.image).disposed(by: bag)
        self.qrCode.createCrispQRCodeImage(from: QRCodeGenerator.generateQRCode(from: self.viewModel.input.privateKey)!)
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
        noteTitle_scan.text = "* " + dls.exportPKey_label_provide_scan_directly_only
        noteTitle_safeEnv.text = "* " +  dls.exportPKey_label_use_in_save_environment
        
        
        noteContent_scan.text = dls.exportPKey_label_provide_scan_directly_only_message
        noteContent_safeEnv.text = dls.exportPKey_label_use_in_save_environment_message
        
        displayBtn.setTitleForAllStates(dls.show_qr_code)
    }
    
    override func renderTheme(_ theme: Theme) {
        noteBase.backgroundColor = theme.palette.specific(color: .white)
        titleLabels.forEach { (label) in
            label.set(textColor: .bittersweet, font: .owMedium(size: 16))
        }
        
        contentLabels.forEach { (label) in
            label.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        }
        
        qrCodeShadowBase.addShadow(
            ofColor: theme.palette.specific(color: .owBlack20),
            radius: 1,
            offset: CGSize.init(width: 0, height: 1),
            opacity: 1
        )
        
        qrCodeBase.set(backgroundColor: theme.palette.bgView_main, borderInfo: (color: theme.palette.bgView_border, width: 1))
        qrCodeBase.cornerRadius = 5
        
        displayBtn.setPureText(
            color: theme.palette.label_sub,
            font: .owRegular(size: 10)
        )
    }
}
