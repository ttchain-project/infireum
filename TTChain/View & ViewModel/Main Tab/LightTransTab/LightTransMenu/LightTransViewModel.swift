//
//  LightTransViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LightTransViewModel: KLRxViewModel {
   
    required init(input: LightTransViewModel.Input, output: LightTransViewModel.Output) {
        self.input = input
        self.output = output
        
        self.setupWallet()
        
        OWRxNotificationCenter.instance.ttnWalletCreated.asObservable().subscribe(onNext:{ _ in
            self.setupWallet()
        }).disposed(by:bag)
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    func setupWallet() {
        let predForTTN = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.ttn.rawValue))
        guard let ttnWallet = DB.instance.get(type: Wallet.self, predicate: predForTTN, sorts: nil)?.first else {
            return
        }
        self.ttnWallet = ttnWallet
        fetchWallets()
    }
    
    var bag: DisposeBag = DisposeBag()
    
    var input: LightTransViewModel.Input
    
    var output: LightTransViewModel.Output
    
    struct Input {
    }
    struct Output {
        
    }
    private(set) var assets: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
    
    lazy var fiat: BehaviorRelay<Fiat> = {
        return FiatManager.instance.fiat
    }()
    
    var ttnWallet: Wallet!
    
    func fetchWallets() {

        var _assets = [Asset]()
        _assets = Asset.getAllWalletAssetsUnderCurrenIdentity(wallet: ttnWallet, selectedOnly: true)
        let ttn = _assets.filter{ $0.coin?.identifier == Coin.ttn_identifier }.first
        let exr = _assets.filter{ $0.coin?.identifier == Coin.exr_identifier }.first
        let mcc = _assets.filter{ $0.coin?.identifier == Coin.mcc_identifier }.first
        let btcn = _assets.filter{ $0.coin?.identifier == Coin.btcn_identifier }.first
        let usdtn = _assets.filter{ $0.coin?.identifier == Coin.usdtn_identifier }.first
        
        self.assets.accept([ttn, usdtn, btcn, mcc, exr].compactMap{ $0 })
    }
    
    // implemented but not used as yet.
    
    /// Calling when wallet update. this function will refresh all the data source.
    func refreshAllData() {
        
        Server.instance.getTTNAssetAmt(address: self.ttnWallet.address!).asObservable().subscribe(onNext: {[weak self] (result) in
            guard let `self` = self else {
                return
            }
            switch result {
            case .success(let model):
                print(model)
                guard let balance = model.balance else {
                    return
                }
                for (k, v) in self.assetAmtTable {
                    switch k.coinID {
                    case Coin.ttn_identifier :
                        v.accept(BehaviorRelay.init(value: balance.ttnBalance))
                        k.updateAmt(balance.ttnBalance)
                    case Coin.usdtn_identifier:
                        v.accept(BehaviorRelay.init(value: balance.usdtnBalance))
                        k.updateAmt(balance.usdtnBalance)
                    case Coin.btcn_identifier:
                        v.accept(BehaviorRelay.init(value: balance.btcnBalance))
                        k.updateAmt(balance.btcnBalance)
                    case Coin.ethn_identifier:
                        v.accept(BehaviorRelay.init(value: balance.ethnBalance))
                        k.updateAmt(balance.ethnBalance)
                    case Coin.exr_identifier:
                        v.accept(BehaviorRelay.init(value: balance.exrBalance))
                        k.updateAmt(balance.exrBalance)
                    case Coin.mcc_identifier:
                        v.accept(BehaviorRelay.init(value: balance.mccBalance))
                        k.updateAmt(balance.mccBalance)
                    default:
                        continue
                    }
                }
            case .failed(error: let error):
                DLogError(error)
            }
        }).disposed(by: bag)
//        for (k, v) in fiatRateTable {
//            v.accept(createFiatRateUpater(ofAsset: k))
//        }
//
//        for (k, v) in assetFiatValueTable {
//            v.accept(createFiatValueUpater(ofAsset: k))
//        }
//
//        totalFiatValue.accept(createTotalFiatValues(for: assets))
//
        
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
        
        totalFiatValue.accept(createTotalFiatValues(for: assets))
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
    
    private(set) lazy var totalFiatValue: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(for: assets))
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
    
    fileprivate func updateAssetAmt(_ asset: Asset) -> Observable<Decimal?> {
        return asset.getAmtFromServerIfPossible().asObservable()
    }
    
    fileprivate func updateFiatRateToAsset(_ fiat: Fiat, asset: Asset) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: asset.coin!, fiat: fiat).asObservable().debug("get fiat rate of asset: \(fiat.name!)/\(asset.coin!.inAppName!)")
    }
}
