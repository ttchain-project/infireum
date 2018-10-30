//
//  WithdrawalCICFeeInfoQuickModeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalCICFeeInfoQuickModeViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var quickLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var gasPriceLabel: UILabel!
    
    typealias ViewModel = WithdrawalCICFeeInfoQuickModeViewModel
    var viewModel: WithdrawalCICFeeInfoQuickModeViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Config
    struct Config {
        let mainCoinID: String
    }
    func config(constructor: Constructor) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input:
            WithdrawalCICFeeInfoQuickModeViewModel.InputSource(
                mainCoinID: constructor.mainCoinID,
                defaultGasPrice: FeeManager.getValue(fromOption: .cic(.gasPrice(.suggest(mainCoinID: constructor.mainCoinID)))),
                maxGasPrice: FeeManager.getValue(fromOption: .cic(.gasPrice(.systemMax(mainCoinID: constructor.mainCoinID)))),
                minGasPrice: FeeManager.getValue(fromOption: .cic(.gasPrice(.systemMin(mainCoinID: constructor.mainCoinID)))),
                percentageUpdateInout: slider.rx.value
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
                $0.cicUnitToCIC
            }
            .map {
                $0.asString(digits: 9, force: true) + " " + LM.dls.fee_cic_per_byte
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
        slowLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
        quickLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
        gasPriceLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
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
