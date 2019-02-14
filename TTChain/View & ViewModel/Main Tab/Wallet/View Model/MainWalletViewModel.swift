//
//  MainWalletViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class WalletFinder {
    static let walletFindingKey = "walletFindingKey"
    
    struct WalletSelection: Codable {
        let epKey: String
        let chainTypeRaw: Int16
        let mainCoinID: String
        
        var chainType: ChainType {
            return ChainType.init(rawValue: chainTypeRaw)!
        }
    }
    
    static func getWallet() -> Wallet {
        
        let wallet: Wallet
        if let data = UserDefaults.standard.value(forKey: walletFindingKey) as? Data,
            let sel = try? PropertyListDecoder().decode(WalletSelection.self, from: data) {
            let pred = Wallet.createPredicate(from: sel.epKey, sel.chainTypeRaw, sel.mainCoinID)
            guard let _wallet = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil)?.first else {
                clearWalletMark()
                return getWallet()
            }
            
            wallet = _wallet
        }else {
            let typePred = NSPredicate.init(format: "chainType = %i", ChainType.eth.rawValue)
            let defaultPred = NSPredicate.init(format: "isFromSystem = %i", true)
            let pred = NSCompoundPredicate.init(andPredicateWithSubpredicates: [typePred, defaultPred])
            
            guard let _wallet = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil)?.first else {
                fatalError()
            }
            
            wallet = _wallet
        }
        
        markWallet(wallet)
        return wallet
    }
    
    static func markWallet(_ wallet: Wallet) {
        let selection = transformWalletToWalletSelection(wallet: wallet)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(selection), forKey: walletFindingKey)
    }
    
    static func clearWalletMark() {
        UserDefaults.standard.setValue(nil, forKey: walletFindingKey)
    }
    
    static private func transformWalletToWalletSelection(wallet: Wallet) -> WalletSelection {
        return WalletSelection.init(epKey: wallet.encryptedPKey!,
                                    chainTypeRaw: wallet.chainType,
                                    mainCoinID: wallet.walletMainCoinID!)
    }
}

class MainWalletViewModel: KLRxViewModel {
    struct Input {
//        let walletChangeInput: Driver<Void>
        let assetRowSelect: Driver<Int>
        let walletRefreshInput: Driver<Void>
        let wallet:Wallet
        let entryPoint:MainWalletViewController.EntryPoint
        let source:MainWalletViewController.Source

    }
    
    struct Output {
        let finishRefreshWallet: () -> Void
        let startChangeWallet: () -> Void
        let selectAsset: (Asset, Wallet) -> Void
    }
    
    private(set) var assets: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    
    typealias InputSource = Input
    typealias OutputSource = Output
    private(set) var input: MainWalletViewModel.Input
    private(set) var output: MainWalletViewModel.Output
    
    var bag: DisposeBag = DisposeBag.init()
    let wallet: BehaviorRelay<Wallet>

    lazy var fiat: BehaviorRelay<Fiat> = {
        return FiatManager.instance.fiat
    }()
    var entryPoint: MainWalletViewController.EntryPoint?
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.wallet = BehaviorRelay.init(value: input.wallet)
        self.entryPoint = input.entryPoint
        var _assets = self.fetchAssets()
        
        sortAssetsInPlace(&_assets, sort: AssetSortingManager.getSortOption())
        
        assets = BehaviorRelay.init(value: _assets)

        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    private func fetchAssets() -> [Asset] {
        //check in case the wallet is deleted, need to find a better way.
        guard self.input.wallet.mainCoin != nil else {
            return []
        }
        switch self.input.source {
        case .StableCoin:
            switch wallet.value.owChainType {
            case .eth:
            return Asset.getStableETHAssets(forETHWallet: self.input.wallet)
            case .btc:
                return Asset.getStableBTCAssets(forBTCWallet: self.input.wallet)
            default:
                return []
            }
        case .ListCoin:
            return Asset.getAirDropAssets(forETHWallet: input.wallet)
        case .ETH:
            return Asset.getETHAssets(forETHWallet: input.wallet)
        case .BTC:
            return Asset.getBTCAssets(forBTCWallet: input.wallet)
        }
    }
    
