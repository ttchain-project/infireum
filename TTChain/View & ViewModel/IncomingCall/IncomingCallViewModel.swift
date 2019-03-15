//
//  IncomingCallViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/13.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift

class IncomingCallViewModel:KLRxViewModel {
  
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let callModel:CallMessageModel
    }
   
    var input: IncomingCallViewModel.Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        AVCallHandler.handler.startIncomingCall(callMessageModel: input.callModel)
    }
}
