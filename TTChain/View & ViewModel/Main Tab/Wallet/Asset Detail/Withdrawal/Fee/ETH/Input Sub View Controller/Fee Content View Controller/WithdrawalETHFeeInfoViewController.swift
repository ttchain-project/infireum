//
//  WithdrawalETHFeeInfoViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class WithdrawalETHFeeInfoViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let defaultOptions: FeeManager.Option?
        let defaultGasPrice: Decimal?
        let defaultGas: Decimal?
    }
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalETHFeeInfoViewModel
    var viewModel: WithdrawalETHFeeInfoViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Config) {
        view.layoutIfNeeded()
        setupChildVCs()
        viewModel = ViewModel.init(
            input: WithdrawalETHFeeInfoViewModel.InputSource(
                systemGasProvider: quickModeVC.viewModel,
                advGasProvider: advModeVC.viewModel,
                feeDefault: WithdrawalETHFeeInfoViewModel.FeeDefaultInput(
                    defaultFeeManagerOption: constructor.defaultOptions,
                    defaultGasPrice: constructor.defaultGasPrice,
                    defaultGas: constructor.defaultGas
                ),
                typeSelectInput: modeSwitch.rx.isOn.asDriver().map {
                    $0 ? .manual : .system
                }
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private var quickModeVC: WithdrawalETHFeeInfoQuickModeViewController!
    private var advModeVC: WithdrawalETHFeeInfoAdvModeViewController!
    
    private func setupChildVCs() {
        quickModeVC = WithdrawalETHFeeInfoQuickModeViewController.instance()
        addChildViewController(quickModeVC)
        quickModeVC.didMove(toParentViewController: self)
        modeBase.addSubview(quickModeVC.view)
        constrain(quickModeVC.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
        
        advModeVC = WithdrawalETHFeeInfoAdvModeViewController.instance()
        addChildViewController(advModeVC)
        advModeVC.didMove(toParentViewController: self)
        modeBase.addSubview(advModeVC.view)
        constrain(advModeVC.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        modeLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 14)
        )
    }
    
    override func renderLang(_ lang: Lang) {
        modeLabel.text = lang.dls.withdrawal_label_advanced_mode
    }
    
    private func bindViewModel() {
        viewModel.mode.subscribe(onNext: {
            [unowned self] mode in
            switch mode {
            case .manual:
                self.quickModeVC.view.isHidden = true
                self.advModeVC.view.isHidden = false
            case .system:
                self.quickModeVC.view.isHidden = false
                self.advModeVC.view.isHidden = true
            }
        })
        .disposed(by: bag)
    }
    
    @IBOutlet weak var modeBase: UIView!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var modeLabel: UILabel!
    
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
