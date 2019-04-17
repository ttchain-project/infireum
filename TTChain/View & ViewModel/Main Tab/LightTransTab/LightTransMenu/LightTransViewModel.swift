//
//  LightTransViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift

class LightTransViewModel: ViewModel,Rx {
    var bag: DisposeBag = DisposeBag()
    
    var input: LightTransViewModel.Input
    
    var output: LightTransViewModel.Output
    
    struct Input {
        
    }
    struct Output {
        
    }
    init() {
        self.input = Input()
        self.output = Output()
    }
}
