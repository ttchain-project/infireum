//
//  AssetDetailViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography


final class AssetDetailViewController: KLModuleViewController, KLVMVC {
    
    enum Purpose {
        case mainWallet
        case lightTx
    }
    
    struct Config {
        let asset: Asset
        let purpose:Purpose
    }
    
    typealias Constructor = Config
    func config(constructor: AssetDetailViewController.Config) {
        
        view.layoutIfNeeded()
        tabVC = TransRecordListTabViewController.instance(of: [], asset: constructor.asset)
        self.purpose = constructor.purpose

        viewModel = ViewModel.init(
            input: AssetDetailViewModel.InputSource(
                asset: constructor.asset,
                depositInput: depositBtn.rx.tap.asDriver(),
                withdrawalInput: withdrawalBtn.rx.tap.asDriver(),
                loadMoreInput: tabVC.nextPage,
                refreshInput: tabVC.refresh
            ),
            output: ()
        )
        
        bindViewModel()
        configTabVC()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
//        if constructor.purpose == .lightTx {
//            self.transferBase.isHidden = true
//            self.view.layoutIfNeeded()
//        }else {
//            if viewModel.input.asset.wallet!.mainCoin!.identifier == Coin.btc_identifier {
//                self.ttcShortcutView.isHidden = false
//            }
//        }
    }
    
    typealias ViewModel = AssetDetailViewModel
    var viewModel: AssetDetailViewModel!
    var bag: DisposeBag = DisposeBag.init()
    var purpose:AssetDetailViewController.Purpose!
    
    @IBOutlet weak var assetInfoBase: UIView!
    @IBOutlet weak var assetAmtLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var assetFiatAmtLabel: UILabel!
    @IBOutlet weak var recordTabBase: UIView!
    @IBOutlet weak var transferBase: UIView!
    @IBOutlet weak var depositBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var ttcShortcutView: UIView! {
        didSet {
            ttcShortcutView.isHidden = true
        }
    }
    
