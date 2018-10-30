//
//  TransferRecordOptionBarViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class TransferRecordOptionBarViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let defaultWallet: Wallet
    }
    
    typealias Constructor = Config
    typealias ViewModel = TransferRecordOptionBarViewModel
    var viewModel: TransferRecordOptionBarViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: Config) {
        view.layoutIfNeeded()
        configBars(with: constructor)
        viewModel = ViewModel.init(
            input: TransferRecordOptionBarViewModel.InputSource(
                mainCoinProvider: mainCoinBar.viewModel,
                walletProvioder: walletBar.viewModel,
                coinProvider: coinBar.viewModel,
                statusProvider: statusBar.viewModel
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private static var preferedHeightPerBar: CGFloat {
        return 50
    }
    
    private static var barIntervalGap: CGFloat {
        return 1
    }
        
    static var preferedHeight: CGFloat {
        //3 is for interval gap
        return preferedHeightPerBar * 4 + barIntervalGap * 4
    }
    
    private var mainCoinBar: TransferRecordChainTypeOptionViewController!
    
    private var walletBar: TransferRecordWalletOptionViewController!
    
    private var coinBar: TransferRecordCoinOptionViewController!
    
    private var statusBar: TransferRecordStatusOptionViewController!
    
    private func configBars(with config: Config) {
        mainCoinBar = TransferRecordChainTypeOptionViewController.instance(from: TransferRecordChainTypeOptionViewController.Config(defaultMainCoin: config.defaultWallet.mainCoin!)
        )
        
        walletBar = TransferRecordWalletOptionViewController.instance(from: TransferRecordWalletOptionViewController.Config(defaultWallet: config.defaultWallet))
        coinBar = TransferRecordCoinOptionViewController.instance(from: TransferRecordCoinOptionViewController.Config(defaultMainCoin: config.defaultWallet.mainCoin!)
        )
        
        statusBar = TransferRecordStatusOptionViewController.instance()
        
        let heightUnit = TransferRecordOptionBarViewController.preferedHeightPerBar
        let gap = TransferRecordOptionBarViewController.barIntervalGap
        addChildViewController(mainCoinBar)
        mainCoinBar.didMove(toParentViewController: self)
        view.addSubview(mainCoinBar.view)
        view.translatesAutoresizingMaskIntoConstraints = false
        constrain(mainCoinBar.view) { (view) in
            let sup = view.superview!
            view.leading == sup.leading
            view.trailing == sup.trailing
            view.top == sup.top
            view.height == heightUnit
        }
        
        addChildViewController(walletBar)
        walletBar.didMove(toParentViewController: self)
        view.addSubview(walletBar.view)
        constrain(walletBar.view, mainCoinBar.view) { (wallet, chainType) in
            wallet.leading == chainType.leading
            wallet.trailing == chainType.trailing
            wallet.top == chainType.bottom + gap
        }

        addChildViewController(coinBar)
        coinBar.didMove(toParentViewController: self)
        view.addSubview(coinBar.view)
        constrain(coinBar.view, walletBar.view) { (coin, wallet) in
            coin.leading == wallet.leading
            coin.trailing == wallet.trailing
            coin.top == wallet.bottom + gap
        }

        addChildViewController(statusBar)
        statusBar.didMove(toParentViewController: self)
        view.addSubview(statusBar.view)
        constrain(statusBar.view, coinBar.view) { (status, coin) in
            status.leading == coin.leading
            status.trailing == coin.trailing
            status.top == coin.bottom + gap
            status.bottom == status.superview!.bottom - gap
        }
        
        constrain(mainCoinBar.view, walletBar.view, coinBar.view, statusBar.view) { (wt, w, c, s) in
            wt.height == w.height
            w.height == c.height
            c.height == s.height
        }
    }

    private func bindViewModel() {
        viewModel.selectedMainCoin
            .subscribe(onNext: {
                [unowned self]
                newCoin in
                self.walletBar.viewModel.switchMainCoin(newCoin)
                self.coinBar.viewModel.switchMainCoin(newCoin)
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
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.specific(color: .owSilver)
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
