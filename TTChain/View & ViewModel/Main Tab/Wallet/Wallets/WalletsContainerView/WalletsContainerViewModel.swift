//
//  WalletsContainerViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/14.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WalletsContainerViewModel:KLRxViewModel {
    var input: Void
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    typealias OutputSource = Void
    
    var bag:DisposeBag = DisposeBag()
 
    var coins:[Coin]
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.coins = Coin.getAllCoins(of: ChainType.btc) + Coin.getAllCoins(of: ChainType.eth)

    }
    
    func getCoinsForChild(child:WalletChildType) -> [Coin]{
        switch child {
        case .mainChain:
            return [Coin.btc,Coin.eth,Coin.ifrc]
        case .stableChain:
            return coins.filter { $0.identifier == Coin.usdt_identifier }.compactMap { $0 }
        default:
            return []
        }
    }
}
