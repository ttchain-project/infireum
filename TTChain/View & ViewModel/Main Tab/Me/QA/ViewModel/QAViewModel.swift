//
//  QAViewModel.swift
//  OfflineWallet
//
//  Created by Patato on 2018/10/3.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class QAViewModel: KLRxViewModel {
    typealias InputSource = Input
    typealias OutputSource = Void
    
    struct Input {
        let identity: Identity
    }
    var bag: DisposeBag = DisposeBag.init()
    
    var input: QAViewModel.Input
    var output: Void
    
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
