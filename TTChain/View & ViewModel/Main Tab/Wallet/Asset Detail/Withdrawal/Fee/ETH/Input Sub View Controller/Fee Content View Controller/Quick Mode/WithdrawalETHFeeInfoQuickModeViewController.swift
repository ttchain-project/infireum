//
//  WithdrawalETHFeeInfoQuickModeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalETHFeeInfoQuickModeViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var quickLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var gasPriceLabel: UILabel!
    
    typealias ViewModel = WithdrawalETHFeeInfoQuickModeViewModel
    var viewModel: WithdrawalETHFeeInfoQuickModeViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let coin: Coin?
    }
    typealias Constructor = Config
    func config(constructor: Constructor) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input:
            WithdrawalETHFeeInfoQuickModeViewModel.InputSource(
                defaultGasPrice: FeeManager.getValue(fromOption: .eth(.gasPrice(.suggest))),
                maxGasPrice: FeeManager.getValue(fromOption: .eth(.gasPrice(.systemMax))),
                minGasPrice: FeeManager.getValue(fromOption: .eth(.gasPrice(.systemMin))),
                percentageUpdateInout: slider.rx.value,
                coin: constructor.coin
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindViewModel() {
        viewModel.gasPrice
            .map {
                $0.asString(digits: 2, force: true) + " " + LM.dls.fee_eth_gwei
        }
        .bind(to: gasPriceLabel.rx.text)
        .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        slowLabel.text = lang.dls.withdrawal_label_slow
        quickLabel.text = lang.dls.withdrawal_label_fast
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        slowLabel.set(textColor: palette.label_sub, font: .owMedium(size: 12))
        quickLabel.set(textColor: palette.label_sub, font: .owMedium(size: 12))
        gasPriceLabel.set(textColor: palette.label_sub, font: .owMedium(size: 12))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    
}
