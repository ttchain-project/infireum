//
//  WalletHeaderViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/13.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WalletHeaderViewModel:KLRxViewModel {
    var input: Input
    
    var output: Void
    
    struct Input {
        let fiatAmtValue: Observable<BehaviorRelay<Decimal?>>
        let fiatSource: Observable<Fiat>
    }
    
    var bag:DisposeBag = DisposeBag()
    typealias InputSource = Input
    typealias OutputSource = Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
    }
    func concatInput() {
        
    }
    func concatOutput() {
        
    }
    
}
