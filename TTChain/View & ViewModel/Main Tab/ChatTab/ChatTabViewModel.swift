//
//  ChatTabViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/20.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChatTabViewModel:KLRxViewModel {
    
    var bag: DisposeBag = DisposeBag()
    typealias InputSource = Void
    typealias OutputSource = Void
    var input: Void
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        
    }
    func concatInput() {}
    func concatOutput() {}
    
    
}
