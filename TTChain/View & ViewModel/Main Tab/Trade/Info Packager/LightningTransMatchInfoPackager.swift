//
//  LightningTransMatchInfoPackager.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

enum LightningTransInfoValidity: Error {
    case valid
    case noFromAsset
    case emptyFromAmt
    //This will be mainly caused from no rate data.
    case unableToCalculateToAmt
    case insuffientFromAmt
}

class LightningTransMatchInfoPackager {
    
    enum Source {
        //Specify there's a asset to use
        case asset(Asset)
        //Non-specify asset, just the coin type.
        case coin(Coin, wallet: Wallet?)
        
        var coin: Coin {
            switch self {
            case .asset(let asset):
                return asset.coin!
            case .coin(let coin, _):
                return coin
            }
        }
        
        var asset: Asset? {
            switch self {
            case .asset(let a): return a
            case .coin: return nil
            }
        }
        
        var wallet: Wallet? {
            switch self {
            case .coin(_, wallet: let w): return w
            case .asset(let a): return a.wallet
            }
        }
    }
    
    var bag: DisposeBag = DisposeBag.init()
    var requestIdentity: Identity
    
    required init(identity: Identity,
                  defaultFromCoin fromCoin: Coin,
                  defaultToCoin toCoin: Coin) {
        
        requestIdentity = identity
        _toSource = BehaviorRelay.init(value: .coin(toCoin, wallet: nil))
        
        if let asset = LightningTransMatchInfoPackager.firstAssetWithAmtGreaterThanTransferAmt(
                identity: identity, fromCoin: fromCoin, transferAmt: 0
            ) {
            _fromSource = BehaviorRelay.init(value: .asset(asset))
            setSourceOfFrom(asset: asset, updateAmtAsWell: true)
        }else {
            _fromSource = BehaviorRelay.init(value: .coin(fromCoin, wallet: nil))
        }
        
        bindCoinMatchUpdateToFeeRateRefresh()
        observeCoinSelectionInsertOrDelete()
    }
    
    private func observeCoinSelectionInsertOrDelete() {
        OWRxNotificationCenter.instance.willDeleteCoinSelection
            .subscribe(onNext: {
                [unowned self]
                sel in
                self.changeSourceIfNeeded(deletedCoinSel: sel)
            })
            .disposed(by: bag)
        
        OWRxNotificationCenter.instance.didInsertCoinSelection
            .subscribe(onNext: {
                [unowned self]
                sel in
                self.changeSourceIfNeeded(insertedCoinSel: sel)
            })
            .disposed(by: bag)
    }
    
    private func changeSourceIfNeeded(deletedCoinSel sel: CoinSelection) {
        switchSourceIfNeeded(source: _fromSource, deletedSel: sel, isFromSource: true)
        switchSourceIfNeeded(source: _toSource, deletedSel: sel, isFromSource: false)
    }
    
    private func changeSourceIfNeeded(insertedCoinSel sel: CoinSelection) {
        switchSourceIfNeeded(source: _fromSource, insertedSel: sel, isFromSource: true)
        switchSourceIfNeeded(source: _toSource, insertedSel: sel, isFromSource: false)
    }
    
    private func switchSourceIfNeeded(source: BehaviorRelay<Source>, deletedSel sel: CoinSelection, isFromSource: Bool) {
        switch source.value {
        case .asset(let asset):
            let assetIsDeleted = asset.isDeleted || asset.walletEPKey == nil
            if assetIsDeleted || (asset.walletEPKey == sel.walletEPKey && asset.coinID == sel.coinIdentifier) {
                //Because asset has been removed, change to coin type.
                //To source should switch to nil.
                let wallet: Wallet? = isFromSource ? sel.wallet : nil
                source.accept(.coin(sel.coin!, wallet: wallet))
            }
        case .coin: return
        }
    }
    
    private func switchSourceIfNeeded(source: BehaviorRelay<Source>, insertedSel sel: CoinSelection, isFromSource: Bool) {
        switch source.value {
        case .asset: return
        case .coin(let coin, wallet: let wallet):
            if let asset = sel.findAsset(),
                asset.coinID == coin.identifier,
                asset.walletEPKey == wallet?.encryptedPKey {
                //if able to find the asset of selection (in theory it should), change to asset type
                //At the same time, try to update the amt as well
                if isFromSource {
                    let fromAsset = _fromSource.value.asset
                    
                    if fromAsset == nil ||
                        (asset.coinID == fromAsset?.coinID && asset.walletEPKey == fromAsset?.walletEPKey) {
                        setSourceOfFrom(asset: asset, updateAmtAsWell: true)
                    }
                }else {
                    let toAsset = _toSource.value.asset
                    if toAsset == nil ||
                        (asset.coinID == toAsset?.coinID && asset.walletEPKey == toAsset?.walletEPKey) {
                        setSourceOfTo(asset: asset, updateAmtAsWell: true)
                    }
                }
            }
        }
    }
    
