//
//  ExploreDetailWebViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/15.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ExploreDetailWebViewModel: KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
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
    
    
}
