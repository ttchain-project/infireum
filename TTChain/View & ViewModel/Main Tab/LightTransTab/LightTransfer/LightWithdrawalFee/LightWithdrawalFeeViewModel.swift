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
        
        let feeAmt = input.purpose == .ifrcTransfer ? FeeManager.getValue(fromOption: _feeOption!) : FeeManager.getValue(fromOption: _feeOption!).satoshiToBTC
        let feeCoin =  input.purpose == .ifrcTransfer ? Coin.ifrc : input.asset.coin!
        return (rate: Decimal(1.0), amt: feeAmt, coin: feeCoin, option: _feeOption!, totalHardCodedFee:nil)
    }
    
    func checkValidity() -> WithdrawalFeeInfoValidity {
        return .valid
    }
    private lazy var _feeOption: FeeManager.Option? = {
        return input.purpose == .ifrcTransfer ? FeeManager.Option.ttn(.systemDefault) : FeeManager.Option.ttn(.btcnWithdrawal)
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
