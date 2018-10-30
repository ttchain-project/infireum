//
//  DeleteABUnitViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

class DeleteABUnitViewModel: KLRxViewModel {
    typealias InputSource = Void
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    var input: Void
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
}
