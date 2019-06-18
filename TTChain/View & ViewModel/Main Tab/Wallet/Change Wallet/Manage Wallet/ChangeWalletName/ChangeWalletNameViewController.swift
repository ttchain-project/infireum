//
//  ChangeWalletNameViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/18.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangeWalletNameViewController: KLModuleViewController,KLVMVC {
    var viewModel: ChangeWalletNameViewModel!
    var bag: DisposeBag = DisposeBag()
    typealias ViewModel = ChangeWalletNameViewModel
    func config(constructor: ChangeWalletNameViewController.Constructor) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: ChangeWalletNameViewModel.InputSource(wallet: constructor.wallet), output: ChangeWalletNameViewModel.OutputSource())
        self.action = constructor.action
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        self.viewModel.messageSubject.bind(to: rx.message).disposed(by: viewModel.bag)
        self.bindUI()
    }
    typealias Constructor = Config
    
    struct Config {
        let wallet:Wallet
        let action:((Wallet?)-> Void)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var walletTitleLabel: UILabel!
    @IBOutlet weak var walletNameTextField: KLTextField!
    var action:((Wallet?)-> Void)!

    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var confirmButton:UIButton!
    
    override func renderLang(_ lang: Lang) {
        self.walletTitleLabel.text = lang.dls.strValidate_field_walletName + self.viewModel.walletType()
        self.walletNameTextField.text = self.viewModel.input.wallet.name
        self.walletNameTextField.placeholder = lang.dls.walletManage_alert_placeholder_walletName_char_range
        self.navigationItem.title = lang.dls.walletManage_alert_changeWalletName_title
        self.cancelButton.setTitleForAllStates(lang.dls.g_cancel)
        self.confirmButton.setTitleForAllStates(lang.dls.g_confirm)
    }
    
    override func renderTheme(_ theme: Theme) {
        self.renderNavBar(tint: theme.palette.nav_bg_1, barTint: theme.palette.nav_bar_tint)
        self.renderNavTitle(color: theme.palette.nav_item_1, font: .owMedium(size: 20))
        self.walletTitleLabel.textColor = .yellowGreen
        self.walletNameTextField.textColor = .cloudBurst
    }
    
    func bindUI() {
        self.walletNameTextField.rx.text.map {
            $0 != nil
            }.bind(to: self.confirmButton.rx.isEnabled).disposed(by: bag)
        
        self.confirmButton.isEnabled = false
        self.cancelButton.rx.klrx_tap.drive(onNext:{
            self.action(nil)
        }).disposed(by: bag)
        
        self.confirmButton.rx.klrx_tap.drive(onNext:{
             self.viewModel.updateWalletName(name:self.walletNameTextField.text!)
        }).disposed(by: bag)
        
        self.viewModel.walletNameUpdated.subscribe(onNext: { _ in
            self.showSimplePopUp(with: LM.dls.walletManage_alert_wallet_name_changed_title, contents: LM.dls.walletManage_alert_wallet_name_changed_message, cancelTitle: LM.dls.g_cancel
                , cancelHandler: {[unowned self] _ in
                    self.action(self.viewModel.input.wallet)
            })
        }).disposed(by: bag)
    }

}

