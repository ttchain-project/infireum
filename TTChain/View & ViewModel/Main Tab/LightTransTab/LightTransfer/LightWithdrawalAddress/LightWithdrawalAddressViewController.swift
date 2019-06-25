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
        let toAddressCoinID:String
    }
    
    func config(constructor: LightWithdrawalAddressViewController.Config) {
        view.layoutIfNeeded()

        viewModel = ViewModel.init(
            input: WithdrawalAddressViewModel.InputSource(asset: constructor.asset, toAddressInout: toAddressTextField.rx.text, toAddressCoinId: constructor.toAddressCoinID),
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
    
    lazy var onTapChangeToAddress: Driver<Void> = {
        return addrbookBtn.rx.tap.asDriver()
    }()
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        toAddressTitleLabel.text = dls.withdrawal_label_toAddr
        addrbookBtn.set(image: #imageLiteral(resourceName: "arrowNavGrey"),
                        title: dls.withdrawal_btn_common_used_addr,
                        titlePosition: .left,
                        additionalSpacing: 4,
                        state: .normal)

        toAddressTextField.set(placeholder: dls.light_withdrawal_placeholder_toAddr)
        
        fromAddressTitleLabel.text = dls.withdrawal_label_fromAddr
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        
        toAddressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        addrbookBtn.set(textColor: palette.nav_bg_1, font: UIFont.owRegular(size: 14),backgroundColor:.summerSky)
        addrbookBtn.tintColor = .white
        addrbookBtn.cornerRadius = addrbookBtn.height/2
        toAddressTextField.set(textColor: palette.input_text, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
        
        fromAddressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        fromAddressLabel.set(textColor: palette.input_text, font: .owRegular(size: 14))
        fromAddressLabel.sizeToFit()
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
