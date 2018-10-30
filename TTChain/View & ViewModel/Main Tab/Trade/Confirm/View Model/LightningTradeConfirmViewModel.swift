//
//  LightningTradeConfirmViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LightningTradeConfirmViewModel: KLRxViewModel {
    struct Input {
        let source: LightningTransRecordCreateSource
        let remarkInOut:  ControlProperty<String?>
        let nextstepInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: LightningTradeConfirmViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        (input.remarkInOut <-> _remarkNote).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var currentSource: LightningTransRecordCreateSource {
        return packageCreateSource()
    }
    
    public var fromCoin: Observable<Coin> {
        return _fromCoin.asObservable()
    }
    
    public func getFromCoin() -> Coin {
        return _fromCoin.value
    }
    
    public var toCoin: Observable<Coin> {
        return _toCoin.asObservable()
    }
    
    public func getToCoin() -> Coin {
        return _toCoin.value
    }
    
    public var fromAmt: Observable<Decimal> {
        return _fromAmt.asObservable()
    }
    
    public var toAmt: Observable<Decimal> {
        return _toAmt.asObservable()
    }
    
    public var transRate: Observable<Decimal> {
        return _transRate.asObservable()
    }
    
    public var fromWallet: Observable<Wallet> {
        return _fromWallet.asObservable()
    }
    
    public func getFromWallet() -> Wallet {
        return _fromWallet.value
    }
    
    public var toAddress: Observable<String?> {
        return _toAddressSource.asObservable().map { $0.address }
    }
    
    public func getToAddress() -> String? {
        return _toAddressSource.value.address
    }
    
    public var feeRate: Observable<Decimal> {
        return _feeRate.asObservable()
    }
    
    public func getFeeRate() -> Decimal {
        return _feeRate.value
    }
    
    public func getFeeOption() -> FeeManager.Option? {
        return _feeOption.value
    }
    
    public func getRemarkNotes() -> String? {
        return _remarkNote.value
    }
    
    public var onFinishPackageFinalSource: Driver<LightningTransRecordCreateSource> {
        return input.nextstepInput.map {
            [unowned self] in self.packageCreateSource()
        }
    }
    
    //MARK: - Private
    private lazy var _fromCoin: BehaviorRelay<Coin> = {
        return BehaviorRelay.init(value: Coin.getCoin(ofIdentifier: input.source.from.coinID)!)
    }()
    
    private lazy var _toCoin: BehaviorRelay<Coin> = {
        return BehaviorRelay.init(value: Coin.getCoin(ofIdentifier: input.source.to.coinID)!)
    }()
    
    private lazy var _fromAmt: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.source.from.amt)
    }()
    
    private lazy var _toAmt: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.source.to.amt)
    }()
    
    private lazy var _transRate: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.source.transRate)
    }()
    
    private lazy var _fromWallet: BehaviorRelay<Wallet> = {
        guard let wallet = input.source.from.fromWallet else {
            fatalError("SHOULD HAS FROM WALLET WHEN DO CONFIRM LIGHTNING TRADE")
        }
        
        return BehaviorRelay.init(value: wallet)
    }()
    
    private lazy var _toAddressSource: BehaviorRelay<ToAddressSource> = {
        return BehaviorRelay.init(value: input.source.to.addressSource)
    }()
    
    private lazy var _feeRate: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.source.fee.rate)
    }()
    
    private lazy var _feeOption: BehaviorRelay<FeeManager.Option?> = {
        return BehaviorRelay.init(value: input.source.fee.option)
    }()
    
    private lazy var _remarkNote: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    //MARK: - Update
    public func updateFromWallet(_ wallet: Wallet) {
        _fromWallet.accept(wallet)
    }
    
    public func updateToAddressSource(_ source: ToAddressSource) {
        _toAddressSource.accept(source)
    }
    
    
    /// Update the fee option user selected
    ///
    /// - Parameters:
    ///   - rate: fee rate
    ///   - option: fee option, nil is manual mode.
    public func updateFeeOption(rate: Decimal, option: FeeManager.Option?) {
        if let _option = option {
            switch _option {
            case .btc: _feeRate.accept(FeeManager.getValue(fromOption: _option).satoshiToBTC)
            case .cic: _feeRate.accept(rate)
            default: _feeRate.accept(rate)
            }
        }else {
            _feeRate.accept(rate)
        }
        
        _feeOption.accept(option)
    }
    
    //MARK: - Info Package
    private func packageCreateSource() -> LightningTransRecordCreateSource {
        let source = input.source
        return LightningTransRecordCreateSource(
            from: LightningTransRecordCreateSource.From(coinID: source.from.coinID, amt: source.from.amt, address: _fromWallet.value.address!),
            to: LightningTransRecordCreateSource.To(coinID: source.to.coinID, amt: source.to.amt, addressSource: _toAddressSource.value),
            transRate: source.transRate,
            fee: LightningTransRecordCreateSource.Fee(coinID: source.fee.coinID, amt: source.fee.amt, rate: _feeRate.value, option: _feeOption.value),
//            wallet: _fromWallet.value,
            status: source.status,
            date: Date(),
            confirmations: 0,
            txID: source.txID,
            note: self.getRemarkNotes(),
            block: source.block
        )
    }
}
