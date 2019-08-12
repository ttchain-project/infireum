//
//  WithdrawalConfirmationViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/19.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class WithdrawalConfirmationViewModel:KLRxViewModel {
    
    var input: WithdrawalConfirmationViewModel.Input
    var output: Void

    typealias InputSource = Input
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag()
    struct Input {
        let info:WithdrawalInfo
    }
    
    required init(input: WithdrawalConfirmationViewModel.Input, output: Void) {
        self.input = input
        self.output = output
        
    }
    
    func concatInput() {
    }
    func concatOutput() {
    }
    
    lazy var _transferAmount:BehaviorRelay<Decimal>  = {
        return BehaviorRelay.init(value: self.input.info.withdrawalAmt)
    }()
    
    var transferAmoutStr:Observable<String> {
        return _transferAmount.map {
            $0.asString(digits: Int(self.input.info.asset.coin!.digit)) + self.input.info.asset.coin!.inAppName!
        }
    }
    
    lazy var receiverAddress:Observable<String> = {
        return Observable.just(self.input.info.address)
    }()
    
    lazy var senderAddress:Observable<String>  = {
        return Observable.just(self.input.info.asset.wallet!.address!)
    }()
    
    var totalFeeStr:Observable<String> {
        return totalFee.map {
            $0.asString(digits: Int(self.input.info.feeCoin.digit)) + self.input.info.feeCoin.inAppName!
        }
    }
    
    lazy var noteString:Observable<String>  = {
        return Observable.just(self.input.info.note ?? "-")
    }()

    private lazy var feeRate: Observable<Decimal> = {
        return Observable.just(input.info.feeRate)
    }()
    
    private lazy var feeAmt: Observable<Decimal> = {
        return Observable.just(input.info.feeAmt)
    }()
    
    public var totalFee: Observable<Decimal> {
        return Observable.combineLatest(feeAmt, feeRate).map { $0 * $1 }
    }
    
    public var ethFeeDetailContent:Observable<String> {
        return Observable.combineLatest(self.feeRate, self.feeAmt)
            .map {
                ether, gas -> String in
                let gasStr = gas.asString(digits: 0)
                let gweiStr = ether.etherToGWei.asString(digits: 4)
                
                return LM.dls.withdrawal_label_eth_fee_content(gasStr, gweiStr)
            }
    }
    
    func startDeposit() -> Observable<TransferFlowState> {
        let info = self.input.info
        
        return Observable.create({ (observer) -> Disposable in
            switch info.asset.wallet?.walletMainCoinID! {
            case Coin.btc_identifier:
                TransferManager.manager.startBTCTransferFlow(with: info, progressObserver: observer, isCompressed: false)
            case Coin.eth_identifier:
                TransferManager.manager.startETHTransferFlow(with: info, progressObserver: observer)
            default:
                break
            }
            return Disposables.create()
        })
    }
}
