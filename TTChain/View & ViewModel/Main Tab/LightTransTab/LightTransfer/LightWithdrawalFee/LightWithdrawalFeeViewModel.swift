//
//  LightWithdrawalFeeViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/29.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LightWithdrawalFeeViewModel: KLRxViewModel,WithdrawalFeeInfoProvider {
  
    var isFeeInfoCompleted: Observable<Bool> { return Observable.of(true) }
    
    func getFeeInfo() -> WithdrawalFeeInfoProvider.FeeInfo? {
        return (rate: Decimal(1.0), amt: 0, coin: self.input.asset.coin!, option: _feeOption!, totalHardCodedFee:nil)
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        return .valid
    }
    private lazy var _feeOption: FeeManager.Option? = {
        return input.purpose == .ttnTransfer ? FeeManager.Option.ttn(.systemDefault) : FeeManager.Option.ttn(.btcnWithdrawal)
    }()
   
    required init(input: LightWithdrawalFeeViewModel.Input, output: LightWithdrawalFeeViewModel.Output) {
        self.input = input
        self.output = output
    }
    
    var input: LightWithdrawalFeeViewModel.Input
    
    var output: LightWithdrawalFeeViewModel.Output
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Output
    
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let asset:Asset
        let purpose:LightTransferViewController.Purpose
    }
    struct Output {
        
    }
}
