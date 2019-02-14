//
//  UserIMQRCodeViewController.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserIMQRCodeViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = UserQRCodeViewModel
    typealias Constructor = Config
    
    struct Config {
        let uid :String
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var uidCopyButton: UIButton!
    @IBOutlet weak var qrcodeBase: UIView! {
        didSet {
            qrcodeBase.addShadow(ofColor: .owBlack20,
                                 radius: 1,
                                 offset: CGSize.init(width: 2, height: 4),
                                 opacity: 1)

        }
    }
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: UserQRCodeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        doneButton.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self]
                _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
//        self.titleLabel.text = dls.exportPKey_tab_qrcode
        self.navigationItem.title = dls.myQRCode
        doneButton.setTitleForAllStates(dls.g_confirm)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        titleLabel.set(textColor: palette.label_main_2,
                       font: .owMedium(size: 18))
        titleView.backgroundColor = palette.nav_bg_clear

        doneButton.setPureText(color: palette.btn_bgFill_enable_text,
                               font: .owRegular(size: 14),
                               backgroundColor: palette.btn_bgFill_enable_bg)
    }
    
    func config(constructor: UserIMQRCodeViewController.Config) {
        view.layoutIfNeeded()
        let output = UserQRCodeViewModel.Output()
        viewModel = ViewModel.init(input: UserQRCodeViewModel.Input.init(uid:constructor.uid), output: output)
        viewModel.output.image.bind(to: qrCodeImageView.rx.image).disposed(by: bag)
        self.uidLabel.text = self.viewModel.uID.value        
        self.uidCopyButton.rx.tap.asDriver()
            .throttle(1)
            .drive(onNext: {
                [unowned self] in
                UIPasteboard.general.string = self.viewModel.uID.value
                self.view.makeToast(LM.dls.g_toast_addr_copied)
            })
            .disposed(by: bag)
    }
}
