//
//  LightTransViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LightTransViewModel: KLRxViewModel {
   
    required init(input: LightTransViewModel.Input, output: LightTransViewModel.Output) {
        self.input = input
        self.output = output
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    var bag: DisposeBag = DisposeBag()
    
    var input: LightTransViewModel.Input
    
    var output: LightTransViewModel.Output
    
    struct Input {
    }
    struct Output {
        
    }
    private(set) var assets: BehaviorRelay<[Asset]> = BehaviorRelay.init(value: [])
}
