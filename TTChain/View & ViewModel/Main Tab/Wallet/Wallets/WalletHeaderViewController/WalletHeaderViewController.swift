//
//  WalletHeaderViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/13.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletHeaderViewController: KLModuleViewController, KLVMVC{
   
    var viewModel: WalletHeaderViewModel!
    
    func config(constructor: WalletHeaderViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: WalletHeaderViewModel.Input(fiatAmtValue: constructor.totalAssetFiatValue,fiatSource:constructor.fiatCurrency), output: ())
        self.manageAssetBtnAction = constructor.manageAsset
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        self.bindUI()
    }
    
    typealias ViewModel = WalletHeaderViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let totalAssetFiatValue:Observable<BehaviorRelay<Decimal?>>
        let fiatCurrency:Observable<Fiat>
        let manageAsset: (()->Void)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var manageAssetBtnAction : (()->Void)!
    
    @IBOutlet weak var totalAssetValueTitleLabel: UILabel!
    @IBOutlet weak var totalAssetValue: UILabel!
    @IBOutlet weak var fiatCurrencyLabel: UILabel!
    @IBOutlet weak var manageCoinButton: UIButton!
    
    
    override func renderLang(_ lang: Lang) {
        
        self.totalAssetValueTitleLabel.text = lang.dls.total_assets_title
        self.manageCoinButton.setTitle(lang.dls.asset_management_btn_title, for: .normal)
        
    }
    
    override func renderTheme(_ theme: Theme) {
        totalAssetValueTitleLabel.set(textColor: theme.palette.label_sub, font: .owRegular(size: 12))
        
         totalAssetValue.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 20))
        
         totalAssetValueTitleLabel.set(textColor: theme.palette.label_sub, font: .owRegular(size: 12))
        
        manageCoinButton.set(textColor: theme.palette.bg_fill_new, font: .owRegular(size: 14),  backgroundColor: .white)
    }
    
    func bindUI() {
        self.viewModel.input.fiatSource.map { $0.fullSymbol }.bind(to:self.fiatCurrencyLabel.rx.text).disposed(by:bag)
        
        self.viewModel.input.fiatAmtValue.flatMapLatest { $0 }.map { $0?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--" }.bind(to:self.totalAssetValue.rx.text).disposed(by:bag)
        
        self.manageCoinButton.rx.klrx_tap.drive(onNext:{[unowned self] in
            self.manageAssetBtnAction()
        }).disposed(by:bag)
    }
}
