//
//  OWMnemonicViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWMnemonicViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let targetMnemonic: String
        let beginMnemonic: String
        let itemRowSelected: Driver<Int>
    }
    
    struct Output {
        let wordSelectHandler: (String) -> Void
        let sourcesUpdate: ([String]) -> Void
        let matchingHandler: ((Bool?) -> Void)?
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    
    var input: OWMnemonicViewModel.Input
    var output: OWMnemonicViewModel.Output
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    lazy var sources: BehaviorRelay<[String]> = {
       return BehaviorRelay.init(value: MnemonicHelper.split(source: input.beginMnemonic))
    }()
    
    func concatInput() {
        input.itemRowSelected
            .drive(onNext: {
                [unowned self]
                row in
                var newSource = self.sources.value
                let word = newSource.remove(at: row)
                self.sources.accept(newSource)
                
                self.output.wordSelectHandler(word)
            })
            .disposed(by: bag)
    }
    
    func insert(word: String) {
        sources.accept(sources.value + [word])
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        sources
            .distinctUntilChanged()
            .subscribe(onNext: {
                [unowned self]
                sources in
                self.output.sourcesUpdate(sources)
            })
            .disposed(by: bag)
        
        sources.distinctUntilChanged()
            .map {
                MnemonicHelper.concat(sources: $0)
            }
            .subscribe(onNext: {
                [unowned self]
                currentConcatedMnemonic in
                let isSame = currentConcatedMnemonic == self.input.targetMnemonic
                self.output.matchingHandler?(isSame)
            })
            .disposed(by: bag)
    }
}
