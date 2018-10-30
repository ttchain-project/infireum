//
//  WIthdrawalRemarkViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/9.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WithdrawalRemarkInfoProvider {
    func getRemarkNote() -> String?
}

class WithdrawalRemarkViewModel : KLRxViewModel,WithdrawalRemarkInfoProvider {
    
    struct  Input {
        let remarkInOut:  ControlProperty<String?>
    }
    typealias InputSource = Input
    typealias OutputSource = Void
    var bag = DisposeBag.init()
    var input: WithdrawalRemarkViewModel.Input
    var output: Void

    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    
    func concatInput() {
        (input.remarkInOut <-> _remarkNote).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private lazy var _remarkNote: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    func getRemarkNote() -> String? {
        return _remarkNote.value
    }

}
