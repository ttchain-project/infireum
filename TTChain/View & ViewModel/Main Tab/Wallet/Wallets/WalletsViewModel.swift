//
//  WalletsViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class WalletsViewModel: KLRxViewModel {
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    var bag: DisposeBag = DisposeBag()
    
    var input: WalletsViewModel.Input
    var output: WalletsViewModel.Output
    
    struct Input {
        
    }
    struct Output {
        
    }
    
    lazy var fiat: BehaviorRelay<Fiat> = {
        return FiatManager.instance.fiat
    }()
    private(set) var assets: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])

    var sectionModelSources : BehaviorRelay<[SectionOfTable]> = BehaviorRelay.init(value: [])
    
    required init(input: WalletsViewModel.Input, output: WalletsViewModel.Output) {
        self.input = input
        self.output = output
        var coins = Coin.getAllCoins(of: ChainType.btc) + Coin.getAllCoins(of: ChainType.eth)
        coins = coins.filter { $0.identifier != Coin.usdt_identifier  }.filter { $0.identifier?.contains("_FIAT") == false  }.compactMap { $0 }
        self.sectionModelSources.accept(coins.map(SectionOfTable.init))
        self.assets.accept(coins.map{ coin -> [Asset] in
           let assets = Asset.getAssetsForCoin(coin: coin)
            self.coinToAssetsTable[coin] = assets
            return assets
            }.flatMap { $0 })
        
        self.dataSource.configureCell = { [weak self] (dataSource, tv, indexPath, asset) -> WalletsTableViewCell in
            guard let `self` = self else {
                return WalletsTableViewCell()
            }
            let cell = tv.dequeueReusableCell(with: WalletsTableViewCell.self, for: indexPath)
            
            let amtSource = self.amt(ofAsset: asset).asObservable()
            let fiatValueSource = self.fiatValue(ofAsset: asset).asObservable()
            let fiatSource = self.fiat.asObservable()
            
            cell.config(asset:asset,amtSource: amtSource,fiatValueSource:fiatValueSource,fiatSource:fiatSource)
            
            return cell
        }
        refreshAllData()
    }
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfTable>.init(animationConfiguration:AnimationConfiguration(insertAnimation: .fade,
                                                                                                                               reloadAnimation: .fade,
                                                                                                                               deleteAnimation: .fade)
        ,configureCell: { (dataSource, tv, indexPath, viewModel) -> UITableViewCell in
            return UITableViewCell()
    })
    
    func updateSectionModel(forSection section: Int)  {
        var sectionModelsArray = self.sectionModelSources.value
        var sectionModel = sectionModelsArray[section]

        if sectionModel.isShowing {
            sectionModel.items = []
        } else {
            let assets = self.assetsForCoin(sectionModel.header)
            sectionModel.items = assets
        }
        
        sectionModel.isShowing = !sectionModel.isShowing
        sectionModelsArray.remove(at: section)
        sectionModelsArray.insert(sectionModel, at: section)
        self.sectionModelSources.accept(sectionModelsArray)
    }

    
    
    //Setup data structure for Assets
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
        for (coin,_) in coinToAssetsTable {
            coinToAssetsTable[coin] = Asset.getAssetsForCoin(coin: coin)
        }
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
    
    private var coinToAssetsTable:[Coin:[Asset]] = [:]
    func assetsForCoin(_ coin:Coin) -> [Asset] {
        if let assets = coinToAssetsTable[coin] {
            return assets
        } else {
            return Asset.getAssetsForCoin(coin: coin)
        }
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
    
    public func totalFiatAmoutForCoin(coin:Coin) -> BehaviorRelay<BehaviorRelay<Decimal?>>{
        let assetsForCoin = self.assetsForCoin(coin)
        return BehaviorRelay.init(value: self.createTotalFiatValues(assets: assetsForCoin))
    }
    
    private(set) lazy var totalFiatValues: BehaviorRelay<BehaviorRelay<Decimal?>> = {
        return BehaviorRelay.init(value: createTotalFiatValues(assets: self.assets.value))
    }()
    
    private func createTotalFiatValues(assets:[Asset]) -> BehaviorRelay<Decimal?> {
        let source: BehaviorRelay<Decimal?> = BehaviorRelay.init(value: nil)
        let fiatValueRelays = Observable.of(assets.map { [unowned self] in self.fiatValue(ofAsset: $0) }).take(1)

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
    
    public func totalAssetAmtForCoin(coin:Coin) -> BehaviorRelay<BehaviorRelay<Decimal?>>{
        let assetsForCoin = self.assetsForCoin(coin)
        return BehaviorRelay.init(value: self.createTotalAssetAmount(assets: assetsForCoin))
    }
    
    private func createTotalAssetAmount(assets:[Asset]) -> BehaviorRelay<Decimal?> {
        let source: BehaviorRelay<Decimal?> = BehaviorRelay.init(value: nil)
        let assetValueRelays = Observable.of(assets.map { [unowned self] in self.amt(ofAsset: $0) }).take(1)
        
        let totalAssetValues = assetValueRelays.flatMapLatest({ (fiatValues) -> Observable<[Decimal?]> in
            return Observable.combineLatest(
                fiatValues.map {
                    $0.asObservable().flatMapLatest { $0 }
                }
            )
        })
        
        let sum: Observable<Decimal?> = totalAssetValues.map {
            values -> Decimal? in
            let nonOptionalVals = values.compactMap { $0 }
            if !nonOptionalVals.isEmpty {
                return nonOptionalVals
                    .reduce(0, +)
            }else {
                return nil
            }
        }
        sum.bind(to: source).disposed(by: bag)
        return source
    }
    
}

extension WalletsViewModel {
    fileprivate func updateAssetAmt(_ asset: Asset) -> Observable<Decimal?> {
        return asset.getAmtFromServerIfPossible().asObservable()
    }
    
    fileprivate func updateFiatRateToAsset(_ fiat: Fiat, asset: Asset) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: asset.coin!, fiat: fiat).asObservable().debug("get fiat rate of asset: \(fiat.name!)/\(asset.coin!.inAppName!)")
    }
}
