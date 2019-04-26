//
//  LightWithdrawalAssetViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LightWithdrawalAssetViewController: KLModuleViewController,KLVMVC {
    var viewModel: WithdrawalAssetViewModel!
    
    @IBOutlet weak var transferAmountLabel: UILabel!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var transferAmtTextField: UITextField!
    @IBOutlet weak var transferAllButton: UIButton!
    
    typealias ViewModel = WithdrawalAssetViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let asset: Asset
        let fiat: Fiat
    }

    func config(constructor: LightWithdrawalAssetViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalAssetViewModel.InputSource(asset: constructor.asset, fiat: constructor.fiat, amtStrInout: transferAmtTextField.rx.text),
            output: ()
        )
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        transferAmtTextField.set(placeholder: dls.withdrawal_placeholder_withdrawalAmt)
        transferAmountLabel.text = dls.transfer_amount_title
        
    }
    
    override func renderTheme(_ theme: Theme) {
        
    }

}
