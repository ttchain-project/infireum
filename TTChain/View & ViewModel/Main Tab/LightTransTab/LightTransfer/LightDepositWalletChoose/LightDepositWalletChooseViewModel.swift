//
//  LightDepositWalletChooseViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/5/3.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LightDepositWalletChooseViewModel: KLRxViewModel {
  
    required init(input: LightDepositWalletChooseViewModel.Input, output: Void) {
        self.input = input
        self.output = output
        
        self.concatInput()
        self.concatOutput()
        self.bindInternalLogic()
    }
    
    var input: LightDepositWalletChooseViewModel.Input
    var output: Void
    
    func concatInput() {
        (input.amtStrInout <-> _transferAmtStr).disposed(by: bag)

    }
    func concatOutput() {
        
    }
  
    func bindInternalLogic() {
        
        let sortDescriptor = NSSortDescriptor.init(key: "isFromSystem", ascending: false)
        let predForBTC = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.btc.rawValue))
        guard let btcWallet = DB.instance.get(type: Wallet.self, predicate: predForBTC, sorts: [sortDescriptor])?.first else {
            return
        }
        
        guard btcWallet.isFromSystem else {
            return
        }
        guard let asset = btcWallet.getAsset(of: btcWallet.mainCoin!) else {
            return
        }
        
        self.fromAsset.accept(asset)
        
        _transferAmtStr.map {
            Decimal.init(string: $0 ?? "")
            }
            .bind(to: _transferAmt)
            .disposed(by: bag)
        
        self.fromAsset.map { $0?.wallet! }.asObservable().bind(to:self._selectedWallet).disposed(by: bag)
        
        self.fromAsset.map {
            (($0?.amount ?? 0) as Decimal)
            }.bind(to: self._assetAvailableAmt).disposed(by: bag)

    }
    
    let messageSubject : PublishSubject<String> = PublishSubject<String>.init()
    
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    var bag = DisposeBag()
    
    struct Input {
        let toAsset:Asset
        let amtStrInout: ControlProperty<String?>

    }

    lazy var _selectedWallet:BehaviorRelay<Wallet?> = {
       return BehaviorRelay.init(value: nil)
    }()
    
    lazy var fromAsset:BehaviorRelay<Asset?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    lazy var toAsset:BehaviorRelay<Asset> = {
        return BehaviorRelay.init(value: self.input.toAsset)
    }()
    
    func changeFromAsset(asset:Asset) {
        self.fromAsset.accept(asset)
    }
    
    private lazy var _transferAmtStr: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    lazy var _transferAmt: BehaviorRelay<Decimal?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _assetAvailableAmt: BehaviorRelay<Decimal> = {
        //In here I don't add the update logic.
        let relay = BehaviorRelay.init(value: (fromAsset.value?.amount ?? 0) as Decimal)
        return relay
        
    }()
    
    public var assetAvailableAmt: Observable<Decimal> {
        return _assetAvailableAmt.asObservable()
    }
    
    func checkValidity() -> Bool {
        guard let transAmt = self._transferAmt.value else {
            self.messageSubject.onNext("Please enter Amount")
            return false
        }
        guard transAmt <= _assetAvailableAmt.value else {
            self.messageSubject.onNext(LM.dls.withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title)
            return false
        }
        return true
    }
    
    var feeOption: BehaviorRelay<FeeManager.Option?> = {
        return BehaviorRelay.init(value: FeeManager.Option.btc(FeeManager.Option.BTCOption.priority))
    }()
    
    public func updateAmt(_ amt: Decimal) {
        _transferAmt.accept(amt)
        _transferAmtStr.accept(amt.asString(digits: 8))
    }
    
    lazy var feeRate:BehaviorRelay<String> = {
        
        let fee = "\(FeeManager.getValue(fromOption: feeOption.value!).satoshiToBTC) btc"
    
        return BehaviorRelay.init(value: fee)
    }()
    
    func initiateTransfer() -> WithdrawalInfo? {
        guard self.checkValidity() else {
            return nil
        }
        
        guard let asset = self.fromAsset.value,
        let transferAmt = self._transferAmt.value
        else {
            return nil
        }
        
        let feeInfo: WithdrawalFeeInfoProvider.FeeInfo = (rate: 1, amt: 0, coin: asset.coin! , option: feeOption.value, totalHardCodedFee:FeeManager.getValue(fromOption: feeOption.value!).satoshiToBTC)
         let toAddress = "16RmMmRGYoCugQAdfBRYoDPCU8CEpeUfqc"
        let info = WithdrawalInfo.init(
            asset: asset,
            withdrawalAmt: transferAmt,
            address: toAddress,
            feeRate: feeInfo.rate, feeAmt:(feeInfo.totalHardCodedFee != nil) ? feeInfo.totalHardCodedFee! : feeInfo.amt,
            feeCoin: feeInfo.coin,
            feeOption: feeInfo.option,
            note: ""
        )
        
        return info
    }
}



