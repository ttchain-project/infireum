 //
 //  AssetDetailViewModel.swift
 //  OfflineWallet
 //
 //  Created by Keith Lee on 2018/7/6.
 //  Copyright © 2018年 gib. All rights reserved.
 //
 
 import UIKit
 import RxSwift
 import RxCocoa
 
 class AssetDetailViewModel: KLRxViewModel {
    struct Input {
        let asset: Asset
        let depositInput: Driver<Void>
        let withdrawalInput: Driver<Void>
        let loadMoreInput: Driver<Void>
        let refreshInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: AssetDetailViewModel.Input
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    private lazy var btcHandler: BTCTxHandler = {
        return BTCTxHandler.init(asset: input.asset, filter: BTCTxFilter())
    }()
    
    private lazy var ethHandler: ETHTxHandler = {
        return ETHTxHandler.init(asset: input.asset, filter: ETHTxFilter())
    }()
    
    private lazy var tokenHandler: TokenTxHandler = {
        return TokenTxHandler.init(specificAsset: input.asset, filter: TokenTxFilter())
    }()
    
    private lazy var cicHandler: CICTxHandler = {
        return CICTxHandler.init(specificAsset: input.asset, filter: CICTxFilter())
    }()
    
    private lazy var bnnHandler: CICTxHandler = {
        return CICTxHandler.init(specificAsset: input.asset, filter: CICTxFilter())
    }()
    
    private lazy var cfpHandler: CICTxHandler = {
        return CICTxHandler.init(specificAsset: input.asset, filter: CICTxFilter())
    }()
    
    
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        bindInternalLogic()
        
        getTransRecords(reset: false)
    }
    
    func concatInput() {
        input.loadMoreInput
            .filter { [unowned self] in !self.loading }
            .throttle(1)
            .drive(
                onNext: {
                    [unowned self]
                    _ in
                    self.getTransRecords(reset: false)
                }
            )
            .disposed(by: bag)
        
        input.refreshInput
            .throttle(1)
            .drive(onNext: {
                [unowned self] in
                self.refreshRecords()
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        //If fiat is update, should refresh rate again
        _fiat.asObservable().skip(1).distinctUntilChanged()
            .subscribe(onNext: {
                [unowned self] _ in
                self.refreshFiatRate()
            })
            .disposed(by: bag)
        
        bindTransferRecordUpdateObserve()
    }
    
    private func bindTransferRecordUpdateObserve() {
        OWRxNotificationCenter.instance.onTransferRecordCreate
            .subscribe(onNext: {
                [unowned self]
                record in
                if self.input.asset.coinID == record.fromCoinID {
                    self.refreshRecords()
                    self.refreshAmt()
                }
            })
            .disposed(by: bag)
    }
    
    
    //MARK: - Public
    public var startDeposit: Observable<Asset> {
        return input.depositInput.asObservable().map { [unowned self] in self.input.asset }
    }
    
    public var startWithdrawal: Observable<Asset> {
        return input.withdrawalInput.asObservable().map { [unowned self] in self.input.asset }
    }
    
    public var startLoading: Observable<Void> {
        return _startLoading.asObservable()
    }
    
    public var finishLoading: Observable<APIResult<Void>> {
        return _finishLoading.asObservable()
    }
    
    public var amtSource: Observable<Decimal?> {
        return _amtSource.asObservable()
    }
    
    public var records: Observable<[TransRecord]> {
        return _records.asObservable()
    }
    
    public var fiatRate: Observable<Decimal?> {
        return _fiatRate.asObservable()
    }
    
    public var fiat: Observable<Fiat> {
        return _fiat.asObservable()
    }
    
    public func refreshAmt() {
        //This will force the previous binding observable send completed event.
        amtsUpdateStopper.accept(())
        getAmtFromBlockchain().bind(to: _amtSource).disposed(by: bag)
    }
    
    public func refreshRecords() {
        //This will force the previous binding observable send completed event.
        recordsUpdateStopper.accept(())
        getTransRecords(reset: true)
    }
    
    public func refreshFiatRate() {
        fiatUpdateStopper.accept(())
        getFiatRateFromServer().bind(to: _fiatRate).disposed(by: bag)
    }
    
    //MARK: - Private
    private lazy var _startLoading: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    private lazy var _finishLoading: PublishRelay<APIResult<Void>> = {
        return PublishRelay.init()
    }()
    
    private let amtsUpdateStopper: PublishRelay<Void> = PublishRelay.init()
    
    private lazy var _amtSource: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: input.asset.amount as Decimal?)
        getAmtFromBlockchain().bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private let recordsUpdateStopper: PublishRelay<Void> = PublishRelay.init()
    
    private lazy var _records: BehaviorRelay<[TransRecord]> = {
        let relay: BehaviorRelay<[TransRecord]>
        switch input.asset.coin!.owChainType {
        case .btc:
            relay = btcHandler.records
        case .eth:
            if input.asset.coinID == Coin.eth_identifier {
                relay = ethHandler.records
            }else {
                relay = tokenHandler.records
            }
        case .cic:
            relay = cicHandler.records
        }
        
        return relay
    }()
    
    
    private var loading: Bool = false
    private func getTransRecords(reset: Bool) {
        let load: RxAPIVoidResponse
        switch input.asset.coin!.owChainType {
        case .btc:
            if reset { btcHandler.reset() }
            guard !btcHandler.didReachedSearchLine else {
                _finishLoading.accept(.success(()))
                return
            }
            
            load = btcHandler.loadCurrentPage()
        case .eth:
            if input.asset.coinID == Coin.eth_identifier {
                if reset { ethHandler.reset() }
                guard !ethHandler.didReachedSearchLine else {
                    _finishLoading.accept(.success(()))
                    return
                }
                
                load = ethHandler.loadAllRequiredTxs()
            }else {
                if reset { tokenHandler.reset() }
                guard !tokenHandler.didReachedSearchLine else {
                    _finishLoading.accept(.success(()))
                    return
                }
                
                load = tokenHandler.loadAllRequiredTxs()
            }
        case .cic:
            if reset { cicHandler.reset() }
            guard !cicHandler.didReachedSearchLine else {
                _finishLoading.accept(.success(()))
                return
            }
            
            load = cicHandler.loadCurrentPage()
        }
        
        _startLoading.accept(())
        loading = true
        load.asObservable()
            .takeUntil(recordsUpdateStopper)
            .subscribe(
                onNext: {
                    [unowned self]
                    result in
                    self._finishLoading.accept(result)
                    self.loading = false
                },
                onDisposed: {
                    [weak self] in
                    self?._finishLoading.accept(.success(()))
                    self?.loading = false
                }
            )
            .disposed(by: bag)
    }
    
    
    private lazy var _fiat: BehaviorRelay<Fiat> = {
        let id = Identity.singleton!
        return BehaviorRelay.init(value: id.fiat!)
    }()
    
    private let fiatUpdateStopper: PublishRelay<Void> = PublishRelay.init()
    
    private lazy var _fiatRate: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: getDBFiatRate())
        getFiatRateFromServer().bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private func getDBFiatRate() -> Decimal? {
        let dbRatePred = CoinToFiatRate.createPredicate(from: input.asset.coinID!, _fiat.value.id)
        let dbValue: Decimal?
        if let cTofRate = DB.instance.get(type: CoinToFiatRate.self, predicate: dbRatePred, sorts: nil)?.first {
            dbValue = cTofRate.rate! as Decimal
        }else {
            dbValue = nil
        }
        
        return dbValue
    }
 }
 
 // MARK: - Mock
 extension AssetDetailViewModel {
    /// Create the observable of the net value of asset
    fileprivate func getAmtFromBlockchain() -> Observable<Decimal?> {
        return input.asset.getAmtFromServerIfPossible().asObservable().takeUntil(amtsUpdateStopper)
    }
    
    fileprivate func getFiatRateFromServer() -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: input.asset.coin!, fiat: _fiat.value).asObservable().takeUntil(fiatUpdateStopper).debug("\(input.asset.coin!.identifier!)/\(_fiat.value.name!)")
    }
 }