    func concatInput() {
//        input.walletChangeInput.drive(onNext: {
//            [unowned self] in self.output.startChangeWallet()
//        }).disposed(by: bag)
        
        input.assetRowSelect.map {
                [unowned self] row -> Asset in
                return self.assets.value[row]
            }
            .drive(onNext: {
                [unowned self] asset in
                self.output.selectAsset(
                    asset, self.wallet.value
                )
            }).disposed(by: bag)
        
        input.walletRefreshInput
            .drive(onNext: {
                [unowned self]
                _ in
                self.refreshAllData()
                self.output.finishRefreshWallet()
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        fiat.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{
                [unowned self] _ in
                self.refreshFiatData()
            })
            .disposed(by: bag)
        
        wallet.asObservable()
            .distinctUntilChanged()
            .skip(1)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.reloadAssets()
            })
            .disposed(by: bag)
        
        observeTransferFinishedEvent()
        observePrefFiatUpdateEvent()
        observeLaunchSync()
        observeWalletDeletedEvent()
    }
    
    private func observeLaunchSync() {
        OWRxNotificationCenter.instance
            .onFinishLaunchSync
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.reloadAssets()
            })
            .disposed(by: bag)
    }
    
    private func observePrefFiatUpdateEvent() {
        OWRxNotificationCenter.instance.prefFiatUpdate
            .subscribe(onNext: {
                [unowned self] fiat in
                self.fiat.accept(fiat)
            })
            .disposed(by: bag)
    }
    
    private func observeTransferFinishedEvent() {
        let withdrawalFinished = OWRxNotificationCenter.instance.onTransferRecordCreate
        let lightningTradeFinished = OWRxNotificationCenter.instance.onLightningTransferRecordCreate
        
        let tradeOfCoinIDHappened =
            Observable<String>.merge(
                withdrawalFinished
                    .map {
                        $0.fromCoinID!
                    },
                withdrawalFinished
                    .map {
                        $0.toCoinID!
                    },
                withdrawalFinished
                    .map {
                        $0.feeCoinID!
                    },
                lightningTradeFinished
                    .map {
                        $0.fromCoinID!
                    },
                lightningTradeFinished
                    .map {
                        $0.toCoinID!
                    },
                lightningTradeFinished
                    .map {
                        $0.feeCoinID!
                    }
            )
            .distinctUntilChanged()
        
        tradeOfCoinIDHappened.map {
            [unowned self] coinID in
            return self.assets.value.index(where: { (asset) -> Bool in
                return asset.coinID == coinID
            })
        }
        .filterNil()
        .map { [unowned self] in self.assets.value[$0] }
        .subscribe(onNext: {
            [unowned self] assetNeedToUpdate in
            
            self.amt(ofAsset: assetNeedToUpdate).accept(
                self.createAssetAmtUpater(ofAsset: assetNeedToUpdate)
            )
            self.fiatValue(ofAsset: assetNeedToUpdate).accept(
                self.createFiatValueUpater(ofAsset: assetNeedToUpdate)
            )
            
            self._onAssetFinishUpdateFromTransfer.accept(assetNeedToUpdate)
        })
        .disposed(by: bag)
    }
    
    public func changeWallet(_ wallet: Wallet) {
        DispatchQueue.global().async {
//            WalletFinder.markWallet(wallet)
            self.wallet.accept(wallet)
        }
    }
    
    private func observeWalletDeletedEvent() {
        OWRxNotificationCenter.instance.walletDeleted
            .filter {
                [unowned self] in
                $0 == self.wallet.value
            }
            .subscribe(onNext: {
                _ in
                self.resetWalletToFirstSystemWallet()
            })
            .disposed(by: bag)
    }
    
    private func resetWalletToFirstSystemWallet() {
        guard let wallet = Identity.singleton!.wallets?.array.first as? Wallet else {
            return
        }
        
        changeWallet(wallet)
    }
    
    public func reloadAssets(assets: [Asset]? = nil) {
        DispatchQueue.main.async {
            //As assets update shuold perfrom asap, load it in the main thread to prevent user keeping seeing the assets of previous wallet.
            var _assets = assets ?? self.fetchAssets()
            self.sortAssetsInPlace(&_assets, sort: AssetSortingManager.getSortOption())
            self.assets.accept(_assets)
            
            //From here is updating the metadata of asset (amt/fiatRate/fiatValue)
            //Which is not that urgent, so move it to the global queue to prevent keeping blocking user.
            DispatchQueue.global().async {
                self.clearSource()
                for _asset in _assets {
                    self.assetAmtTable[_asset] = self.amt(ofAsset: _asset)
                    self.fiatRateTable[_asset] = self.fiatRate(ofAsset: _asset)
                    self.assetFiatValueTable[_asset] = self.fiatValue(ofAsset: _asset)
                }
                
                let totalFiatValues = self.createTotalFiatValues()
                //            DispatchQueue.main.async {
                
                self.totalFiatValues.accept(totalFiatValues)
                //            }
            }
        }
    }
    
    func clearSource() {
        assetAmtTable.removeAll()
        fiatRateTable.removeAll()
        assetFiatValueTable.removeAll()
    }
    
    /// Calling when wallet update. this function will refresh all the data source.
    func refreshAllData() {
        for (k, v) in assetAmtTable {
            v.accept(createAssetAmtUpater(ofAsset: k))
        }
        
        for (k, v) in fiatRateTable {
            v.accept(createFiatRateUpater(ofAsset: k))
        }
        
        for (k, v) in assetFiatValueTable {
            v.accept(createFiatValueUpater(ofAsset: k))
        }
        
        totalFiatValues.accept(createTotalFiatValues())
    }
    
    /// Calling this function will renew fiat data (include fiatRate and fiatValue)
    /// Please always call this function only when fiat is updated.
    func refreshFiatData() {
        for (k, v) in fiatRateTable {
            v.accept(createFiatRateUpater(ofAsset: k))
        }
        
        for (k, v) in assetFiatValueTable {
            v.accept(createFiatValueUpater(ofAsset: k))
        }
        
        totalFiatValues.accept(createTotalFiatValues())
    }
    
    /// Table to store fiat value of each asset
    /// Note: asset fiat value relay is bind to amt * value right after initialized.
    private var assetFiatValueTable: [Asset : BehaviorRelay<BehaviorRelay<Decimal?>>] = [:]
    func fiatValue(ofAsset asset: Asset) ->  BehaviorRelay<BehaviorRelay<Decimal?>> {
        if let value = assetFiatValueTable[asset] {
            return value
        }else {
            let source = createFiatValueUpater(ofAsset: asset)
            assetFiatValueTable[asset] = BehaviorRelay.init(value: source)
            return fiatValue(ofAsset: asset)
        }
    }
    
    private func createFiatValueUpater(ofAsset asset: Asset) -> BehaviorRelay<Decimal?> {
        let amount = amt(ofAsset: asset)
        let rate = fiatRate(ofAsset: asset)
        let observ: Observable<Decimal?> = Observable.combineLatest(
            amount.asObservable().flatMapLatest { $0 }, rate.asObservable().flatMapLatest { $0 }
            )
            .map {
                a, r -> Decimal? in
                guard let _a = a, let _r = r else { return nil }
                return _a * _r
        }
        
        let value = BehaviorRelay<Decimal?>.init(value: nil)
        observ.bind(to: value).disposed(by: bag)
        
        return value
    }
    
    /// Table to store amt of each asset, the value is updatable, so view can use this source to update changes. Nil means there no record now.
    private var assetAmtTable: [Asset :  BehaviorRelay<BehaviorRelay<Decimal?>>] = [:]
    func amt(ofAsset asset: Asset) ->  BehaviorRelay<BehaviorRelay<Decimal?>> {
        if let amt = assetAmtTable[asset] {
            return amt
        }else {
            let source = createAssetAmtUpater(ofAsset: asset)
            assetAmtTable[asset] = BehaviorRelay.init(value: source)
            return amt(ofAsset: asset)
        }
    }
    
    private func createAssetAmtUpater(ofAsset asset: Asset) -> BehaviorRelay<Decimal?> {
        let source = BehaviorRelay.init(value: asset.amount as Decimal?)
        updateAssetAmt(asset).subscribe(onNext: {
            amt in
            source.accept(amt)
            if let _amt = amt {
                asset.updateAmt(_amt)
            }
        })
        .disposed(by: bag)
        
        return source
    }
    
    /// Table to store the prefer fiat rate of each asset.
    private var fiatRateTable: [Asset :  BehaviorRelay<BehaviorRelay<Decimal?>>] = [:]
    func fiatRate(ofAsset asset: Asset) ->  BehaviorRelay<BehaviorRelay<Decimal?>> {
        if let rate = fiatRateTable[asset] {
            return rate
        }else {
            let source = createFiatRateUpater(ofAsset: asset)
            fiatRateTable[asset] = BehaviorRelay.init(value: source)
            return fiatRate(ofAsset: asset)
        }
    }
    
    private func createFiatRateUpater(ofAsset asset: Asset) -> BehaviorRelay<Decimal?> {
        let source: BehaviorRelay<Decimal?>
        let dbRatePred = CoinToFiatRate.createPredicate(from: asset.coinID!, self.fiat.value.id)
        
        if let rate = DB.instance.get(type: CoinToFiatRate.self, predicate: dbRatePred, sorts: nil)?.first {
            source = BehaviorRelay.init(value: rate.rate! as Decimal)
        }else {
            source = BehaviorRelay.init(value: nil)
        }
        
        updateFiatRateToAsset(fiat.value, asset: asset)
            .subscribe(onNext: {
                rate in
                source.accept(rate)
            })
            .disposed(by: bag)
        
        return source
    }
    
    private(set) lazy var totalFiatValues: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues())
    }()
    
    private func createTotalFiatValues() -> BehaviorRelay<Decimal?> {
        let source: BehaviorRelay<Decimal?> = BehaviorRelay.init(value: nil)
        let fiatValueRelays = assets.map {
            [unowned self] in
            $0.map { [unowned self] in self.fiatValue(ofAsset: $0) }
        }
        .take(1)
        
        let fiatValues = fiatValueRelays.flatMapLatest({ (fiatValues) -> Observable<[Decimal?]> in
            
            return Observable.combineLatest(
                fiatValues.map {
                    $0.asObservable().flatMapLatest { $0 }
                }
            )
        })
        
        let sum: Observable<Decimal?> = fiatValues.map {
            values -> Decimal? in
            let nonOptionalVals = values.compactMap { $0 }
            if !nonOptionalVals.isEmpty {
                return nonOptionalVals.map { $0.rounded(toPlaces: 2,
                                                        rule: .towardZero) }
                                      .reduce(0, +)
            }else {
                return nil
            }
        }
        
        
        sum.bind(to: source).disposed(by: bag)

        return source
    }
    
    //MARK: - Asset Update From Notification
    public var onAssetFinishUpdateFromTransfer: Observable<Asset> {
        return _onAssetFinishUpdateFromTransfer.asObservable()
    }
    
    private lazy var _onAssetFinishUpdateFromTransfer: PublishRelay<Asset> = {
        return PublishRelay.init()
    }()
}

