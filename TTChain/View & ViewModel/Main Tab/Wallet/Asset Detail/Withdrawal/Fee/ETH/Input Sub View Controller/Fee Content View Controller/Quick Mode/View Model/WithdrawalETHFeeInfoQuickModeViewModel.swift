//
//  WithdrawalETHFeeInfoQuickModeViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalETHFeeInfoQuickModeViewModel: KLRxViewModel, WithdrawalETFFeeInfoModeBase {
    struct Input {
        let defaultGasPrice: Decimal
        let maxGasPrice: Decimal
        let minGasPrice: Decimal
        let percentageUpdateInout: ControlProperty<Float>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalETHFeeInfoQuickModeViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        twoWayBind(
            property: input.percentageUpdateInout, relay: _gasPrice,
            toVariable: {
                [unowned self]
                percentage in
                return self.gasPriceAtPercentage(percentage)
            },
            toProperty: {
                [unowned self]
                gasPrice in
                self.percentageAtGasPrice(gasPrice)
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public func updateGas(_ gas: Decimal?) {
        warning("Should not update gas in the quick mode")
        return
    }
    
    public func updateGasPrice(_ gasPrice: Decimal?) {
        if let p = gasPrice {
            _gasPrice.accept(p)
        }else {
            warning("Should not pass nil gas price to quick mode")
        }
    }
    
    public var gasInfo: Observable<(gasPrice: Decimal?, gas: Decimal?)> {
        return Observable
            .combineLatest(
                gasPrice, Observable.just(FeeManager.getValue(fromOption: .eth(.gas)))
            )
            .map {
                (gasPrice: $0, gas: $1)
            }
    }
    
    public var gasPrice: Observable<Decimal> {
        return _gasPrice.asObservable()
    }

    public func getGasPrice() -> Decimal {
        return _gasPrice.value
    }
    
    //MARK - Private
    private lazy var _gasPrice: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.defaultGasPrice)
    }()
    
    
    private func gasPriceAtPercentage(_ percentage: Float) -> Decimal {
        let gasPrice = input.minGasPrice + ((input.maxGasPrice - input.minGasPrice) * Decimal.init(Double(percentage)))
        
        return min(input.maxGasPrice, max(input.minGasPrice, gasPrice))
    }
    
    private func percentageAtGasPrice(_ price: Decimal) -> Float {
        let percent = (price - input.minGasPrice) / (input.maxGasPrice - input.minGasPrice)
        let dPercent = percent.doubleValue
        return Float(dPercent)
    }
}