    //MARK: - Public
    public var fromSource: Observable<Source> {
        return _fromSource.asObservable()
    }
    
    public var toSource: Observable<Source> {
        return _toSource.asObservable()
    }
    
    public var transRate: Observable<Decimal?> {
        return _transRate.asObservable()
    }
    
    public var fromCoin: Observable<Coin> {
        return _fromSource.map { $0.coin }
    }
    
    public var fromWallet: Observable<Wallet?> {
        return _fromSource.map { $0.wallet }
    }
    
    public var fromAsset: Observable<Asset?> {
        return _fromSource.map { $0.asset }
    }
    
    public var toCoin: Observable<Coin> {
        return _toSource.map { $0.coin }
    }
    
    public var toWallet: Observable<Wallet?> {
        return _toSource.map { $0.wallet }
    }
    
    public var toAsset: Observable<Asset?> {
        return _toSource.map { $0.asset }
    }
    
    public func updateFromAmt(_ amt: Decimal?) {
        _fromAmt.accept(amt)
    }

    public func setSourceOfFrom(asset: Asset, updateAmtAsWell: Bool = false) {
        if updateAmtAsWell {
            asset
                .getAmtFromServerIfPossible()
                .subscribe(onSuccess: {
                    [unowned self]
                    _ in
                    switch self._fromSource.value {
                    case .asset(let _asset):
                        if _asset == asset {
                            self._fromSource.accept(.asset(asset))
                        }
                    case .coin: return
                    }
                })
                .disposed(by: bag)
        }
        
        _fromSource.accept(.asset(asset))
    }
    
    public func setSourceOfFrom(coin: Coin, wallet: Wallet?, updateAmtIfPossible: Bool = false) {
        if let _wallet = wallet,
            let asset = _wallet.getAsset(of: coin) {
            setSourceOfFrom(asset: asset, updateAmtAsWell: updateAmtIfPossible)
        }else {
            _fromSource.accept(.coin(coin, wallet: wallet))
        }
    }
    
    //Set the "to" type to only
    public func setSourceOfTo(asset: Asset, updateAmtAsWell: Bool = false) {
        if updateAmtAsWell {
            asset
                .getAmtFromServerIfPossible()
                .subscribe(onSuccess: {
                    [unowned self]
                    _ in
                    switch self._toSource.value {
                    case .asset(let _asset):
                        if _asset == asset {
                            self._toSource.accept(.asset(asset))
                        }
                    case .coin: return
                    }
                })
                .disposed(by: bag)
        }
        
        _toSource.accept(.asset(asset))
    }
    
    public func setSourceOfTo(coin: Coin, wallet: Wallet?, updateAmtIfPossible: Bool = false) {
        if let _wallet = wallet,
            let asset = _wallet.getAsset(of: coin) {
            setSourceOfTo(asset: asset, updateAmtAsWell: updateAmtIfPossible)
        }else {
            _toSource.accept(.coin(coin, wallet: wallet))
        }
    }
    //MARK: - From
    public func getFromAsset() -> Asset? {
        return _fromSource.value.asset
    }
    
    public func getFromCoin() -> Coin {
        return _fromSource.value.coin
    }
    
    public func getFromWallet() -> Wallet? {
        return _fromSource.value.wallet
    }
    
    public var fromAmt: Observable<Decimal?> { return _fromAmt.asObservable() }
    private let _fromAmt: BehaviorRelay<Decimal?> = BehaviorRelay.init(value: nil)
    
    //MARK: - To
    public func getToWallet() -> Wallet? {
        return _toSource.value.wallet
    }
    
    public func getToAsset() -> Asset? {
        return _toSource.value.asset
    }
    
    public func getToCoin() -> Coin {
        return _toSource.value.coin
    }
    
    //MARK: - Private
    //Must init in initializer
    private let _fromSource: BehaviorRelay<Source>
    //Must init in initializer
    private let _toSource: BehaviorRelay<Source>
    
    private func bindCoinMatchUpdateToFeeRateRefresh() {
        Observable.combineLatest(fromCoin, toCoin)
            .subscribe(onNext: {
                [unowned self] _ in self.refreshTransRateOfCurrentMatch()
            })
            .disposed(by: bag)
    }
    
    var toAmt: Observable<Decimal?> {
        return Observable.combineLatest(fromAmt, transRate).map {
            fromAmt, rate in
            if let amt = fromAmt, let r = rate {
                return amt * r
            } else {
                return nil
            }
        }
    }
    
    //MARK: - Transfer Rate
    
    private let _transRate: BehaviorRelay<Decimal?> = BehaviorRelay.init(value: nil)
    private let rateUpdateCancel: PublishRelay<Void> = PublishRelay.init()
    private func cancelAllUpdatingRates() {
        rateUpdateCancel.accept(())
    }
    
    func refreshTransRateOfCurrentMatch() {
        cancelAllUpdatingRates()
        
        let fc = getFromCoin()
        let tc = getToCoin()
        createCoinRateUpdateStream(from: fc, to: tc)
            .takeUntil(rateUpdateCancel)
            .bind(to: _transRate)
            .disposed(by: bag)
    }
    
