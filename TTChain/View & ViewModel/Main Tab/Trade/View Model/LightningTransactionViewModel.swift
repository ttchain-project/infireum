//
//  LightningTransactionViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LTTxSourceHandler {
    var fromCoins: [Coin]
    var fromWallets: [Wallet?] = [nil]
    var toCoins: [Coin] = []
    var toWallets: [Wallet?] = [nil]
    
    init(defaultFromCoins: [Coin], defaultFromCoin: Coin? = nil) {
        self.fromCoins = defaultFromCoins
        if let defaultCoin = defaultFromCoin ?? defaultFromCoins.first {
            changeResourceBasedOnSelectedFromCoin(defaultCoin)
        }
    }
    
    func changeResourceBasedOnSelectedFromCoin(_ fromCoin: Coin) {
        let wallets = Wallet.getWallets(ofMainCoinID: fromCoin.walletMainCoinID!)
        fromWallets = wallets.isEmpty ? [nil] : wallets
        
        let ltTxAbleToCoins = Coin.lightningTransactionToCoins(withFromCoin: fromCoin)
        toCoins = ltTxAbleToCoins
        if let defaultToCoin = toCoins.first {
            changeResourceBasedOnSelectedToCoin(defaultToCoin)
        }
    }
    
    func changeResourceBasedOnSelectedToCoin(_ toCoin: Coin) {
        toWallets = [nil] + Wallet.getWallets(ofMainCoinID: toCoin.walletMainCoinID!)
    }
}

class LightningTransactionViewModel: KLRxViewModel {
    struct Input {
        let fromAmtStrInout: ControlProperty<String?>
        let transferInput: Driver<Void>
        let defaultFromCoins: [Coin]
        let defaultFromCoin: Coin
        let defaultToCoins: [Coin]
        let defaultToCoin: Coin
    }
    
    
    public var optionSource: LTTxSourceHandler { return _optionSource }
    private lazy var _optionSource: LTTxSourceHandler = {
        return LTTxSourceHandler.init(defaultFromCoins: input.defaultFromCoins,
                                      defaultFromCoin: input.defaultFromCoin)
    }()
    
    public var idx_currentSelectedFromCoin: Int? {
        return _optionSource.fromCoins.index(where: {
            $0.identifier == _packager.getFromCoin().identifier
        })
    }
    
    public var idx_currentSelectedFromWallet: Int? {
        return _optionSource.fromWallets.index(where: {
            $0 == _packager.getFromWallet()
        })
    }
    
    public var idx_currentSelectedToCoin: Int? {
        return _optionSource.toCoins.index(where: {
            $0.identifier == _packager.getToCoin().identifier
        })
    }
    
    public var idx_currentSelectedToWallet: Int? {
        return _optionSource.toWallets.index(where: {
            $0 == _packager.getToWallet()
        })
    }
    
    //MARK: - Coin/Asset Selections API
    public func selectFromWallet(_ fWallet: Wallet?) {
        let fCoin = _packager.getFromCoin()
        selectFromCoin(fCoin, wallet: fWallet)
    }
    
