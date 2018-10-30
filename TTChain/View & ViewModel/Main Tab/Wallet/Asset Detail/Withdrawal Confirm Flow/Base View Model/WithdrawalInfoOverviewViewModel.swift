//
//  WithdrawalInfoOverviewViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalInfoOverviewViewModel: KLRxViewModel {
    struct Input {
        let info: WithdrawalInfo
        let changeWalletInput: Driver<Void>
        let changeFeeRateInput: Driver<Void>
        let confirmInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: WithdrawalInfoOverviewViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var toValidate: Observable<WithdrawalInfo> {
        return infoValidation
            .filter {
                result in
                switch result {
                case .failed: return false
                case .success: return true
                }
            }
            .map {
                result in
                switch result {
                case .success(let info): return info
                case .failed: fatalError()
                }
            }
            .asObservable()
    }
    
    public var foundValidationError: Observable<WithdrawalInfoValidator.Error> {
        return infoValidation
            .filter {
                result in
                switch result {
                case .failed: return true
                case .success: return false
                }
            }
            .map {
                result in
                switch result {
                case .success: fatalError()
                case .failed(let err): return err
                }
            }
            .asObservable()
    }
    
    public var coin: Observable<Coin> {
        return Observable.just(input.info.asset.coin!)
    }
    
    public var transAmt: Observable<Decimal> {
        return Observable.just(input.info.withdrawalAmt)
    }
    
    public var toAddr: Observable<String> {
        return Observable.just(input.info.address)
    }
    
    public var fromAsset: Observable<Asset> {
        return _fromAsset.asObservable()
    }
    
    public var fromAddr: Observable<String> {
        return _fromAsset.asObservable().map { $0.wallet!.address! }
    }
    
    public var feeRate: Observable<Decimal> {
        return _feeRate.asObservable()
    }
    
    public var feeAmt: Observable<Decimal> {
        return _feeAmt.asObservable()
    }
    
    public var totalFee: Observable<Decimal> {
        return Observable.combineLatest(feeAmt, feeRate).map { $0 * $1 }
    }
    
    public var remarkNote: Observable<String?> {
        return Observable.just(input.info.note)
    }
    
    public var onStartChangingWallet: Driver<WithdrawalInfo> {
        return input.changeWalletInput
            .map {
                [unowned self] in self.input.info
            }
    }
    
    public var onStartChangingFeeRate: Driver<WithdrawalInfo> {
        return input.changeFeeRateInput
            .map {
                [unowned self] in self.input.info
        }
    }
    
    public func changeAsset(_ asset: Asset) {
        _fromAsset.accept(asset)
        input.info.asset = asset
    }
    
    public func changeFeeRate(_ rate: Decimal) {
        _feeRate.accept(rate)
        input.info.feeRate = rate
    }
    
    public func changeFeeAmt(_ amt: Decimal) {
        _feeAmt.accept(amt)
        input.info.feeAmt = amt
    }
    
    public func changeFeeOption(_ option: FeeManager.Option?) {
        input.info.feeOption = option
    }
    
    //MARK: - Private
    private lazy var infoValidation: Driver<WithdrawalInfoValidator.Result> = {
        return input.confirmInput.map {
            [unowned self] in self.validate(info: self.input.info)
        }
    }()
    
    private lazy var _fromAsset: BehaviorRelay<Asset> = {
        let relay = BehaviorRelay.init(value: input.info.asset)
        return relay
    }()
    
    private lazy var _feeRate: BehaviorRelay<Decimal> = {
        return BehaviorRelay.init(value: input.info.feeRate)
    }()
    
    private lazy var _feeAmt: BehaviorRelay<Decimal> = {
       return BehaviorRelay.init(value: input.info.feeAmt)
    }()
    
    //MARK: - Helper
    private func validate(info: WithdrawalInfo) -> WithdrawalInfoValidator.Result {
        return WithdrawalInfoValidator().validate(info: info)
    }
}
