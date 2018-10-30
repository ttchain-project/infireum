//
//  WithdrawalAssetViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol WithdrawalAssetInfoProvider {
    var hasAmt: Observable<Bool> { get }
    func checkAmtValidity() -> WithdrawalAssetValidity
    func getTransferAmt() -> Decimal?
}

enum WithdrawalAssetValidity {
    case valid
    case overAvailableAmt
    case empty
}

class WithdrawalAssetViewModel: KLRxViewModel, WithdrawalAssetInfoProvider {
    struct Input {
        let asset: Asset
        let fiat: Fiat
        let amtStrInout: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: WithdrawalAssetViewModel.Input
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
        (input.amtStrInout <-> _transferAmtStr).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _transferAmtStr.map {
            Decimal.init(string: $0 ?? "")
        }
        .bind(to: _transferAmt)
        .disposed(by: bag)
    }
    
    //MARK: - Public
    public var hasAmt: Observable<Bool> {
        return _transferAmt.map { $0 != nil }
    }
    
    public var assetAvailableAmt: Observable<Decimal> {
        return _assetAvailableAmt.asObservable()
    }
    
    public var fiat: Observable<Fiat> {
        return _fiat.asObservable()
    }
    
    public var transferAmtFiatValue: Observable<Decimal?> {
        return _transferAmtFiatValue.asObservable()
    }
    
    public func getTransferAmt() -> Decimal? {
        return _transferAmt.value
    }
    
    public func checkAmtValidity() -> WithdrawalAssetValidity {
        guard let amt = _transferAmt.value else { return .empty }
        guard amt <= _assetAvailableAmt.value else { return .overAvailableAmt }
        return .valid
    }
    
    //MARK: - Private
    private lazy var _assetAvailableAmt: BehaviorRelay<Decimal> = {
        //In here I don't add the update logic.
        let relay = BehaviorRelay.init(value: input.asset.amount! as Decimal)
        return relay
    }()
    
    private lazy var _fiat: BehaviorRelay<Fiat> = {
        return BehaviorRelay.init(value: input.fiat)
    }()
    
    private lazy var _transferAmtFiatValue: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: nil)
        Observable.combineLatest(_fiatRate, _transferAmt).map {
            rate, amt -> Decimal? in
            if let r = rate, let a = amt {
                return r * a
            }else {
                return nil
            }
        }
        .bind(to: relay)
        .disposed(by: bag)
        
        return relay
    }()
    
    private lazy var _fiatRate: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: CoinToFiatRate.getRateFromDatabase(coinID: input.asset.coinID!, fiatID: _fiat.value.id)?.rate as Decimal?)
        updateFiatRateToCoin(fiat: _fiat.value, coin: input.asset.coin!).bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private func updateFiatRateToCoin(fiat: Fiat, coin: Coin) -> Observable<Decimal?> {
        return CoinToFiatRate.getRateFromServerIfPossible(coin: coin, fiat: fiat).asObservable()
    }
    
    private lazy var _transferAmtStr: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _transferAmt: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    //MARK: - Helper
    public func updateAmt(_ amt: Decimal) {
        _transferAmt.accept(amt)
        _transferAmtStr.accept(amt.asString(digits: 8))
    }
}