extension MainWalletViewModel {
    fileprivate func updateAssetAmt(_ asset: Asset) -> Observable<Decimal?> {
        return asset.getAmtFromServerIfPossible().asObservable()
    }
    
    fileprivate func updateFiatRateToAsset(_ fiat: Fiat, asset: Asset) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: asset.coin!, fiat: fiat).asObservable().debug("get fiat rate of asset: \(fiat.name!)/\(asset.coin!.inAppName!)")
    }
}

// MARK: - Helper
extension MainWalletViewModel {
    fileprivate func sortAssetsInPlace(_ assets: inout [Asset], sort: AssetSortingManager.Sort) {
        
        let sortedAssets: [Asset]
        switch sort {
        case .none:
            //Do the reset
            sortedAssets = self.fetchAssets()
        case .alphabetic:
            sortedAssets = assets.sorted(by: { (asset1, asset2) -> Bool in
                guard let c1 = asset1.coin, let c2 = asset2.coin else {
                    return true
                }
                
                return c1.inAppName! <= c2.inAppName!
            })
        case .assetAmt:
            sortedAssets = assets.sorted(by: { (asset1, asset2) -> Bool in
                guard let a1_amt = asset1.amount as Decimal?,
                    let a2_amt = asset2.amount as Decimal? else {
                        return true
                }
                
                //If one of asset is empty, just compare the amount itself
                if a1_amt == 0 || a2_amt == 0 {
                    return a1_amt >= a2_amt
                }else {
                    /* Both assets are not empty,
                     so try to get the fiat rate of the coin from DB.
                     If able to get the fiat rate,
                     return the result of fiat value comparison */
                    if let usd = Fiat.usd?.id,
                        let fiatRate1 = CoinToFiatRate.getRateFromDatabase(coinID: asset1.coinID!, fiatID: usd)?.rate as Decimal?,
                        let fiatRate2 = CoinToFiatRate.getRateFromDatabase(coinID: asset2.coinID!, fiatID: usd)?.rate as Decimal? {
                        return a1_amt * fiatRate1 >= a2_amt * fiatRate2
                    }else {
                        /* if unable to get fiat rate from DB,
                         just compare the asset amt. */
                        return a1_amt >= a2_amt
                    }
                }
            })
        }
        
        var unremovableAssets: [Asset] = []
        var removableAssets: [Asset] = []
        for asset in sortedAssets {
            if asset.coin!.isDeletable {
                removableAssets.append(asset)
            }else {
                unremovableAssets.append(asset)
            }
        }
        
        //As the unremovable coins shuold always be list at top of the list.
        assets = unremovableAssets + removableAssets
    }
}
