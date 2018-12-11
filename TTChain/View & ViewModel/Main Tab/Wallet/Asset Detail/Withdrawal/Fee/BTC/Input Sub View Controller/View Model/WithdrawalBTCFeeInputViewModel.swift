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
        if let rate = _satPerByte.value {
            return (rate: rate.satoshiToBTC, amt: 0, coin: self.input.asset.coin ?? Coin.btc, option: _feeOption.value)
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
