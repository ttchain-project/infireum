//
//  LightTransDetailViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/17.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LightTransDetailViewModel: ViewModel,Rx {
    
    var input: LightTransDetailViewModel.Input
    
    var output: LightTransDetailViewModel.Output
    
    var bag:DisposeBag = DisposeBag.init()
    
    struct Input {
        var asset:BehaviorRelay<Asset>
    }
    
    struct Output {
        var amountStr:PublishSubject<String> = PublishSubject.init()
        var fiatAmtStr:PublishSubject<String> = PublishSubject.init()
    }
    
    init(withAsset asset:Asset) {
        self.input = Input.init(asset: BehaviorRelay.init(value: asset))
        self.output = Output()
        self._amtSource.map { amt in
            if let _amt = amt {
                return _amt
                    .asString(digits: 4,
                              force: true,
                              maxDigits: Int(self.input.asset.value.coin!.requiredDigit),
                              digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                    .disguiseIfNeeded()
            }else {
                return "--"
            }
        }.bind(to: self.output.amountStr).disposed(by: bag)
     
        Observable.combineLatest(self._fiat, self._fiatRate, self._amtSource)
            .map {
                fiat, fiatRate, amt -> String in
                let fiatSymbol = fiat.fullSymbol
                let prefix = "≈" + fiatSymbol + " "
                if let rate = fiatRate, let _amt = amt {
                    return prefix + (rate * _amt).asString(digits: 2, force: true).disguiseIfNeeded()
                }else {
                    return prefix + "--"
                }
            }
            .bind(to: self.output.fiatAmtStr)
            .disposed(by: bag)
    }
    
    private lazy var _amtSource: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: input.asset.value.amount as Decimal?)
        getAmtFromBlockchain().bind(to: relay).disposed(by: bag)
        return relay
    }()
    
    private lazy var _fiat: BehaviorRelay<Fiat> = {
        return BehaviorRelay.init(value: Identity.singleton!.fiat!)
    }()
    
    private lazy var _fiatRate: BehaviorRelay<Decimal?> = {
        let relay = BehaviorRelay<Decimal?>.init(value: CoinToFiatRate.getRateFromDatabase(coinID: input.asset.value.coinID!, fiatID: _fiat.value.id)?.rate as Decimal?)
        return relay
    }()
    
    fileprivate func getAmtFromBlockchain() -> Observable<Decimal?> {
        return input.asset.value.getAmtFromServerIfPossible().asObservable()
    }
    
}
