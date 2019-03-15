//
//  WithdrawalBTCFeeInfoViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalBTCFeeInfoViewModel: KLRxViewModel {
    enum InputOption {
        case regular
        case priority
        case manual
    }
    
    struct FeeDefaultInput {
        let defaultFeeManagerOption: FeeManager.Option?
        let defaultFeeRate: Decimal?
    }
    
    struct Input {
        let feeDefault: FeeDefaultInput
        let typeSelectInput: Driver<InputOption>
        let manualRateStrInout: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalBTCFeeInfoViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
//        updateSuggestFeeRate()
    }
    
    func concatInput() {
        twoWayBind(
            property: input.manualRateStrInout,
            relay: _manualFeeRate,
            toVariable: { str in Decimal.init(string: str ?? "") },
            toProperty: { rate in rate?.asString(digits: 8) }
        )
        .disposed(by: bag)
        
        input.typeSelectInput.drive(_selectedOption).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var selectedOption: Observable<InputOption> {
        return _selectedOption.asObservable()
    }
    
    public var inputOptions: Observable<[InputOption]> {
        return _inputOptions.asObservable()
    }
    
    //Nil is possible if using manual input
    public var satPerByte: Observable<Decimal?> {
        //is actually btc value after hard coding, and not "per byte" value
        return _satPerByte.asObservable()
    }
    
    public var regularSatPerByte: Observable<Decimal> {
        //is actually btc value after hard coding, and not "per byte" value

        return _regularFeeRate.asObservable()
    }
    
    public var prioritySatPerByte: Observable<Decimal> {
        //is actually btc value after hard coding, and not "per byte" value

        return _priorityFeeRate.asObservable()
    }
    
    public func getSelectedResult() -> (FeeManager.Option?, Decimal) {
        var option: FeeManager.Option?
        let rate = _satPerByte.value! //already in btc value
            //.satoshiToBTC
        switch _selectedOption.value {
        case .manual:
            option = nil
        case .regular:
            option = FeeManager.Option.btc(.regular)
        case .priority:
            option = FeeManager.Option.btc(.priority)
        }
        return (option, rate)
    }
    
    //MARK: - Private
    private lazy var _selectedOption: BehaviorRelay<InputOption> = {
        let defOption = mapFeeManageOptionToLocal(source: input.feeDefault.defaultFeeManagerOption)
        return BehaviorRelay.init(value: defOption)
    }()
    
    private lazy var _inputOptions: BehaviorRelay<[InputOption]> = {
        return BehaviorRelay.init(value: [.regular, .priority, .manual])
    }()
    
    private lazy var _satPerByte: BehaviorRelay<Decimal?> = {
        
        let relay = BehaviorRelay<Decimal?>.init(value: nil)
        _selectedOption.flatMapLatest {
            [unowned self]
            option -> Observable<Decimal?> in
            switch option {
            case .manual:
                return self._manualFeeRate.asObservable()
            case .priority:
                return self._priorityFeeRate.asObservable().map { Optional.init($0) }
            case .regular:
                return self._regularFeeRate.asObservable().map { Optional.init($0) }
            }
        }
        .bind(to: relay)
        .disposed(by: bag)
        
        return relay
    }()
    
    private lazy var _regularFeeRate: BehaviorRelay<Decimal> = {
        //HARD-CODED for now
        let fee = Decimal.init(3000).satoshiToBTC
//            FeeManager.getValue(fromOption: .btc(.regular))
        return BehaviorRelay.init(value: fee)
    }()
    
    private lazy var _priorityFeeRate: BehaviorRelay<Decimal> = {
        //HARD-CODED for now
        let fee = Decimal.init(6000).satoshiToBTC

//            FeeManager.getValue(fromOption: .btc(.priority))
        return BehaviorRelay.init(value: fee)
    }()
    
    private lazy var _manualFeeRate: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: input.feeDefault.defaultFeeRate)
    }()
    
    
    /// Calling updateSuggestFeeRate() will ask FeeManager to update rate and sync with the local variable after completed.
    /// FeeManager will return the available value, whether from server of local (if HTTP request if failed).
    private func updateSuggestFeeRate() {
        FeeManager.updateBTCFeeRates()
            .map {
                _ in
                (FeeManager.getValue(fromOption: .btc(.regular)), FeeManager.getValue(fromOption: .btc(.priority)))
            }
            .subscribe(onSuccess: {
                [unowned self]
                (reg, prior) in
                self._regularFeeRate.accept(reg)
                self._priorityFeeRate.accept(prior)
            })
            .disposed(by: bag)
    }
    
    //MARK: - Helper
    private func mapFeeManageOptionToLocal(source: FeeManager.Option?) -> InputOption {
        guard let s = source else {
             return .manual
        }
        
        switch s {
        case .btc(let opt):
            switch opt {
            case .priority: return .priority
            case .regular: return .regular
            }
        //SHUOLD NOT ENTER NON-BTC TYPE
        default: return errorDebug(response: .manual)
        }
    }
}
