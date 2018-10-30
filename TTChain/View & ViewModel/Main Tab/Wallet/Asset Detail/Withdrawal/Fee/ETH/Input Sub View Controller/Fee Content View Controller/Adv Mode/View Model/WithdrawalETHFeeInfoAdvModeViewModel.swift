//
//  WithdrawalETHFeeInfoAdvModeViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalETHFeeInfoAdvModeViewModel: KLRxViewModel, WithdrawalETFFeeInfoModeBase {
    var gasInfo: Observable<(gasPrice: Decimal?, gas: Decimal?)> {
        return Observable.combineLatest(gasPrice, gas).map {
            (gasPrice: $0, gas: $1)
        }
    }
    
    func updateGas(_ gas: Decimal?) {
        _gas.accept(gas)
    }
    
    func updateGasPrice(_ gasPrice: Decimal?) {
        _gasPrice.accept(gasPrice)
    }
    
    struct Input {
        let gasPriceInout: ControlProperty<String?>
        let gasInout: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalETHFeeInfoAdvModeViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        twoWayBind(
            property: input.gasPriceInout,
            relay: _gasPrice,
            toVariable: { str in
                Decimal.init(string: str ?? "")
            },
            toProperty: { rate in
                rate?.asString(digits: 0)
            })
            .disposed(by: bag)
        
        twoWayBind(
            property: input.gasInout,
            relay: _gas,
            toVariable: { str in Decimal.init(string: str ?? "") },
            toProperty: { rate in rate?.asString(digits: 0) }
            )
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var gasPrice: Observable<Decimal?> {
        return _gasPrice.asObservable()
    }
    
    public var gas: Observable<Decimal?> {
        return _gas.asObservable()
    }
    
    //MARK: - Private
    private lazy var _gasPrice: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _gas: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
}