    public func selectFromCoin(_ fCoin: Coin, wallet: Wallet?) {
        guard !Coin.lightningTransactionToCoins(withFromCoin: fCoin).isEmpty else {
            //Attemp create some no-exist match of coin selection.
            //return immediately,
            //In future should support all cic type trans.
            return
        }
        
        let currentSelectedCoin = _packager.getFromCoin()
        if fCoin.identifier != currentSelectedCoin.identifier  {
            //Determine if wallets resource should change or not
            _optionSource.changeResourceBasedOnSelectedFromCoin(fCoin)
        }else {
            guard _packager.getFromWallet() != wallet else {
                //If enter here, means both coin and wallet are same, return immediately.
                return
            }
        }
        
        let fromWalletToUse: Wallet?
        if let w = wallet {
            fromWalletToUse = w
        }else {
            fromWalletToUse = _optionSource.fromWallets.first ?? nil
        }
        
        _packager.setSourceOfFrom(coin: fCoin, wallet: fromWalletToUse, updateAmtIfPossible: true)
        
        //Determine if the new fCoin will force toCoins resource to update
        let newToCoins = _optionSource.toCoins
        let currentSelectedToCoin = _packager.getToCoin()
        if newToCoins.contains(where: { $0.identifier == currentSelectedToCoin.identifier }) {
            //Means the new toCoins also contain the origin selected coin, then
            //don't change this selection, as system support this match as well.
        }else {
            //Ensure there's at least one support toCoin
            if let newSelectedToCoins = newToCoins.first {
                //Update to the new toWallets
                _optionSource.changeResourceBasedOnSelectedToCoin(newSelectedToCoins)
                //Update the selected source to the first selected wallet
                _packager.setSourceOfTo(coin: newSelectedToCoins,
                                        wallet: _optionSource.toWallets.first ?? nil,
                                        updateAmtIfPossible: true)
            }else {
                //THIS SHOULD NOT HAPPEN
                return errorDebug(response: ())
            }
        }
    }
    
    public func selectToWallet(_ tWallet: Wallet?) {
        let tCoin = _packager.getToCoin()
        selectToCoin(tCoin, wallet: tWallet)
    }

    public func selectToCoin(_ tCoin: Coin, wallet: Wallet?) {
        let currentSelectedCoin = _packager.getToCoin()
        if tCoin.identifier != currentSelectedCoin.identifier {
            //the source update the available wallets list.
            _optionSource.changeResourceBasedOnSelectedToCoin(tCoin)
        }else {
            guard _packager.getToWallet() != wallet else {
                //If enter here, means both coin and wallet are same, return immediately.
                return
            }
        }

        _packager.setSourceOfTo(coin: tCoin,
                                wallet: wallet,
                                updateAmtIfPossible: true)
    }
    
    typealias InputSource = Input
    var input: LightningTransactionViewModel.Input
    
