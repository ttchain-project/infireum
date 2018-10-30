//
//  ImportChainTypeChooseViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImportChainTypeChooseViewModel: KLRxViewModel {
    struct Input {
        let typeRowSelectInput: Driver<Int>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: Input
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    public var mainCoins: BehaviorRelay<[Coin]> = BehaviorRelay.init(
        value: MainCoinTypStorage.supportMainCoins
    )
    
    public var onSelectMainCoin: Driver<Coin> {
        return input.typeRowSelectInput.map {
            [unowned self] in
            self.mainCoins.value[$0]
        }
    }
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
}
