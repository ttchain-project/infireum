//
//  IdentitySetupViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IdentitySetupViewModel: KLRxViewModel {
    
    //MARK: - Protocol Defines
    typealias InputSource = Input
    typealias OutputSource = Output
    
    struct Input {
        var onCreate: Driver<Void>
        var onRestore: Driver<Void>
    }
    
    struct Output {
        var startCreate: () -> Void
        var startRestore: () -> Void
    }
    
    var bag: DisposeBag = DisposeBag.init()
    private(set) var input: Input
    private(set) var output: Output
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    func bindInternalLogic() {
        input.onCreate
            .drive(onNext: { [unowned self] _ in self.output.startCreate() })
            .disposed(by: bag)
        
        input.onRestore
            .drive(onNext: { [unowned self] _ in self.output.startRestore() })
            .disposed(by: bag)
    }
}
