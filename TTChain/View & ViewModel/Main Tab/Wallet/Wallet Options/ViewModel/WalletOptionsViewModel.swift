//
//  WalletOptionsViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/10/30.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


class WalletOptionsViewModel:KLRxViewModel {
   
    struct Input {
        
    }
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
        fetchWallets()
    }
    
    var input: Void
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    lazy var btcWallet: BehaviorRelay<[Wallet]?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    lazy var ethWallet: BehaviorRelay<[Wallet]?> = {
        return BehaviorRelay.init(value: nil)
    }()

    lazy var fiat: BehaviorRelay<Fiat> = {
        return FiatManager.instance.fiat
    }()
    
    private(set) var assetsForBTC: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    private(set) var assetsForStableCoins: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    private(set) var assetsForETH: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    private(set) var assetsForAirDrop: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    private var totalBTCAssets =  [Asset]()
    private var totalETHAssets = [Asset]()
    
    func fetchWallets() {
        let sortDescriptor = NSSortDescriptor.init(key: "isFromSystem", ascending: false)
        let predForBTC = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.btc.rawValue))
        guard let btcWallet = DB.instance.get(type: Wallet.self, predicate: predForBTC, sorts: [sortDescriptor]) else {
            return
        }
        self.btcWallet.accept(btcWallet)
        
        let predForETH = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.eth.rawValue))
        guard let ethWallet = DB.instance.get(type: Wallet.self, predicate: predForETH, sorts: [sortDescriptor]) else {
            return
        }
        self.ethWallet.accept(ethWallet)
        
       
        
        var _assetsForBTC = [Asset]()
        var stableAssetsForBTC = [Asset]()

        for wallet in self.btcWallet.value! {
            _assetsForBTC.append(contentsOf: Asset.getBTCAssets(forBTCWallet:wallet))
            stableAssetsForBTC.append(contentsOf: Asset.getStableBTCAssets(forBTCWallet:wallet))
        }
        
        var _assetsForETH = [Asset]()
        var stableAssetsForETH = [Asset]()
        for wallet in self.ethWallet.value! {
            _assetsForETH.append(contentsOf: Asset.getETHAssets(forETHWallet:wallet))
            stableAssetsForETH.append(contentsOf: Asset.getStableETHAssets(forETHWallet:wallet))
        }
        let _assetsForAirDrop:[Asset] = []
        let _assetsForStableCoins:[Asset] = stableAssetsForETH + stableAssetsForBTC
        
        self.assetsForETH = BehaviorRelay.init(value: _assetsForETH + stableAssetsForETH)
        self.assetsForBTC = BehaviorRelay.init(value: _assetsForBTC + stableAssetsForBTC)
        self.assetsForStableCoins = BehaviorRelay.init(value: _assetsForStableCoins)
        self.assetsForAirDrop = BehaviorRelay.init(value: _assetsForAirDrop)
        self.refreshAllData()
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
        
        totalFiatValuesBTC.accept(createTotalFiatValues(for: assetsForBTC))
        totalFiatValuesETH.accept(createTotalFiatValues(for: assetsForETH))
        totalFiatValuesForStableCoins.accept(createTotalFiatValues(for: assetsForStableCoins))
        totalFiatValuesListedCoins.accept(createTotalFiatValues(for: assetsForAirDrop))
        
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
        
        totalFiatValuesBTC.accept(createTotalFiatValues(for: assetsForBTC))
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
    
    private(set) lazy var totalFiatValuesBTC: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(for: assetsForBTC))
    }()
    
    private(set) lazy var totalFiatValuesETH: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(for: assetsForETH))
    }()
    
    private(set) lazy var totalFiatValuesForStableCoins: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(for: assetsForStableCoins))
    }()
    
    private(set) lazy var totalFiatValuesListedCoins: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(for: assetsForAirDrop))
    }()

    
    private func createTotalFiatValues(for assets:BehaviorRelay<[Asset]>) -> BehaviorRelay<Decimal?> {
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
}

extension WalletOptionsViewModel {
    fileprivate func updateAssetAmt(_ asset: Asset) -> Observable<Decimal?> {
        return asset.getAmtFromServerIfPossible().asObservable()
    }
    
    fileprivate func updateFiatRateToAsset(_ fiat: Fiat, asset: Asset) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: asset.coin!, fiat: fiat).asObservable().debug("get fiat rate of asset: \(fiat.name!)/\(asset.coin!.inAppName!)")
    }
}
