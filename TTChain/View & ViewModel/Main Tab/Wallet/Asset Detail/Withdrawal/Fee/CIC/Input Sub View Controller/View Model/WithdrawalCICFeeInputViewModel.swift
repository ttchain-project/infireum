//
//  WithdrawalCICFeeInfoViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalCICFeeInputViewModel: KLRxViewModel, WithdrawalFeeInfoProvider {
    var isFeeInfoCompleted: Observable<Bool> {
        return input.gasProvider.isFeeInfoCompleted
    }
    
    func getFeeInfo() -> WithdrawalFeeInfoProvider.FeeInfo? {
        return input.gasProvider.getFeeInfo()
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        return input.gasProvider.checkValidity()
    }
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let fiat: Fiat
        let feeInfoIsDisplayedInput: Driver<Void>
        let gasProvider: WithdrawalCICFeeInfoBase
        let mainCoinID: String
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
    
    //    public var totalGas: Observable<Decimal?> {
    //        return Observable.combineLatest(gas, gasPrice)
    //            .map {
    //                gas, gasPrice -> Decimal? in
    //                guard let g = gas, let gp = gasPrice else {
    //                    return nil
    //                }
    //
    //                return g * gp
    //            }
    //    }
    //
    public var totalGasFiatValue: Observable<Decimal?> {
        return Observable.combineLatest(input.gasProvider.totalGas, _fiatRate.asObservable())
            .map {
                total, rate -> Decimal? in
                guard let t = total, let r = rate else { return nil }
                return t * r
        }
    }
    
    //    public var gas: Observable<Decimal?> {
    //        return _gas.asObservable()
    //    }
    //
    //    public var gasPrice: Observable<Decimal?> {
    //        return _gasPrice.asObservable()
    //    }
    //
    //    public func updateGasPrice(_ gasPrice: Decimal?) {
    //        _gasPrice.accept(gasPrice)
    //    }
    //
    //    public func updateGas(_ gas: Decimal?) {
    //        _gas.accept(gas)
    //    }
    
    //    public func updateFeeOption(option: FeeManager.Option?) {
    //        _feeOption.accept(option)
    //    }
    
    //    private lazy var _gas: BehaviorRelay<Decimal?> = {
    //        return BehaviorRelay.init(value: nil)
    //    }()
    //
    //    private lazy var _gasPrice: BehaviorRelay<Decimal?> = {
    //        return BehaviorRelay.init(value: nil)
    //    }()
    //
    private lazy var _isInfoDisplayed: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: false)
    }()
    //
    //    private lazy var _feeOption: BehaviorRelay<FeeManager.Option?> = {
    //        return BehaviorRelay.init(value: nil)
    //    }()
    
    private lazy var _fiatRate: BehaviorRelay<Decimal?> = {
        let dbRate = CoinToFiatRate.getRateFromDatabase(coinID: Coin.cic_identifier, fiatID: input.fiat.id)?.rate
        let relay = BehaviorRelay<Decimal?>.init(value: dbRate as Decimal?)
        
        CoinToFiatRate.getRateFromServerIfPossible(coin: Coin.cic, fiat: input.fiat)
            .asObservable()
            .bind(to: relay)
            .disposed(by: bag)
        
        return relay
    }()
}
