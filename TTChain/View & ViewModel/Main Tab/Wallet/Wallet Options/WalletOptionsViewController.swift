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
        self.view.setNeedsLayout()
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()

    }
    typealias Constructor = Void
    
    var bag: DisposeBag = DisposeBag.init()

 
//    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var btcTitleLabel: UILabel!
    @IBOutlet weak var btcView: UIView!
    @IBOutlet weak var btcAddressLabel: UILabel!
    @IBOutlet weak var btcValueLabel: UILabel!
    @IBOutlet weak var btcAddressCopy: UIButton!
    
    @IBOutlet weak var ethTitleLabel: UILabel!
    @IBOutlet weak var ethAddressLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    @IBOutlet weak var ethAddressCopy: UIButton!
    @IBOutlet weak var ethView: UIView!
    
//    @IBOutlet weak var rscSetting: UIImageView!
    @IBOutlet weak var rscTitleLabel: UILabel!
    @IBOutlet weak var rscAddressCopy: UIButton!
    @IBOutlet weak var rscAddressLabel: UILabel!
    @IBOutlet weak var rscValueLabel: UILabel!
    @IBOutlet weak var rscView: UIView!
    
//    @IBOutlet weak var airdropSetting: UIImageView!
    @IBOutlet weak var airdropView: UIView!
    @IBOutlet weak var airdropTitleLabel: UILabel!
    @IBOutlet weak var airdropAddressCopy: UIButton!
    @IBOutlet weak var airdropAddressLabel: UILabel!
    @IBOutlet weak var airdropValueLabel: UILabel!
    
//    @IBOutlet weak var titleLabel: UILabel!
    
//    @IBOutlet weak var btcButton: UIButton!
//    @IBOutlet weak var ethButton: UIButton!
//    @IBOutlet weak var rscButton: UIButton!
//    @IBOutlet weak var airdropButton: UIButton!

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
            self.rscAddressLabel.text = wallet?.address
            self.airdropAddressLabel.text = wallet?.address
        }).disposed(by: bag)
        
        let totalBTC = self.viewModel.totalFiatValuesBTC.flatMapLatest { $0 }.share()
        let totalETH = self.viewModel.totalFiatValuesETH.flatMapLatest { $0 }.share()
        let fiat = viewModel.fiat
        
        let totalRSC = self.viewModel.totalFiatValuesRSC.flatMapLatest { $0 }.share()
        let totalAirDrop = self.viewModel.totalFiatValuesAirDrop.flatMapLatest { $0 }.share()

        
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
        
//        Observable.combineLatest(totalBTC, totalETH)
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: {
//                 btc, eth in
//                let totalBTCValue = btc ?? 0
//                let totalETHValue = eth ?? 0
//                let total = totalBTCValue + totalETHValue
////                self.USDAmountLabel.text = total.asString(digits: 2)
//            })
//            .disposed(by: bag)
        
        Observable.combineLatest(totalRSC, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] t, f in
                self.rscValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)
        
        Observable.combineLatest(totalAirDrop, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] t, f in
                self.airdropValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)
        
        self.btcAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.btcWallet.value?.address)
        }).disposed(by: bag)
        self.ethAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        self.rscAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        self.airdropAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
//        btcView.rx.tapGesture().bind { _ in
//            self.toWalletDetail(withWallet: self.viewModel.btcWallet.value!, source: .BTC)
//        }.disposed(by: bag)
        
        btcView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            self.toWalletDetail(withWallet: self.viewModel.btcWallet.value!, source: .BTC)
        }).disposed(by: bag)
        
        ethView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            self.toWalletDetail(withWallet: self.viewModel.ethWallet.value!, source: .ETH)
        }).disposed(by: bag)
        

        rscView.rx.klrx_tap.asDriver().drive(onNext: {
            self.toWalletDetail(withWallet: self.viewModel.ethWallet.value!, source: .RSC)
            }).disposed(by: bag)
    
            airdropView.rx.klrx_tap.asDriver().drive(onNext: {
            self.toWalletDetail(withWallet: self.viewModel.ethWallet.value!, source:.AirDrop)
            }).disposed(by: bag)
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
    
    private func toWalletDetail(withWallet wallet: Wallet, source: MainWalletViewController.Source) {
        //        WalletFinder.markWallet(wallet)
        let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: wallet, source: source))
        //                self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        self.btcTitleLabel.backgroundColor = palette.application_main
        self.rscTitleLabel.backgroundColor = palette.application_main
        
        self.ethTitleLabel.backgroundColor = palette.application_alert
        self.airdropTitleLabel.backgroundColor = palette.application_alert
        
        self.btcAddressCopy.backgroundColor = palette.application_main
        self.ethAddressCopy.backgroundColor = palette.application_alert
        self.rscAddressCopy.backgroundColor = palette.application_main
        self.airdropAddressCopy.backgroundColor = palette.application_alert
        
        self.btcView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        self.view.setGradientColor()
    }
    override func renderLang(_ lang: Lang) {
        self.title = "TTChain"
        
        
    }
    @objc func doughnutTapped () {
        
    }
}
