//
//  WithdrawalBTCFeeInputViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class WithdrawalBTCFeeInputViewController: KLModuleViewController, WithdrawalFeeChildVC, KLVMVC, WithdrawalFeeViewControllerBase {
    
    struct Config {
        let asset:Asset
    }
    typealias FeeInfoProvider = ViewModel
    typealias Constructor = Config
    typealias ViewModel = WithdrawalBTCFeeInputViewModel
    var viewModel: WithdrawalBTCFeeInputViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalBTCFeeInputViewModel.InputSource(
                feeInfoIsDisplayedInput: feeBtn.rx.tap.asDriver(),
                asset:constructor.asset
            ),
            output: ()
        )
        configChildVC()
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }

    
    var preferedHeight: CGFloat {
        return headerBase.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + self.infoVC.preferedHeight
    }
    
    var preferedDisclosedHeight:CGFloat {
        return headerBase.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return viewModel.satPerByte.map { $0 != nil }
    }
    
    @IBOutlet weak var headerBase: UIView!
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeBtn: UIButton!
    @IBOutlet weak var feeAmtLabel: UILabel!
    
    @IBOutlet weak var infoBase: UIView!
    private var infoVC: WithdrawalBTCFeeInfoViewController!
    private func configChildVC() {
        infoVC = WithdrawalBTCFeeInfoViewController.instance(from: WithdrawalBTCFeeInfoViewController.Config(
                defaultFeeOption: .btc(.regular),
                defaultFeeRate: nil
            )
        )
        
        
        infoVC.viewModel.satPerByte.subscribe(
            onNext: {
                [unowned self] in self.viewModel.updateFee(satPerByte: $0)
            }
        )
        .disposed(by: bag)
        
        infoVC.viewModel.selectedOption
            .subscribe(onNext: {
                [unowned self]
                option in
                switch option {
                case .manual:
                    self.viewModel.updateFeeOption(option: nil)
                case .priority:
                    self.viewModel.updateFeeOption(option: .btc(.priority))
                case .regular:
                    self.viewModel.updateFeeOption(option: .btc(.regular))
                }
            })
            .disposed(by: bag)
        
        
        addChildViewController(infoVC)
        infoVC.didMove(toParentViewController: self)
        infoBase.addSubview(infoVC.view)
        constrain(infoVC.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
    }
    
    private func bindViewModel() {
        viewModel.isInfoDisplayed.map { !$0 }.bind(to: infoBase.rx.isHidden).disposed(by: bag)
        
        let feeStr = viewModel.satPerByte
            .map {
                ($0?.asString(digits: 8) ?? "--") + " " + "btc"//LM.dls.fee_sat_per_byte
        }
        
        feeStr.bind(to: self.feeAmtLabel.rx.text).disposed(by: bag)
        
        self.viewModel.feeAmtFiatValue.subscribe(onNext: {
            [unowned self]
            text in
            self.feeBtn.set(image: nil, title: text, titlePosition: .left, additionalSpacing: 8, state: .normal)
        })
        .disposed(by: bag)
        
        
        viewModel.isInfoDisplayed
            .subscribe(onNext: {
                [unowned self]
                isDisplayed in
                let img = isDisplayed ? #imageLiteral(resourceName: "btn_close") :  #imageLiteral(resourceName: "btn_open")
                self.feeBtn.set(image: img, title: nil, titlePosition: .left, additionalSpacing: 8, state: .normal)
            })
            .disposed(by: bag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        feeTitleLabel.text = lang.dls.withdrawal_label_minerFee
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        headerBase.backgroundColor = palette.bgView_sub
        infoBase.backgroundColor = palette.bgView_sub
        feeTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 12))
        feeBtn.set(color: palette.application_main, font: UIFont.owRegular(size: 12))
        feeAmtLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 12))
        
        let isDisplayed = !infoBase.isHidden
        let img = isDisplayed ? #imageLiteral(resourceName: "btn_close") :  #imageLiteral(resourceName: "btn_open")
        self.feeBtn.set(image: img,
                        title: nil,
                        titlePosition: .left,
                        additionalSpacing: 8,
                        state: .normal)
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
