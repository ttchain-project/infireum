//
//  TransferRecordsListViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordsListViewModel: KLRxViewModel {
    struct Input {
        let defaultOptionProvider: RxTransRecordSortingOptionsProvider
        let refreshInput: Driver<Void>
        let nextPageInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransferRecordsListViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        
        bindInternalLogic()
    }
    
    func concatInput() {
        input.nextPageInput.drive(onNext: {
            [unowned self] in
            if let wallet = self._wallet.value {
                self.syncRecord(ofWallet: wallet, reset: false)
            }
        })
        .disposed(by: bag)
        
        input.refreshInput.drive(onNext: {
            [unowned self] in
            if let wallet = self._wallet.value {
                self.syncRecord(ofWallet: wallet, reset: true)
            }
        })
        .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _optionProvider.flatMapLatest {
                $0.selectedMainCoin
            }
            .distinctUntilChanged()
            .bind(to: _mainCoin)
            .disposed(by: bag)
        
        _optionProvider.flatMapLatest {
                $0.selectedWallet
            }
            .distinctUntilChanged()
            .bind(to: _wallet)
            .disposed(by: bag)
        
        _optionProvider.flatMapLatest {
                $0.selectedCoin
            }
            .distinctUntilChanged()
            .bind(to: _coin)
            .disposed(by: bag)
        
        _optionProvider.flatMapLatest {
                $0.selectedStatus
            }
            .distinctUntilChanged()
            .bind(to: _status)
            .disposed(by: bag)
        
        //Records update part
        _wallet.subscribe(onNext: {
            [unowned self] wallet in
            if let w = wallet {
                self.updateWallet(w)
            }
        })
        .disposed(by: bag)
        
        _records.map {
            [unowned self] in self.fileterRecordsUnderCurrentOptions(originSource: $0)
        }
        .bind(to: _filteredRecords)
        .disposed(by: bag)
        
        Observable.merge(_status.map { _ in () }, _coin.map { _ in () })
            .map {
                [unowned self] in self.fileterRecordsUnderCurrentOptions(originSource: self._records.value)
            }
            .bind(to: _filteredRecords)
            .disposed(by: bag)
    }
    
    
    
    //MARK: - Public
    public func switchInfoProvider(_ provider: RxTransRecordSortingOptionsProvider) {
        _optionProvider.accept(provider)
    }
    
    public var filteredRecords: Observable<[TransRecord]> {
        return _filteredRecords.asObservable()
    }
    
    public func getSelectedWallet() -> Wallet? {
        return _wallet.value
    }
    
    //MARK: - Private
    private lazy var _optionProvider: BehaviorRelay<RxTransRecordSortingOptionsProvider> = {
        return BehaviorRelay.init(value: input.defaultOptionProvider)
    }()
    
    private lazy var _filteredRecords: BehaviorRelay<[TransRecord]> = {
       return BehaviorRelay.init(value: [])
    }()
    
    private lazy var _records: BehaviorRelay<[TransRecord]> = {
       return BehaviorRelay.init(value: [])
    }()
    
    private lazy var _mainCoin: BehaviorRelay<Coin?> = {
       return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _wallet: BehaviorRelay<Wallet?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _coin: BehaviorRelay<Coin?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _status: BehaviorRelay<TransRecordListsStatusOptions?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private func updateWallet(_ wallet: Wallet) {
        resetHandlerIfNeeded(ofWallet: wallet)
        _records.accept([])
        _coin.accept(nil)
        
        syncRecord(ofWallet: wallet, reset: true)
    }
    
    private func resetHandlerIfNeeded(ofWallet wallet: Wallet) {
        switch wallet.owChainType {
        case .btc:
            btc_handler = nil
        case .eth:
            eth_handler = nil
            token_handler = nil
        case .cic:
            cic_handler = nil
        case .ttn:
            break
        }
    }
    
    private func syncRecord(ofWallet wallet: Wallet, reset: Bool) {
        switch wallet.owChainType {
        case .btc:
            guard let btc = wallet.getAsset(of: Coin.btc) else { return }
            btc_syncRecord(btcAsset: btc, reset: reset)
        case .eth:
            eth_syncRecord(ofWallet: wallet,
                           reset: reset,
                           optionalETHAsset: nil)
        case .cic:
            cic_syncRecord(ofWallet: wallet,
                           reset: reset,
                           optionalCICAsset: nil)
        case .ttn:
            break;
        }
    }
    
    private func fileterRecordsUnderCurrentOptions(originSource: [TransRecord]) -> [TransRecord] {
        var source = originSource
        guard !source.isEmpty else { return source }
        if let coin = _coin.value {
            source = source.filter({ (rec) -> Bool in
                return rec.fromCoinID! == coin.identifier! || rec.toCoinID! == coin.identifier!
            })
        }
        
        if let status = _status.value, let wallet = _wallet.value {
            switch status {
            case .deposit:
                source = source.filter({ (rec) -> Bool in
                    return rec.inoutRoleOfAddress(wallet.address!) == .deposit
                })
            case .withdrawal:
                source = source.filter({ (rec) -> Bool in
                    return rec.inoutRoleOfAddress(wallet.address!) == .withdrawal
                })
            case .failed:
                source = source.filter({ (rec) -> Bool in
                    return rec.owStatus == .failed
                })
            }
        }
        
        return source
    }
    
    // MARK: - Wallet Update
    
    public var onReceiveRecordsUpdateResponse: Observable<APIResult<Void>> {
        return _onReceiveRecordsUpdateResponse.asObservable()
    }
    
    private lazy var _onReceiveRecordsUpdateResponse: PublishRelay<APIResult<Void>> = {
        return PublishRelay.init()
    }()
    
    /** The Disposable whick is currently binding to the records.
        Always remember to
     */
    private var recordsBindingDisposable: Disposable?
    
    //MARK: - BTC
    private var btc_handler: BTCTxHandler!
    
    private func btc_syncRecord(btcAsset: Asset, reset: Bool) {
        //First, check if the handler if set properly. if nil or has diff asset handler, create a new one, once the handler loading callback is called, filter the result by checking the wallet address to prevent updating records of other wallets.
        guard let handler = btc_handler,let handlerAddress = handler.asset.wallet?.address, let btcAddress = btcAsset.wallet?.address,
            handlerAddress.caseInsensitiveCompare(btcAddress) == .orderedSame else {
                btc_handler = BTCTxHandler.init(asset: btcAsset, filter: BTCTxFilter())
                recordsBindingDisposable?.dispose()
                recordsBindingDisposable = btc_handler.records.bind(to: _records)

                return btc_syncRecord(btcAsset: btcAsset,
                                      reset: reset)
        }
        
        if reset { handler.reset() }
        //Try to load the page, result will be ignored if the handler has been changed.
        handler
            .loadCurrentPage()
            .filter {
                [unowned self] _ -> Bool in
                guard let currentHandler = self.btc_handler else { return false }
                return currentHandler.asset.wallet?.address?.caseInsensitiveCompare(handlerAddress) == .orderedSame
            }
            .subscribe(
                onSuccess: { [unowned self] (result) in
                    self._onReceiveRecordsUpdateResponse.accept(result)
                }
            )
            .disposed(by: bag)
    }
    
    //MARK: - ETH
    private var eth_handler: ETHTxHandler!
    private var token_handler: TokenTxHandler!
    
    private func eth_syncRecord(ofWallet wallet: Wallet,
                                reset: Bool,
                                optionalETHAsset ethAsset: Asset?) {
        if let specificAsset = ethAsset {
            switch specificAsset.coin!.identifier! {
            case Coin.eth_identifier:
                //Means user targets for eth asset records.
                guard let handler = eth_handler,
                    handler.asset.wallet!.address!.caseInsensitiveCompare(specificAsset.wallet!.address!) == .orderedSame else {
                        eth_handler = ETHTxHandler.init(asset: specificAsset, filter: ETHTxFilter())
                        recordsBindingDisposable?.dispose()
                        recordsBindingDisposable = eth_handler.records.bind(to: _records)
                        
                        return eth_syncRecord(ofWallet: wallet,
                                              reset: reset,
                                              optionalETHAsset: ethAsset)
                }
                
                if reset { handler.reset() }
                
                handler
                    .loadCurrentPage()
                    .filter {
                        [unowned self] _ -> Bool in
                        guard let currentHandler = self.eth_handler else { return false }
                        return currentHandler.asset.wallet?.address == handler.asset.wallet?.address
                    }
                    .subscribe(
                        onSuccess: { [unowned self] (result) in
                            self._onReceiveRecordsUpdateResponse.accept(result)
                        }
                    )
                    .disposed(by: bag)
            default:
                //Need to verified is ETH type coin.
                guard specificAsset.coin!.owChainType == .eth else { return }
                //So it's not ETH, must be ERC-20.
                //Need to check
                guard let handler = token_handler,
                    handler.wallet.address?.caseInsensitiveCompare(specificAsset.wallet!.address!) == .orderedSame else {
                        token_handler = TokenTxHandler.init(specificAsset: specificAsset, filter: TokenTxFilter())
                        recordsBindingDisposable?.dispose()
                        recordsBindingDisposable = token_handler.records.bind(to: _records)
                        
                        return eth_syncRecord(ofWallet: wallet,
                                              reset: reset,
                                              optionalETHAsset: ethAsset)
                }
                
                if reset { handler.reset() }
                
                handler
                    .loadCurrentPage()
                    .filter {
                        [unowned self] _ -> Bool in
                        guard let currentHandler = self.token_handler else { return false }
                        return currentHandler.wallet.address!.caseInsensitiveCompare(handler.wallet.address!) == .orderedSame
                    }
                    .subscribe(
                        onSuccess: { [unowned self] (result) in
                            self._onReceiveRecordsUpdateResponse.accept(result)
                        }
                    )
                    .disposed(by: bag)
            }
        }else {
            //Here can also use same TokenTx Handler logic, just recreate the source. by mapping the source update to local data.
            guard let handler = token_handler,
                handler.asset == nil else {
                    token_handler = TokenTxHandler.init(wallet: wallet, specificAsset: nil, filter: TokenTxFilter())
                    recordsBindingDisposable?.dispose()
                    recordsBindingDisposable =
                        token_handler
                            .records
                            .map {
                                _ in
                                TransRecord.getAllRecords(ofWallet: wallet) ?? []
                            }
                            .bind(to: _records)
                    
                    return eth_syncRecord(ofWallet: wallet,
                                          reset: reset,
                                          optionalETHAsset: ethAsset)
            }
            
            if reset { handler.reset() }
            
            handler
                .loadCurrentPage()
                .filter {
                    [unowned self] _ -> Bool in
                    guard let currentHandler = self.token_handler else { return false }
                    return currentHandler.wallet.address!.caseInsensitiveCompare(handler.wallet.address!) == .orderedSame
                }
                .subscribe(
                    onSuccess: { [unowned self] (result) in
                        self._onReceiveRecordsUpdateResponse.accept(result)
                    }
                )
                .disposed(by: bag)
        }
    }
    
    //MARK: - CIC
    private var cic_handler: CICTxHandler!
    
    private func cic_syncRecord(ofWallet wallet: Wallet,
                                reset: Bool,
                                optionalCICAsset cicAsset: Asset?) {
        if let specificAsset = cicAsset {
            //Need to verified is CIC type coin.
            guard specificAsset.coin!.owChainType == .cic else { return }
            
            //Need to check
            guard let handler = cic_handler,
                handler.wallet.address == specificAsset.wallet?.address else {
                    cic_handler = CICTxHandler.init(specificAsset: specificAsset, filter: CICTxFilter())
                    recordsBindingDisposable?.dispose()
                    recordsBindingDisposable = cic_handler.records.bind(to: _records)
                    
                    return cic_syncRecord(ofWallet: wallet,
                                          reset: reset,
                                          optionalCICAsset: cicAsset)
            }
            
            if reset { handler.reset() }
            
            handler
                .loadCurrentPage()
                .filter {
                    [unowned self] _ -> Bool in
                    guard let currentHandler = self.cic_handler else { return false }
                    return currentHandler.wallet.address == handler.wallet.address
                }
                .subscribe(
                    onSuccess: { [unowned self] (result) in
                        self._onReceiveRecordsUpdateResponse.accept(result)
                    }
                )
                .disposed(by: bag)
        
        }else {
            guard let handler = cic_handler,
                handler.asset == nil else {
                    cic_handler = CICTxHandler.init(wallet: wallet, specificAsset: nil, filter: CICTxFilter())
                    recordsBindingDisposable?.dispose()
                    recordsBindingDisposable =
                        cic_handler
                            .records
                            .map {
                                _ in
                                TransRecord.getAllRecords(ofWallet: wallet) ?? []
                            }
                            .bind(to: _records)
                    
                    return cic_syncRecord(ofWallet: wallet,
                                          reset: reset,
                                          optionalCICAsset: cicAsset)
            }
            
            if reset { handler.reset() }
            
            handler
                .loadCurrentPage()
                .filter {
                    [unowned self] _ -> Bool in
                    guard let currentHandler = self.cic_handler else { return false }
                    return currentHandler.wallet.address == handler.wallet.address
                }
                .subscribe(
                    onSuccess: { [unowned self] (result) in
                        self._onReceiveRecordsUpdateResponse.accept(result)
                    }
                )
                .disposed(by: bag)
        }
    }
}

