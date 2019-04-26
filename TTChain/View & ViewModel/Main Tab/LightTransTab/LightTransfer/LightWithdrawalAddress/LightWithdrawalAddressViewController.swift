//
//  LightWithdrawalAddressViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightWithdrawalAddressViewController: KLModuleViewController,KLVMVC {
    var viewModel: WithdrawalAddressViewModel!
    
    typealias ViewModel = WithdrawalAddressViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let asset: Asset
    }
    
    func config(constructor: LightWithdrawalAddressViewController.Config) {
        view.layoutIfNeeded()

        viewModel = ViewModel.init(
            input: WithdrawalAddressViewModel.InputSource(asset: constructor.asset, toAddressInout: toAddressTextField.rx.text),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        
        bindViewModel()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return viewModel.hasValidInfo
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        toAddressTitleLabel.text = dls.withdrawal_label_toAddr
        addrbookBtn.set(image: #imageLiteral(resourceName: "arrowNavGrey"),
                        title: dls.withdrawal_btn_common_used_addr,
                        titlePosition: .left,
                        additionalSpacing: 8,
                        state: .normal)

        toAddressTextField.set(placeholder: dls.withdrawal_placeholder_toAddr)
        
        fromAddressTitleLabel.text = dls.withdrawal_label_fromAddr
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        
        toAddressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        addrbookBtn.set(color: palette.label_main_2, font: UIFont.owRegular(size: 14))
        addrbookBtn.cornerRadius = addrbookBtn.height/2
        toAddressTextField.set(textColor: palette.input_text, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
        
        fromAddressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        fromAddressLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
    }
    
    @IBOutlet weak var toAddressTitleLabel: UILabel!
    @IBOutlet weak var toAddressTextField: UITextField!
    @IBOutlet weak var addrbookBtn:UIButton!
    @IBOutlet weak var fromAddressTitleLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    func bindViewModel() {
        viewModel.fromAsset.map { $0.wallet!.address! }.bind(to: fromAddressLabel.rx.text).disposed(by: bag)
    }
    
    
}