    private func createCoinRateUpdateStream(from: Coin, to: Coin) -> Observable<Decimal?> {
        let singleObserv = CoinRate.getRateFromServerIfPossible(fromCoin: from, toCoin: to)
        return singleObserv.asObservable()
    }
    
    func checkInfoValidity() -> LightningTransInfoValidity {
        guard let fromAsset = getFromAsset() else { return .noFromAsset }
        guard let fAmt = _fromAmt.value else { return .emptyFromAmt }
        guard let assetAmt = fromAsset.amount as Decimal?,
            assetAmt >= fAmt else {
                return .insuffientFromAmt
        }
        
        guard _transRate.value != nil else { return .unableToCalculateToAmt }
        
        return .valid
    }
    
    //MARK: - Helper
    private static func firstAssetWithAmtGreaterThanTransferAmt(identity: Identity, fromCoin: Coin, transferAmt: Decimal?) -> Asset? {
        guard let wallets = identity.wallets?.array as? [Wallet] else { return nil }
        
        let targetWallets = wallets.filter { $0.owChainType == fromCoin.owChainType }
        guard !targetWallets.isEmpty else { return nil }
        for tWallet in targetWallets {
            guard let assets = tWallet.assets?.array as? [Asset] else {
                continue
            }
            
            for asset in assets where asset.coinID! == fromCoin.identifier! {
                guard let amt = transferAmt, amt > 0 else { return asset }
                if let assetAmt = asset.amount as Decimal?, assetAmt >= amt {
                    return asset
                }
            }
        }
        
        return nil
    }
    
    
    //MARK: - Packaging (Fianl Stage)
    
    /// Will first ensure the validity first, throw error if is not valid. then update the cic fee rate, finally create the source.
    ///
    /// - Returns:
    /// - Throws:
    public func packageIntoCreateSource() throws -> Observable<LightningTransRecordCreateSource> {
        let validity = checkInfoValidity()
        guard validity == .valid else { throw validity }
        let feeUpdate: RxAPIVoidResponse
        switch getFromCoin().owChainType {
        case .btc:
            feeUpdate = FeeManager.updateBTCFeeRates()
        case .eth:
            feeUpdate = FeeManager.updateETHFeeRates()
        case .cic:
            let fromMainCoinID = getFromCoin().walletMainCoinID!
            feeUpdate = FeeManager.updateCICFeeRates(mainCoinID: fromMainCoinID)
        case .ttn:
            feeUpdate = FeeManager.updateETHFeeRates()
        }
        
        return feeUpdate
            .asObservable()
            .map {
                [unowned self] _ in
                self.packSource()
            }
            .concat(Observable.never())
        
    }
    
    private func packSource() -> LightningTransRecordCreateSource {
        let fc = getFromCoin()
        let tc = getToCoin()
        let fAmt = _fromAmt.value!
        let rate = _transRate.value!
        let tAmt = fAmt * rate
        
        //This force unwrapping is safe as the validity check will guarantee the asset is exist
        let fromAsset = getFromAsset()!
        let toAddressSource: ToAddressSource
        if let toWallet = getToWallet() {
            toAddressSource = .local(wallet: toWallet)
        }else {
            toAddressSource = .remote(addr: nil)
        }
        
        let feeAmt: Decimal
        
        let feeOption: FeeManager.Option
        let feeRate: Decimal
        let feeID: String
        switch fc.owChainType {
        case .cic:
            feeAmt = FeeManager.systemDefaultCICFeeAmt
            feeOption = .cic(.gasPrice(.suggest(mainCoinID: fc.walletMainCoinID!)))
            
            let digit = Int(fc.digit)
            feeRate = FeeManager.getValue(fromOption: feeOption).power(digit * -1)
            feeID = fc.walletMainCoinID!
        case .btc:
            feeAmt = FeeManager.systemDefaultBTCFeeAmt
            feeOption = .btc(.regular)
            feeRate = FeeManager.getValue(fromOption: feeOption).satoshiToBTC
            feeID = Coin.btc_identifier
        case .eth,.ttn:
            //This should not happened
            fatalError()
        }
        
        return LightningTransRecordCreateSource(
            from: LightningTransRecordCreateSource.From(
                coinID: fc.identifier!, amt: fAmt, address: fromAsset.wallet!.address!
            ),
            to: LightningTransRecordCreateSource.To(
                coinID: tc.identifier!, amt: tAmt, addressSource: toAddressSource
            ),
            transRate: _transRate.value!,
            fee: LightningTransRecordCreateSource.Fee(coinID: feeID, amt: feeAmt, rate: feeRate, option: feeOption),
            //            wallet: fromAsset.wallet!,
            status: .success,
            date: Date(),
            confirmations: 0,
            txID: nil,
            note: nil,
            block: 0
        )
    }
}
