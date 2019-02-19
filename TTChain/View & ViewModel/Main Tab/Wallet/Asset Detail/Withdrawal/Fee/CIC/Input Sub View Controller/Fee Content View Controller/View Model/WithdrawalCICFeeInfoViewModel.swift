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

protocol WithdrawalCICFeeInfoBase: WithdrawalFeeInfoProvider {
    var totalGas: Observable<Decimal?> { get }
    var gas: Observable<Decimal?> { get }
    var gasPrice: Observable<Decimal?> { get }
}

class WithdrawalCICFeeInfoViewModel: KLRxViewModel, WithdrawalCICFeeInfoBase {
    var isFeeInfoCompleted: Observable<Bool> {
        return totalGas.map { $0 != nil }
    }
    
    func getFeeInfo() -> WithdrawalFeeInfoProvider.FeeInfo? {
        guard let gp = _gasPrice.value, let g = _gas.value else {
            return nil
        }
        
        let option: FeeManager.Option?
        switch _mode.value {
        case .manual:
            option = nil
        case .system:
            option = .cic(.gasPrice(.suggest(mainCoinID: input.mainCoinID)))
        }
        
        let coin = Coin.getCoin(ofIdentifier: input.mainCoinID)!
        let digit = Int(coin.digit)
        return (rate: gp.power(digit * -1), amt: g, coin: coin, option: option,totalHardCodedFee:nil)
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        if _gas.value != nil && _gasPrice.value != nil {
            return .valid
        }else {
            return .emptyFee
        }
    }
    
    enum InputOption {
        case system
        case manual
    }
    
    struct FeeDefaultInput {
        let defaultFeeManagerOption: FeeManager.Option?
        let defaultGasPrice: Decimal?
        let defaultGas: Decimal?
    }
    
    struct Input {
        let systemGasProvider: WithdrawalETFFeeInfoModeBase
        let advGasProvider: WithdrawalETFFeeInfoModeBase
        let feeDefault: FeeDefaultInput
        let typeSelectInput: Driver<InputOption>
        let mainCoinID: String
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalCICFeeInfoViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        bindInternalLogic()
    }
    
    func concatInput() {
        input.typeSelectInput.drive(_mode).disposed(by: bag)
        switch inputOption(ofFeeManagerOption: input.feeDefault.defaultFeeManagerOption) {
        case .manual:
            input.advGasProvider.updateGasPrice(input.feeDefault.defaultGasPrice)
            input.advGasProvider.updateGas(input.feeDefault.defaultGas)
        case .system:
            input.systemGasProvider.updateGasPrice(input.feeDefault.defaultGasPrice)
        }
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _mode.subscribe(onNext: {
            [unowned self]
            mode in
            switch mode {
            case .manual:
                self.gasSource.accept(self.input.advGasProvider.gasInfo)
            case .system:
                self.gasSource.accept(self.input.systemGasProvider.gasInfo)
            }
        })
            .disposed(by: bag)
    }
    
    //MARK: - Public
    public var totalGas: Observable<Decimal?> {
        return Observable.combineLatest(gasPrice, gas).map {
            gasPrice, gas in
            guard let gp = gasPrice, let g = gas else { return nil }
            return gp * g
        }
    }
    
    public var gasPrice: Observable<Decimal?> {
        return _gasPrice.asObservable()
    }
    
    public var gas: Observable<Decimal?> {
        return _gas.asObservable()
    }
    
    public var mode: Observable<InputOption> {
        return _mode.asObservable()
    }
    
    //MARK: - Private
    private lazy var _mode: BehaviorRelay<InputOption> = {
        return BehaviorRelay.init(value: .system)
    }()
    
    private lazy var _gasPrice: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: nil)
        gasSource.switchLatest().map { $0.gasPrice }.bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private lazy var _gas: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: nil)
        gasSource.switchLatest().map { $0.gas }.bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private lazy var gasSource: BehaviorRelay<Observable<(gasPrice: Decimal?, gas: Decimal?)>> = {
        switch inputOption(ofFeeManagerOption: input.feeDefault.defaultFeeManagerOption) {
        case .manual:
            return BehaviorRelay.init(value: input.advGasProvider.gasInfo)
        case .system:
            return BehaviorRelay.init(value: input.systemGasProvider.gasInfo)
        }
    }()
    
    private func inputOption(ofFeeManagerOption option: FeeManager.Option?) -> InputOption {
        return option != nil ? .system : .manual
    }
}
