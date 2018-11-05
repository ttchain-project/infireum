//
//  WalletOptionsViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/10/29.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletOptionsViewController:KLModuleViewController, KLVMVC {
    var viewModel: WalletOptionsViewModel!
    
    typealias ViewModel = WalletOptionsViewModel

    func config(constructor: Void) {
        
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()

    }
    typealias Constructor = Void
    
    var bag: DisposeBag = DisposeBag.init()

    @IBOutlet weak var USDAmountLabel: UILabel!
 
//    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var btcAddressLabel: UILabel!
    @IBOutlet weak var btcValueLabel: UILabel!
    @IBOutlet weak var btcSetting: UIImageView!
    @IBOutlet weak var btcAddressCopy: UIImageView!
    
    @IBOutlet weak var ethAddressLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    @IBOutlet weak var ethSetting: UIImageView!
    @IBOutlet weak var ethAddressCopy: UIImageView!
    
    @IBOutlet weak var rscSetting: UIImageView!
    @IBOutlet weak var rscAddressCopy: UIImageView!
    @IBOutlet weak var rscAddressLabel: UILabel!
    @IBOutlet weak var rscValueLabel: UILabel!
   
    @IBOutlet weak var airdropSetting: UIImageView!
    @IBOutlet weak var airdropAddressCopy: NSLayoutConstraint!
    @IBOutlet weak var airdropAddressLabel: UILabel!
    @IBOutlet weak var airdropValueLabel: UILabel!
    
//    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var btcButton: UIButton!
    @IBOutlet weak var ethButton: UIButton!
    @IBOutlet weak var rscButton: UIButton!
    @IBOutlet weak var airdropButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let navBar = self.navigationController?.navigationBar else {
//            return
//        }
        self.viewModel = WalletOptionsViewModel.init(input: (), output: ())
//        navBar.setBackgroundImage(UIImage(), for: .default)
//        navBar.shadowImage = UIImage()
//        navBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func bindViewModel() {
        self.viewModel.btcWallet.subscribe(onNext: { (wallet) in
            self.btcAddressLabel.text = wallet?.address
            
        }).disposed(by: bag)
        
        self.viewModel.ethWallet.subscribe(onNext: { (wallet) in
            self.ethAddressLabel.text = wallet?.address
        }).disposed(by: bag)
        
        let totalBTC = self.viewModel.totalFiatValuesBTC.flatMapLatest { $0 }.share()
        let totalETH = self.viewModel.totalFiatValuesETH.flatMapLatest { $0 }.share()
        let fiat = viewModel.fiat
        
        Observable.combineLatest(totalBTC, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] t, f in
                self.btcValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)

        Observable.combineLatest(totalETH, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] t, f in
                self.ethValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)
        
        Observable.combineLatest(totalBTC, totalETH)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] btc, eth in
                let totalBTCValue = btc ?? 0
                let totalETHValue = eth ?? 0
                let total = totalBTCValue + totalETHValue
                self.USDAmountLabel.text = total.asString(digits: 2)
            })
            .disposed(by: bag)
        
        self.btcAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.btcWallet.value?.address)
        }).disposed(by: bag)
        self.ethAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        btcButton.rx.tap.bind {
            self.toWalletDetail(withWallet: self.viewModel.btcWallet.value!)
        }.disposed(by: bag)
        ethButton.rx.tap.bind {
            self.toWalletDetail(withWallet: self.viewModel.ethWallet.value!)
        }.disposed(by: bag)
    }

    func updateValue(for fiat:Fiat?, total:Decimal?) -> String{
        var value = ""
        if let f = fiat {
            let symbol = f.fullSymbol
            
            if let t = total {
                value = symbol + t.asString(digits: 2).disguiseIfNeeded()
            }else {
                value = symbol + "--"
            }
        }
        return value
    }
    
    private func handleAddressCopied(address: String?) {
        guard let address = address else {
            return
        }
        UIPasteboard.general.string = address
        EZToast.present(on: self,
                        content: LM.dls.g_toast_addr_copied)
    }
    
    private func toWalletDetail(withWallet wallet: Wallet) {
//        WalletFinder.markWallet(wallet)
        let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: wallet))
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        setDoughnutMenuButton()
    }
    override func renderLang(_ lang: Lang) {
        self.title = "TTChain"
    }
    @objc func doughnutTapped () {
        
    }
}
