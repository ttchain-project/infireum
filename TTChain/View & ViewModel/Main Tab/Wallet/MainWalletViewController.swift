//
//  MainWalletViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class MainWalletViewController: KLModuleViewController, KLVMVC {
    
    enum Source {
        case BTC, ETH, StableCoin, ListCoin
    }
    enum EntryPoint:Int {
        case MainTab = 0
        case MainWallet
    }
    struct Config {
        let entryPoint: EntryPoint
        let wallet:Wallet
        let source:Source
    }
    typealias Constructor = Config
    typealias ViewModel = MainWalletViewModel
    
    var viewModel: MainWalletViewModel!
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
        
    fileprivate lazy var walletOverviewVC: MainWalletOverviewViewController = {
        let vc = MainWalletOverviewViewController.instance(
            of: viewModel.wallet.value,
            total: viewModel.totalFiatValues.value.value,
            fiat: viewModel.fiat.value
        )
        
        return vc
    }()
    
    fileprivate let refreshControl = WalletRefreshControl.init()
    
//    fileprivate lazy var transRecordBtn: UIButton = {
//        let text = LM.dls.walletOverview_btn_txRecord
//        return changeLeftBarButton(target: self, selector: #selector(toTransRecord), title: text)
//    }()
    
//    fileprivate lazy var qrCodeScannerBtn: UIButton = {
//        return createRightBarButton(target: self, selector: #selector(toQRCodeScan), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), shouldClear: true)
//    }()
    
    
    
    func config(constructor: Constructor) {
        view.layoutIfNeeded()
        
        let refreshStart = refreshControl.rx.controlEvent(.valueChanged).asDriver().throttle(2.5, latest: true)
        
        viewModel = ViewModel.init(
            input: MainWalletViewModel.InputSource(
                
                //            walletChangeInput: walletChooseTextField.rx.tapGesture().map { _ in () }.skip(1).asDriver(onErrorJustReturn: ()),
                assetRowSelect: tableView.rx.itemSelected.asDriver().map { $0.row },
                walletRefreshInput: refreshStart,
                wallet:constructor.wallet,
                entryPoint: constructor.entryPoint,
                source:constructor.source
            ),
            output: MainWalletViewModel.OutputSource(
                finishRefreshWallet: {
                    [unowned self] in
                    //                    print("finish refresh")
                    self.refreshControl.endRefreshing()
                },
                startChangeWallet: {
                    [unowned self] in self.startChangeWallet()
                },
                selectAsset: {
                    [unowned self] (asset, wallet) in self.handleAssetSelect(asset, ofWallet: wallet)
                }
            )
        )
        
//        walletOverviewVC.onSwitchWallet.drive(onNext:{
//            [unowned self] in
//            self.startChangeWallet()
//        })
//        .disposed(by: bag)
        
        walletOverviewVC.onAddressCopied.drive(onNext:{
            [unowned self]
            addr in
            self.handleAddressCopied(address: addr)
        })
        .disposed(by: bag)
        
//        walletOverviewVC.onDeposit.drive(onNext:{
//            [unowned self]
//            wallet in
//            self.startDeposit(wallet: wallet)
//        })
//        .disposed(by: bag)
        
//        walletOverviewVC.onTransactionHistory.drive(onNext:{
//            self.toTransRecord()
//        }).disposed(by:bag)
        
//        walletOverviewVC.onManageAsset.drive(onNext:{
//            [unowned self]
//            wallet in
//            self.startManageAsset(wallet: wallet)
//        })
//        .disposed(by: bag)
        
        
        configTableView()
        bindWalletOverviewUpdate()
        bindAssetUpdate()
        observePrivateModeUpdateEvent()
        
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()

       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        renderNavTitle(color: .owWhite, font: .owDemiBold(size: 18))

    }
    
    
    private func configTableView() {
        let base = UIView.init()
        base.backgroundColor = .clear
        base.addSubview(walletOverviewVC.view)
        base.frame = CGRect.init(origin: .zero, size: MainWalletOverviewViewController.prefSize)
        constrain(walletOverviewVC.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
        tableView.tableHeaderView = base
        
        tableView.addSubview(refreshControl)
        tableView.register(MainWalletAssetTableViewCell.nib, forCellReuseIdentifier: MainWalletAssetTableViewCell.cellIdentifier())
        viewModel.assets.bind(to: tableView.rx.items(cellIdentifier: MainWalletAssetTableViewCell.cellIdentifier(), cellType: MainWalletAssetTableViewCell.self)) {
            [weak self]
            row, asset, cell in
            guard let wSelf = self else { return }
            let _coin: Coin
            if let coin = asset.coin {
                _coin = coin
            }else {
                let pred = Coin.genPredicate(fromIdentifierType: IdentifierUnit.str(keyPath: #keyPath(Coin.identifier), value: asset.coinID!))
                guard let coin = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil)?.first else {
                    return errorDebug(response: ())
                }
                
                _coin = coin
            }
            
            let amtSource = wSelf.viewModel.amt(ofAsset: asset).asObservable()
            let fiatValueSource = wSelf.viewModel.fiatValue(ofAsset: asset).asObservable()
            let fiatSource = wSelf.viewModel.fiat.asObservable()
            cell.config(coin: _coin, amtSource: amtSource, fiatValueSource: fiatValueSource, fiatSource: fiatSource)
        }
        .disposed(by: bag)
    }
    
    
    private func bindWalletOverviewUpdate() {
        let wallet = viewModel.wallet
        let total = viewModel.totalFiatValues.flatMapLatest { $0 }
        let fiat = viewModel.fiat
        
        Observable.combineLatest(wallet, total, fiat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] w, t, f in
                self.walletOverviewVC.update(wallet: w, total: t, fiat: f)
            })
            .disposed(by: bag)
    }
    
    private func bindAssetUpdate() {
        viewModel.onAssetFinishUpdateFromTransfer
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
    
    private func observePrivateModeUpdateEvent() {
        OWRxNotificationCenter
            .instance
            .onChangePrivateMode
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        //        transRecordBtn.setTitleForAllStates(text)
        switch self.viewModel.entryPoint! {
        case .MainTab:
            self.title = "TTChain"
        case .MainWallet:
            self.title = {
                switch self.viewModel.input.source {
                case .StableCoin:
                    return lang.dls.stable_coin
                case .ListCoin:
                    return lang.dls.sto_coin
                default:
                    return self.viewModel.wallet.value.name
                }
            }()
            
        }
        
    }
    
    override func renderTheme(_ theme: Theme) {
//        transRecordBtn.tintColor = theme.palette.specific(color: theme.palette.application_main)
//        qrCodeScannerBtn.tintColor = theme.palette.specific(color: theme.palette.application_main)
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        switch self.viewModel.entryPoint {
        case .MainWallet?:
            changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
            createCustomRightBarButton(img: #imageLiteral(resourceName: "settings"), target: self, action: #selector(toSettings))
        default:
            changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        }
        tableView.backgroundColor = theme.palette.bgView_sub
    }
    
    private func startChangeWallet() {
//        let vc = ChangeWalletViewController.instance(from: ChangeWalletViewController.Constructor(assetSupportLimit: nil)
//        )
//        vc.onWalletSelect
//            .observeOn(MainScheduler.instance)
//            .debug("Select Wallet: Prepare dismissing")
//            .subscribe(
//                onNext: {
//                    [unowned self] wallet in
//                    vc.dismiss(animated: true, completion: {
//                        self.viewModel.changeWallet(wallet)
//                    })
//                }
//            )
//            .disposed(by: bag)
//
//        present(vc, animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startDeposit(wallet: Wallet) {
        guard let firstAsset = viewModel.assets.value.first else {
            return
        }
        
        let nav = DepositViewController.navInstance(from: DepositViewController.Setup(wallet: wallet, asset: firstAsset)
        )
        
        present(nav, animated: true, completion: nil)
    }

    private func startManageAsset(wallet: Wallet) {
        let nav = ManageAssetViewController.navInstance(
            from: ManageAssetViewController.Config(wallet: wallet, updateNotifier: {
                [unowned self] assets in
                self.viewModel.reloadAssets(assets: assets)
            },source:self.viewModel.input.source)
        )
        
        present(nav, animated: true, completion: nil)
    }
    
    private func handleAddressCopied(address: String) {
        UIPasteboard.general.string = address
        EZToast.present(on: self,
                        content: LM.dls.g_toast_addr_copied)
    }
    
    private func handleAssetSelect(_ asset: Asset, ofWallet wallet: Wallet) {
        let vc = AssetDetailViewController.navInstance(
            from: AssetDetailViewController.Config(asset: asset)
        )
        //        let assetVC = AssetDetailViewController.instance(from: AssetDetailViewController.Config(asset: asset))
                present(vc, animated: true, completion: nil)

//        switch self.viewModel.entryPoint {
//        case .MainWallet?:
//            let vc = WithdrawalBaseViewController.instance(
//                from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: nil)
//            )
//            self.navigationController?.pushViewController(vc, animated: true)
//        default:
//            let vc = WithdrawalBaseViewController.navInstance(
//                from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: nil)
//            )
//            self.present(vc, animated: true)
//        }
    }
    
    @objc private func toTransRecord() {
        let nav = TransferRecordsListViewController.navInstance()
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func toSettings() {
        let vc = ManageWalletViewController.instance(from: ManageWalletViewController.Config(wallet: viewModel.wallet.value))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func toQRCodeScan() {
//        let chainType = viewModel.wallet.value.owChainType
        let nav = OWQRCodeViewController.navInstance(from: OWQRCodeViewController._Constructor(
            purpose: .general(nil),
            resultCallback: { [unowned self] (result, purpose, scanningType) in
                self.handleQRCodeScanResult(result: result, purpose: purpose, scanningType: scanningType)
            },
            isTypeLocked: false
            )
        )
        present(nav, animated: true, completion: nil)
    }
    
    private func handleQRCodeScanResult(
        result: OWQRCodeDecoder.DecodingResult,
        purpose: OWQRCodeViewController.Purpose,
        scanningType: OWQRCodeViewController.ScanningType
        ) {
        switch scanningType {
        case .withdrawal:
            switch result {
            case .address(let addr, chainType: let type, coin: let coin, amt: _):
                if let c = coin {
                    attemptWithdrawal(with: addr, coin: c)
                }else {
                    //Attemp to find base coin of the wallet type
                    let c: Coin
                    switch type {
                    case .btc: c = Coin.btc
                    case .eth: c = Coin.eth
                    case .cic: c = Coin.btcRelay
                    }
                    
                    attemptWithdrawal(with: addr, coin: c)
                }
            default: break
            }
        case .importWallet:
            switch result {
            case .mnemonic(let mne): //NOTE: No mnemonic import now.
                break
            case .privateKey(let pKey, possibleAddresssesInfo: let infos) where infos.count == 1:
                let info = infos[0]
                toImportWallet(pKey: pKey,
                               address: info.address,
                               mainCoinID: info.mainCoin.identifier!)
            default: break
            }
        case .contact:
            switch result {
            case .address(let addr, chainType: let chain, coin: let coin, amt: _):
                let mainCoinID: String
                if let c = coin {
                    mainCoinID = c.walletMainCoinID!
                }else {
                    mainCoinID = chain.defaultCoin.walletMainCoinID!
                }
                
                toAddressList(address: addr, mainCoinID: mainCoinID)
            default: break
            }
        default: break
        }
        
    }
    
    private func toImportWallet(pKey: String, address: String, mainCoinID: String) {
        let vc = ImportWalletViaPrivateKeyViewController.navInstance(from: ImportWalletViaPrivateKeyViewController.Config(mainCoinID: mainCoinID, defaultPKey: pKey)
        )
        
        dismiss(animated: false) {
            [unowned self] in
            self.present(vc, animated: true, completion: nil)
        }
    }

    private func toAddressList(address: String, mainCoinID: String) {
        let vc: UIViewController
        if let unit = AddressBookUnit.findUnit(
            identity: Identity.singleton!,
            addr: address,
            mainCoinID: mainCoinID
            ) {
            vc = EditABUnitViewController.navInstance(from: EditABUnitViewController.Config(source: .abUnit(unit)))
        } else {
            vc = EditABUnitViewController.navInstance(from: EditABUnitViewController.Config(source: .scannedSource(addr: address, mainCoinID: mainCoinID)))
        }
        
        dismiss(animated: false) {
            [unowned self] in
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func attemptWithdrawal(with address: String, coin: Coin) {
        if coin.owChainType == .cic {
            dismiss(animated: true) {
                OWRxNotificationCenter.instance.switchToLightningModeWithCoin(coin)
            }
        }else {
            guard let asset = Identity.singleton!.getAllAssets(of: coin).first else {
        
                navigationController?.topViewController?
                    .showSimplePopUp(
                        with: LM.dls
                            .walletOverview_alert_withdrawal_noAsset_title(coin.inAppName!),
                        contents: LM.dls.walletOverview_alert_withdrawal_noAsset_content(coin.inAppName!),
                        cancelTitle: LM.dls.g_cancel,
                        cancelHandler: nil
                )
                
                return
            }
            let vc = WithdrawalBaseViewController.navInstance(
                from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: address, defaultAmount:nil)
            )
            
            //        if presentingViewController == nil {
            //            present(vc, animated: true, completion: nil)
            //        } else {
            dismiss(animated: false) {
                [unowned self] in
                self.present(vc, animated: true, completion: nil)
            }
            //        }
        }
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


extension MainWalletViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

