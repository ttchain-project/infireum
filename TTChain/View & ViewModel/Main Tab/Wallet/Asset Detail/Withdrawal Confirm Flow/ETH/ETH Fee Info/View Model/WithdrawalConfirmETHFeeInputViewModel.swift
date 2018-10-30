//
//  WithdrawalConfirmETHFeeInfoViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalConfirmETHFeeInputViewModel: KLRxViewModel , WithdrawalFeeInfoProvider {
    var isFeeInfoCompleted: Observable<Bool> {
        return input.gasProvider.isFeeInfoCompleted
    }
    
    func getFeeInfo() -> WithdrawalFeeInfoProvider.FeeInfo? {
        return input.gasProvider.getFeeInfo()
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        return input.gasProvider.checkValidity()
    }
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let gasProvider: WithdrawalETFFeeInfoBase
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }

    public var gas: Observable<Decimal?> {
        return input.gasProvider.gas
    }
    
    public var gasPrice: Observable<Decimal?> {
        return input.gasProvider.gasPrice
    }
}
