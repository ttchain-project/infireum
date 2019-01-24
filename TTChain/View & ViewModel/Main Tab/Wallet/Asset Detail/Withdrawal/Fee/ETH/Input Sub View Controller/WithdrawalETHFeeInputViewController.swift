//
//  WithdrawalBTCFeeInputViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class WithdrawalETHFeeInputViewController: KLModuleViewController, WithdrawalChildVC, KLVMVC, WithdrawalFeeViewControllerBase {
    struct Config {
        let fiat: Fiat
    }
    
    typealias FeeInfoProvider = ViewModel
    typealias Constructor = Config
    typealias ViewModel = WithdrawalETHFeeInputViewModel
    var viewModel: WithdrawalETHFeeInputViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Config) {
        view.layoutIfNeeded()
        configChildVC()
        viewModel = ViewModel.init(
            input: WithdrawalETHFeeInputViewModel.InputSource(
                fiat: constructor.fiat,
                feeInfoIsDisplayedInput: feeBtn.rx.tap.asDriver(),
                gasProvider: infoVC.viewModel
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return viewModel.isFeeInfoCompleted
    }
    
    @IBOutlet weak var headerBase: UIView!
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeBtn: UIButton!
    
    @IBOutlet weak var infoBase: UIView!
    private var infoVC: WithdrawalETHFeeInfoViewController!
    private func configChildVC() {
        infoVC = WithdrawalETHFeeInfoViewController.instance(
            from: WithdrawalETHFeeInfoViewController.Config(
                defaultOptions: .eth(.gasPrice(.suggest)),
                defaultGasPrice: FeeManager.getValue(fromOption: .eth(.gasPrice(.suggest))),
                defaultGas: FeeManager.getValue(fromOption: .eth(.gas))
            )
        )
        
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
        
        let feeStr = Observable.combineLatest(
            viewModel.input.gasProvider.totalGas,
            viewModel.totalGasFiatValue
            )
            .map {
                [unowned self]
                totalGas, totalFiat -> String in
                let gasStr = (totalGas?.gweiToEther.asString(digits: 18) ?? "--") + LM.dls.fee_ether
                let fiatSymbol = self.viewModel.input.fiat.fullSymbol
                let fiatStr = fiatSymbol + (totalFiat?.asString(digits: 2) ?? "--")
                return gasStr + " ≈ " + fiatStr
            }
        
        feeStr.subscribe(onNext: {
            [unowned self]
            text in
            self.feeBtn.set(image: nil, title: text, titlePosition: .left, additionalSpacing: 8, state: .normal)
        })
        .disposed(by: bag)
        
        
        viewModel.isInfoDisplayed
            .subscribe(onNext: {
                [unowned self]
                isDisplayed in
                let img = isDisplayed ? #imageLiteral(resourceName: "doneBlue") : #imageLiteral(resourceName: "arrowNavBlue")
                self.feeBtn.set(image: img,
                                title: nil,
                                titlePosition: .left,
                                additionalSpacing: 8,
                                state: .normal)
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
        feeTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        feeBtn.set(color: palette.label_main_1, font: UIFont.owRegular(size: 14))
        let isDisplayed = !infoBase.isHidden
        let img = isDisplayed ? #imageLiteral(resourceName: "doneBlue") : #imageLiteral(resourceName: "arrowNavBlue")
        self.feeBtn.set(image: img, title: nil, titlePosition: .left, additionalSpacing: 8, state: .normal)
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
