//
//  AudioCallViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AudioCallViewModel: KLRxViewModel {
   
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()

    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
    }
    
    var input: AudioCallViewModel.Input
    var output: AudioCallViewModel.Output
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }

}
