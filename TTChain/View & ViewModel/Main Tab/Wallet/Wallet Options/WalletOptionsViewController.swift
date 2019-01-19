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
    @IBOutlet weak var stableCoinTitleLabel: UILabel!
    @IBOutlet weak var stableCoinAddressCopy: UIButton!
    @IBOutlet weak var stableCoinAddressLabel: UILabel!
    @IBOutlet weak var stableCoinValueLabel: UILabel!
    @IBOutlet weak var stableCoinView: UIView!
    
//    @IBOutlet weak var airdropSetting: UIImageView!
    @IBOutlet weak var listedCoinView: UIView!
    @IBOutlet weak var listedCoinTitleLabel: UILabel!
    @IBOutlet weak var listedCoinAddressCopy: UIButton!
    @IBOutlet weak var listedCoinAddressLabel: UILabel!
    @IBOutlet weak var listedCoinValueLabel: UILabel!
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
            self.stableCoinAddressLabel.text = wallet?.address
            self.listedCoinAddressLabel.text = wallet?.address
        }).disposed(by: bag)
        
        let totalBTC = self.viewModel.totalFiatValuesBTC.flatMapLatest { $0 }.share()
        let totalETH = self.viewModel.totalFiatValuesETH.flatMapLatest { $0 }.share()
        let fiat = viewModel.fiat
        
        let totalRSC = self.viewModel.totalFiatValuesForStableCoins.flatMapLatest { $0 }.share()
        let totalAirDrop = self.viewModel.totalFiatValuesListedCoins.flatMapLatest { $0 }.share()

        
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
                self.stableCoinValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)
        
        Observable.combineLatest(totalAirDrop, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] t, f in
                self.listedCoinValueLabel.text = self.updateValue(for: f, total: t)
            })
            .disposed(by: bag)
        
        self.btcAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.btcWallet.value?.address)
        }).disposed(by: bag)
        self.ethAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        self.stableCoinAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        self.listedCoinAddressCopy.rx.tapGesture().skip(1).subscribe(onNext: {[weak self] (gesture) in
            self?.handleAddressCopied(address: self?.viewModel.ethWallet.value?.address)
        }).disposed(by: bag)
        
        btcView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            self.toWalletDetail(withWallet: self.viewModel.btcWallet.value!, source: .BTC)
        }).disposed(by: bag)
        
        ethView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            self.toWalletDetail(withWallet: self.viewModel.ethWallet.value!, source: .ETH)
        }).disposed(by: bag)
        

        stableCoinView.rx.klrx_tap.asDriver().drive(onNext: {
            self.showStableCoinOptions()
            
        }).disposed(by: bag)
    
        listedCoinView.rx.klrx_tap.asDriver().drive(onNext: {
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
    
    private func showStableCoinOptions() {
        let actionSheet = UIAlertController.init(title: "Stable Coin",message: "", preferredStyle: .actionSheet)
        let actionBTC = UIAlertAction.init(title: "BTC", style: .default) { _ in
            let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: self.viewModel.btcWallet.value!, source: .RSC))
            //                self.navigationController?.pushViewController(vc, animated: true)
            self.present(vc, animated: true, completion: nil)
        }
        
        let actionETH = UIAlertAction.init(title: "ETH", style: .default) { _ in
            let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: self.viewModel.ethWallet.value!, source: .RSC))
            //                self.navigationController?.pushViewController(vc, animated: true)
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(actionBTC)
        actionSheet.addAction(actionETH)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        createCustomRightBarButton(img: #imageLiteral(resourceName: "tt_icon_create"),target: self, action: #selector(importWallet))
        
        self.btcTitleLabel.backgroundColor = palette.application_main
        self.stableCoinTitleLabel.backgroundColor = palette.application_main
        
        self.ethTitleLabel.backgroundColor = palette.application_alert
        self.listedCoinTitleLabel.backgroundColor = palette.application_alert
        
        self.btcAddressCopy.backgroundColor = palette.application_main
        self.ethAddressCopy.backgroundColor = palette.application_alert
        self.stableCoinAddressCopy.backgroundColor = palette.application_main
        self.listedCoinAddressCopy.backgroundColor = palette.application_alert
        
        self.btcView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        self.ethView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        self.stableCoinView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        self.listedCoinView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)

        self.view.setGradientColor()
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.title = "TTChain"
        
        
    }
    @objc func importWallet() {
        let vc = xib(vc: ImportWalletTypeChooseViewController.self)
        let nav = UINavigationController.init(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}
