//
//  AgreementViewModel.swift
//  OfflineWallet
//
//  Created by Patato on 2018/10/2.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AgreementMeViewModel: KLRxViewModel {
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        
        let identity: Identity
    }
    
    var input: AgreementMeViewModel.Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
        
    }
    
    func concatOutput() {
        
    }
    
    func concatInput() {
        
    }
}
