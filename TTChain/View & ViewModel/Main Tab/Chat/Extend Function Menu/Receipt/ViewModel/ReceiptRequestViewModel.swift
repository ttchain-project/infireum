//
//  ReceiptRequestViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/29.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ReceiptRequestViewModel: KLRxViewModel {
    var input: Input
    
    var output: Void
    
    func concatInput() {
        (input.amtStrInout <-> _transferAmtStr).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    struct Input {
        let amtStrInout: ControlProperty<String?>
        let coinSelectedInOut: ControlProperty<String?>
    }
    typealias InputSource = Input
    typealias OutputSource = Void
    var bag: DisposeBag = DisposeBag.init()
    var wallet = [Wallet]()
    
    lazy var selectedWallet : BehaviorRelay<Wallet?> = {
        guard wallet.count > 0 else {
          return BehaviorRelay.init(value: nil)
        }
        return BehaviorRelay.init(value: wallet[0])
    }()
    
    var coins : BehaviorRelay<[Coin]?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _transferAmtStr: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    var selectedCoin: BehaviorRelay<Coin?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        let predForBTC = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.btc.rawValue))
        guard let btcWallet = DB.instance.get(type: Wallet.self, predicate: predForBTC, sorts: nil) else {
            return
        }
        
        let predForETH = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.eth.rawValue))
        guard let ethWallet = DB.instance.get(type: Wallet.self, predicate: predForETH, sorts: nil) else {
            return
        }
        self.wallet.append(contentsOf: btcWallet)
        self.wallet.append(contentsOf: ethWallet)
        self.selectedWallet.asObservable().filter { $0 != nil }.map { wallet in
            return Coin.getAllCoins(of: ChainType(rawValue: wallet!.chainType)!)
        }.bind(to: self.coins).disposed(by: bag)
        
        self.selectedCoin
            .map {
                $0 != nil ? $0?.inAppName : ""
            }
            .bind(to: self.input.coinSelectedInOut).disposed(by: bag)
    }
    
    public func updateAmt(_ amt: Decimal) {
        _transferAmtStr.accept(amt.asString(digits: 8))
    }
    public func getAmt() -> String {
        return self._transferAmtStr.value ?? ""
    }
    
    public func checkValidity() -> Bool {
        guard self._transferAmtStr.value != nil else {
            return false
        }
        guard self.selectedCoin.value != nil else {
            return false
        }
        guard self.selectedWallet.value != nil else {
            return false
        }
        return true
    }
}


