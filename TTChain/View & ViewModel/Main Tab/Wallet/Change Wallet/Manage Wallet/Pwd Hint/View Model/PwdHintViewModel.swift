//
//  PwdHintViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PwdHintViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let wallet: Wallet
        let pwdHintInout: ControlProperty<String?>
        let pwdVisibilityInput: Driver<Bool>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: PwdHintViewModel.Input
    var output: Void
    
    public var hintVisibility: Driver<Bool> {
        return input.pwdVisibilityInput
    }
    
    public var isAbleToSave: Observable<Bool> {
        return hint.asObservable().map { $0?.count ?? 0 }.map { $0 > 0 }
    }
    
    private lazy var hint: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: input.wallet.pwdHint!)
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        (input.pwdHintInout <-> hint).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    public func saveNewHint() -> Bool {
        let hint = self.hint.value!
        input.wallet.pwdHint = hint
        return DB.instance.update()
    }
}
