//
//  WithdrawalCICFeeInfoAdvModeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalCICFeeInfoAdvModeViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasPriceLabel: UILabel!
    @IBOutlet weak var gasPriceSepline: UIView!
    @IBOutlet weak var gasTextField: UITextField!
    @IBOutlet weak var gasSepline: UIView!
    
    
    typealias Constructor = Void
    typealias ViewModel = WithdrawalCICFeeInfoAdvModeViewModel
    var viewModel: WithdrawalCICFeeInfoAdvModeViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Void) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalCICFeeInfoAdvModeViewModel.InputSource(
                gasPriceInout: gasPriceTextField.rx.text,
                gasInout: gasTextField.rx.text
            ),
            output: ()
        )
        
        gasPriceTextField.keyboardType = .numberPad
        gasTextField.keyboardType = .numberPad
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        gasPriceTextField.set(placeholder: dls.withdrawal_placeholder_eth_custom_gasPrice)
        gasTextField.set(placeholder: dls.withdrawal_placeholder_eth_custom_gas)
        gasPriceLabel.text = "cic"
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        gasPriceTextField.set(textColor: palette.input_text, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
        gasTextField.set(textColor: palette.input_text, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
        gasPriceLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        gasPriceSepline.backgroundColor = palette.sepline
        gasSepline.backgroundColor = palette.sepline
    }
    
    //    private func bindViewModel() {
    //
    //    }
    
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
