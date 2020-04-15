//
//  WithdrawalConfirmETHFeeInfoViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class WithdrawalConfirmETHFeeInputViewController: KLModuleViewController, WithdrawalChildVC, KLVMVC, WithdrawalFeeViewControllerBase {
    struct Config {
        let defaultFeeManagerOption: FeeManager.Option?
        let defaultGasPrice: Decimal?
        let defaultGas: Decimal?
        let coin: Coin?
    }
    
    typealias FeeInfoProvider = ViewModel
    typealias Constructor = Config
    typealias ViewModel = WithdrawalConfirmETHFeeInputViewModel
    var viewModel: WithdrawalConfirmETHFeeInputViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    private lazy var completeBtn: UIButton = {
        let btn = createRightBarButton(target: self, selector: #selector(complete), size: CGSize.init(width: 50, height: 44))
        
        return btn
    }()
    
    func config(constructor: Config) {
        view.layoutIfNeeded()
        configChildVC(with: constructor)
        viewModel = ViewModel.init(
            input: WithdrawalConfirmETHFeeInputViewModel.InputSource(
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
    
    var onUpdateFeeInfo: ((FeeInfoProvider.FeeInfo) -> Void)?
    
    @IBOutlet weak var headerBase: UIView!
    @IBOutlet weak var feeTotalLabel: UILabel!
    @IBOutlet weak var feeDetailLabel: UILabel!
    
    @IBOutlet weak var infoBase: UIView!
    private var infoVC: WithdrawalETHFeeInfoViewController!
    private func configChildVC(with config: Config) {
        infoVC = WithdrawalETHFeeInfoViewController.instance(
            from: WithdrawalETHFeeInfoViewController.Config(
                defaultOptions: config.defaultFeeManagerOption,
                defaultGasPrice: config.defaultGasPrice,
                defaultGas: config.defaultGas,
                coin: config.coin
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

        viewModel.input.gasProvider.totalGas
            .map {
                $0?.gweiToEther.asString(digits: 9) ?? "--"
            }
            .map {
                $0 + " " + LM.dls.fee_ether
            }
            .bind(to: feeTotalLabel.rx.text)
            .disposed(by: bag)
        
        let gasStr = viewModel.gas.map {
                $0?.asString(digits: 0) ?? "--"
            }
        
        let gasPriceStr = viewModel.gasPrice.map {
            $0?.asString(digits: 2) ?? "--"
        }
        
        Observable.combineLatest(gasStr, gasPriceStr)
            .map {
                "= " + LM.dls.withdrawal_label_eth_fee_content($0, $1)
            }
            .bind(to: feeDetailLabel.rx.text)
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
        let dls = lang.dls
        completeBtn.setTitleForAllStates(dls.g_done)
        title = dls.withdrawalConfirm_changeFee_title
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        headerBase.backgroundColor = palette.bgView_main
        infoBase.backgroundColor = palette.bgView_main
        feeTotalLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 13))
        feeDetailLabel.set(textColor: palette.label_sub, font: UIFont.owRegular(size: 13))
        completeBtn.set(color: palette.application_main, font: UIFont.owRegular(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc private func complete() {
        if let info = viewModel.getFeeInfo() {
            onUpdateFeeInfo?(info)
        }
        
        pop(sender: nil)
    }
    
}
