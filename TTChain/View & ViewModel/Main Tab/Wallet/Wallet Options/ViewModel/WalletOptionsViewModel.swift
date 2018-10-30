//
//  WalletOptionsViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/10/30.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


class WalletOptionsViewModel:KLRxViewModel {
   
    struct Input {
        
    }
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
        fetchWallets()
    }
    
    var input: Void
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    private(set) lazy var btcWallet: BehaviorRelay<Wallet?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private(set) lazy var ethWallet: BehaviorRelay<Wallet?> = {
        return BehaviorRelay.init(value: nil)
    }()

    
    
    func fetchWallets() {
        let predForBTC = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.btc.rawValue))
        guard let btcWallet = DB.instance.get(type: Wallet.self, predicate: predForBTC, sorts: nil) else {
            return
        }
        self.btcWallet.accept(btcWallet[0])
        
        let predForETH = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.eth.rawValue))
        guard let ethWallet = DB.instance.get(type: Wallet.self, predicate: predForETH, sorts: nil) else {
            return
        }
        self.ethWallet.accept(ethWallet[0])
    }
    
    private func getTotalValueOfWalletAssets() {
        
    }
}
