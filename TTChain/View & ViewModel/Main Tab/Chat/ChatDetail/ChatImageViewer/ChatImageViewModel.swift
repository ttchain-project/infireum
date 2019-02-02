//
//  ChatImageViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/2.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChatImageViewModel: KLRxViewModel {
    required init(input: Void, output: Void) {
        
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
