//
//  CreatetABUnitAddressViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreatetABUnitAddressViewModel: KLRxViewModel {
    typealias InputSource = Void
    typealias OutputSource = Void
    var input: Void
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
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