    private var tabVC: TransRecordListTabViewController!
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        depositBtn.setTitleForAllStates(dls.assetDetail_receive)
        withdrawalBtn.setTitleForAllStates(dls.assetDetail_btn_withdrawal)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        self.hideDefaultNavBar()
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bar_tint)

        renderNavTitle(color: palette.nav_bg_1, font: .owMedium(size: 18))
        changeNavShadowVisibility(false)
        
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_bg_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        if self.purpose == .mainWallet {
            createCustomRightBarButton(img: #imageLiteral(resourceName: "wallet_settings"), target: self, action: #selector(toSettings))
        }
        
        view.backgroundColor = .white
        assetInfoBase.backgroundColor = .cloudBurst
        assetAmtLabel.set(textColor: palette.label_main_2, font: .owMedium(size: 26))
        assetFiatAmtLabel.set(textColor: palette.label_main_2, font: .owRegular(size: 12))
        walletNameLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12))
        
        depositBtn.cornerRadius = 5
        depositBtn.set(
            color: palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),
            backgroundColor: palette.recordStatus_deposit
        )
        
        withdrawalBtn.cornerRadius = 5
        withdrawalBtn.set(
            color: palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),
            backgroundColor: palette.recordStatus_withdrawal
        )
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.view.setGradientColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func toSettings() {
        let vc = ManageWalletViewController.instance(from: ManageWalletViewController.Config(wallet: viewModel.input.asset.wallet!))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func bindViewModel() {
        
        self.walletNameLabel.text = "(\(self.viewModel.input.asset.wallet!.name!))"
        
        let coin = viewModel.input.asset.coin!
        title = viewModel.input.asset.coin?.inAppName?.replacingOccurrences(of: "BTCN", with: "BTC")
        
        viewModel.records
            .subscribe(
                onNext: {
                    [unowned self] in
                    self.updateTabChildsTransRecords(newRecords: $0)
                }
            )
            .disposed(by: bag)
        
        let privateModeEvent = OWRxNotificationCenter.instance.onChangePrivateMode
        
        Observable.combineLatest(viewModel.amtSource, privateModeEvent)
            .map {
                amt, pMode in
                if let _amt = amt {
                    return _amt
                        .asString(digits: 4,
                                  force: true,
                                  maxDigits: Int(coin.digit),
                                  digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                        .disguiseIfNeeded()
                }else {
                    return "--"
                }
            }
            .bind(to: assetAmtLabel.rx.text)
            .disposed(by: bag)
        
        Observable.combineLatest(viewModel.fiat, viewModel.fiatRate, viewModel.amtSource, privateModeEvent)
            .map {
                fiat, fiatRate, amt, pMode -> String in
                let fiatSymbol = fiat.fullSymbol
                let prefix = "≈" + fiatSymbol + " "
                if let rate = fiatRate, let _amt = amt {
                    return prefix + (rate * _amt).asString(digits: 2, force: true).disguiseIfNeeded()
                }else {
                    return prefix + "--"
                }
            }
            .bind(to: assetFiatAmtLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.startDeposit.subscribe(onNext: {
            [unowned self] asset in
            self.toDeposit(with: asset)
        })
            .disposed(by: bag)
        
        ttcShortcutView.rx.klrx_tap.drive(onNext: {
            self.toTTCShortcut(asset: self.viewModel.input.asset)
        }).disposed(by: bag)
        
        viewModel.startWithdrawal
            .flatMapLatest {
                //This is a little bit hack, to update the fee before enter the view.
                [unowned self]
                asset -> Observable<Asset> in
                self.animateIndicator()
                return self.prepareFee(ofAsset: asset).asObservable().map { _ in asset }
            }
            .subscribe(onNext: {
                [unowned self] asset in
                self.hideIndicator()
                self.toWithdrawal(with: asset)
            })
            .disposed(by: bag)
        
        //When loading finish, hide refresher of child list vc
        viewModel.finishLoading
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] result in
                self?.tabVC.stopRefresh()
                switch result {
                case .failed(let err):
                    switch (err) {
                    case .noData:
                        break
                    default:
                        self?.showAPIErrorResponsePopUp(from: err,
                                                        cancelTitle: LM.dls.g_confirm)
                    }
                    
                case .success: break
                }
            })
            .disposed(by: bag)
    }
    
    private func configTabVC() {
        addChildViewController(tabVC)
        recordTabBase.addSubview(tabVC.view)
        tabVC.didMove(toParentViewController: self)
        constrain(tabVC.view) { (view) in
            let sup = view.superview!
            view.top == sup.top
            view.bottom == sup.bottom
            view.trailing == sup.trailing
            view.leading == sup.leading
        }
    }
    
    private func updateTabChildsTransRecords(newRecords: [TransRecord]) {
        tabVC.updateRecords(newRecords)
    }
    
    
    //MARK: - Routing
    private func toDeposit(with asset: Asset) {
//        let vc = DepositViewController.navInstance(from: DepositViewController.Setup(wallet: asset.wallet!, asset: asset))
        let viewModel = LightReceiptQRCodeViewModel.init(asset: asset)
        let vc = LightReceiptQRCodeViewController.init(viewModel: viewModel)
        self.navigationController?.pushViewController(vc)
//        present(vc, animated: true, completion: nil)
    }
    
    private func toWithdrawal(with asset: Asset) {
        switch asset.wallet!.owChainType {
        case .btc, .eth:
            let nav = WithdrawalBaseViewController.navInstance(from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: nil,defaultAmount:nil))
            present(nav, animated: true, completion: nil)
        case .cic:
            OWRxNotificationCenter.instance
                .switchToLightningModeWithCoin(asset.coin!)
            dismiss(animated: true) {}
        case .ttn,.ifrc:
            DLogInfo("TTN to withdrawal")
        }
    }
    
    private func toTTCShortcut(asset: Asset) {
        let toAsset:Asset? = {
            switch asset.coinID {
            case Coin.btc_identifier:
                return Asset.getAssetsForCoinID(coinId: Coin.btcn_identifier).first
            case Coin.usdt_identifier:
                return Asset.getAssetsForCoinID(coinId: Coin.usdtn_identifier).first
            default:
                return nil
            }
        }()
        
        let vc = LightDepositWalletChooseViewController.navInstance(from: LightDepositWalletChooseViewController.Config(toAsset: toAsset!, fromAsset: asset))
        self.present(vc, animated: true, completion: nil)

    }
    
    
    //MARK: Fee Preparation
    private func prepareFee(ofAsset asset: Asset) -> RxAPIVoidResponse {
        switch asset.coin!.owChainType {
        case .btc: return FeeManager.updateBTCFeeRates()
        case .eth,.ttn,.ifrc: return FeeManager.updateETHFeeRates()
        case .cic:
            let mainCoinID = asset.coin!.walletMainCoinID!
            return FeeManager.updateCICFeeRates(mainCoinID: mainCoinID)
        }
    }
    
}
