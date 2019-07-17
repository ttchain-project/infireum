//
//  RestoreMnemonicViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/16.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RestoreMnemonicViewModel:KLRxViewModel {
    
    func concatInput() { }
    
    func concatOutput() { }
    
    var bag:DisposeBag = DisposeBag()
    struct Input {
        
    }
    struct Output {
        let errorMessageSubject = PublishSubject<String>.init()
        let animateHUDSubject = PublishSubject<Bool>.init()
        let mnemonicValidated = PublishSubject<String>.init()
    }
    typealias InputSource = Input
    typealias OutputSource = Output
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
    }
    var input: RestoreMnemonicViewModel.Input
    var output: RestoreMnemonicViewModel.Output
    
    func createWalletWithMnemonics(_ mnemonic:String) {
        switch mnemonic.ow_isValidMnemonic {
        case .incorrectFormat(let desc):
            self.output.errorMessageSubject.onNext(desc)
            return
        case .valid:
            break
        }
        self.output.mnemonicValidated.onNext(mnemonic)
    }
}
