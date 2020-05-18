//
//  WithdrawalBTCFeeInputViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalBTCFeeInputViewModel: KLRxViewModel, WithdrawalFeeInfoProvider {
    var isFeeInfoCompleted: Observable<Bool> {
        return _satPerByte.map { $0 != nil }
    }
    
    func getFeeInfo() -> WithdrawalFeeInfoProvider.FeeInfo? {
        if let fee = _satPerByte.value {
            var coin:Coin
            if self.input.asset.coin == Coin.btc || self.input.asset.coin == Coin.USDT {
                coin = Coin.btc
            }else {
                coin = self.input.asset.coin ?? Coin.btc
            }
            return (rate: 1, amt: 0, coin: coin, option: _feeOption.value, totalHardCodedFee:fee)
        }else {
            return nil
        }
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        if _satPerByte.value != nil {
            return .valid
        }else {
            return .emptyFee
        }
    }
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let feeInfoIsDisplayedInput: Driver<Void>
        let asset:Asset
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        input.feeInfoIsDisplayedInput.map { [unowned self] in !self._isInfoDisplayed.value }.drive(_isInfoDisplayed).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    public var isInfoDisplayed: Observable<Bool> {
        return _isInfoDisplayed.asObservable()
    }
    
    public var satPerByte: Observable<Decimal?> {
        return _satPerByte.asObservable()
    }
    
    private lazy var _fiat: BehaviorRelay<Fiat> = {
        return FiatManager.instance.fiat
    }()
    
    private lazy var _fiatRate: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: CoinToFiatRate.getRateFromDatabase(coinID: input.asset.coinID!, fiatID: _fiat.value.id)?.rate as Decimal?)
        updateFiatRateToCoin(fiat: _fiat.value, coin: input.asset.coin!).bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private func updateFiatRateToCoin(fiat: Fiat, coin: Coin) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: coin, fiat: fiat).asObservable()
    }
    
    private lazy var _feeAmtFiatValue: BehaviorRelay<String?> = {
        let relay = BehaviorRelay<String?>.init(value: nil)
        Observable.combineLatest(_fiatRate, _satPerByte).map { [unowned self]
            rate, amt -> String? in
            if let r = rate, let a = amt {
                return  "≈\(self._fiat.value.symbol!) \((r * a).asString(digits: 4))"
            }else {
                return nil
            }
            }
            .bind(to: relay)
            .disposed(by: bag)
        
        return relay
    }()
    
    public var feeAmtFiatValue: Observable<String?> {
        return _feeAmtFiatValue.asObservable()
    }
    
    public func updateFee(satPerByte: Decimal?) {
        _satPerByte.accept(satPerByte)
    }
    
    public func updateFeeOption(option: FeeManager.Option?) {
        _feeOption.accept(option)
    }
    
    private lazy var _satPerByte: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _isInfoDisplayed: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: false)
    }()
    
    private lazy var _feeOption: BehaviorRelay<FeeManager.Option?> = {
        return BehaviorRelay.init(value: nil)
    }()
}