    typealias OutputSource = Void
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        concatInput()
        refreshRecords()
    }
    
    func concatInput() {
        bindBidirectionalFromAmtUpdate()
//        bindFromCoinChangeToToCoinSourcesUpdate()
//        bindToCoinChange()
        bindTransferInput()
        bindLightningTransferRecordUpdateObserve()
        observeWalletDeletion()
    }
    
    private func bindLightningTransferRecordUpdateObserve() {
        OWRxNotificationCenter.instance.onLightningTransferRecordCreate
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.refreshRecords()
            })
            .disposed(by: bag)
    }
    
    public var onStartTransferWithCreateSource: Observable<LightningTransRecordCreateSource> {
        return _onStartTransferWithCreateSource.asObservable()
    }
    private let _onStartTransferWithCreateSource: PublishRelay<LightningTransRecordCreateSource> = PublishRelay.init()
    
    public var onFindOutInvalidInfoWhilePackageTransferInfo: Observable<LightningTransInfoValidity> {
        return _onFindOutInvalidInfoWhilePackageTransferInfo.asObservable()
    }
    
    private let _onFindOutInvalidInfoWhilePackageTransferInfo: PublishRelay<LightningTransInfoValidity> = PublishRelay.init()
    
    private func bindTransferInput() {
        input.transferInput.asObservable().flatMapLatest {
                [unowned self] _ -> Observable<LightningTransRecordCreateSource> in
                do {
                    let observ = try self._packager.packageIntoCreateSource()
                    return observ
                }
                catch let err {
                    let e = err as! LightningTransInfoValidity
                    self._onFindOutInvalidInfoWhilePackageTransferInfo.accept(e)
                    return Observable.never()
                }
            }
            .subscribe(
                onNext:{
                    [unowned self] in
                    self._onStartTransferWithCreateSource.accept($0)
                }
            )
            .disposed(by: bag)
    
    }
    
    private func bindBidirectionalFromAmtUpdate() {
        (input.fromAmtStrInout <-> _fromAmtStr).disposed(by: bag)
        _fromAmtStr.map {
            str -> Decimal? in
            if let _str = str {
                return Decimal.init(string: _str)
            }else {
                return nil
            }
            }
            .subscribe(onNext: {
                [unowned self] amt in
                self._packager.updateFromAmt(amt)
            })
            .disposed(by: bag)
    }
    
    private func observeWalletDeletion() {
        OWRxNotificationCenter.instance.walletDeleted
            .subscribe(onNext: {
                [unowned self]
                wallet in
                guard let fromWallet = self._packager.getFromWallet(),
                    let toWallet = self._packager.getToWallet() else {
                        return
                }
                
                if fromWallet == wallet {
                    let coin = self._packager.getFromCoin()
                    self.optionSource
                        .changeResourceBasedOnSelectedFromCoin(coin)
                    self._packager.setSourceOfFrom(coin: coin, wallet: nil)
                }
                
                
                if toWallet == wallet {
                    let coin = self._packager.getToCoin()
                    self.optionSource
                        .changeResourceBasedOnSelectedToCoin(coin)
                    self._packager.setSourceOfTo(coin: coin, wallet: nil)
                }
                
                
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Transfer Match
    public var packager: LightningTransMatchInfoPackager {
        return _packager
    }
    
    private lazy var _packager: LightningTransMatchInfoPackager = {
        return LightningTransMatchInfoPackager.init(
            identity: Identity.singleton!,
            defaultFromCoin: input.defaultFromCoin,
            defaultToCoin: input.defaultToCoin
        )
    }()
    
    public var selectedFromWallet: Observable<Wallet?> {
        return _packager.fromWallet
    }
    
    public var selectedFromCoin: Observable<Coin> {
        return _packager.fromCoin.distinctUntilChanged()
    }
    
    public var selectedFromAssetAmt: Observable<Decimal?> {
        return _packager.fromAsset.map { $0?.amount as Decimal? }
    }
    
    public func getSelectedFromCoin() -> Coin {
        return _packager.getFromCoin()
    }
    
    public var selectedToWallet: Observable<Wallet?> {
        return _packager.toWallet
    }
    
    public var selectedToCoin: Observable<Coin> {
        return _packager.toCoin.distinctUntilChanged()
    }
    
    public var selectedToAssetAmt: Observable<Decimal?> {
        return _packager.toAsset.map { $0?.amount as Decimal? }
    }
    
    public func getSelectedToCoin() -> Coin {
        return _packager.getToCoin()
    }
    
    public var toAmt: Observable<Decimal?> {
        return _packager.toAmt
    }
    
    public var transRate: Observable<Decimal?> {
        return _packager.transRate
    }
    
    private lazy var _fromAmtStr: BehaviorRelay<String?> = {
        return .init(value: nil)
    }()
    
    //MARK: - Records
    public var records: Observable<[LightningTransRecord]> {
        return _records.asObservable()
    }
    
    private lazy var _records: BehaviorRelay<[LightningTransRecord]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    private func refreshRecords() {
        if let recs = DB.instance.get(type: LightningTransRecord.self, predicate: nil, sorts: nil)?.sorted(by: { (r1, r2) -> Bool in
            return (r1.date! as Date) > (r2.date! as Date)
        }) {
            _records.accept(recs)
        }
    }
    
    //MARK: - Helper
    public func refreshTransRate() {
        return _packager.refreshTransRateOfCurrentMatch()
    }
    
//    public func changeFromCoin(to fCoin: Coin) {
//        guard let tCoin = Coin.lightningTransactionToCoins(withFromCoin: fCoin).first else {
//            warning("No toCoin to trade in lightning trade from coin: \(fCoin.name!)")
//            return
//        }
//
//        _packager.changeFromCoin(from: fCoin, withDefaultToCoin: tCoin)
//    }
    
    public func updateFromAmt(_ amt: Decimal) {
        _packager.updateFromAmt(amt)
        _fromAmtStr.accept(amt.asString(digits: 18))
    }
}
