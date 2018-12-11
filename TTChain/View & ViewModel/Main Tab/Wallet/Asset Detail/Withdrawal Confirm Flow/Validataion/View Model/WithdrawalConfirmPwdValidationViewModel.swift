//
//  WithdrawalConfirmPwdValidationViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum PwdValidateResult {
    case valid
    case invalid
}

enum BlockchainTransferFlowState {
    /// This is the default state, to notify the view layer the transfer is not happened yet.
    case waitingUserActivate
    case signing
    case broadcasting
    /// Whether success or not will return this state, and send in the request result.
    case finished(RxAPIResponse<TransRecord>.E)
}

class WithdrawalConfirmPwdValidationViewModel: KLRxViewModel {
    struct Input {
        let info: WithdrawalInfo
        let pwdInout: ControlProperty<String?>
        let confirmInput: Driver<Void>
        let changePwdVisibleInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalConfirmPwdValidationViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        (input.pwdInout <-> _pwd).disposed(by: bag)
        input.changePwdVisibleInput.map {
            [unowned self] in !self._isPwdVisible.value
        }
        .drive(_isPwdVisible)
        .disposed(by: bag)
        
        input.confirmInput
            .asObservable()
            .flatMapLatest {
                [unowned self] in self.checkPwdIsValid()
            }
            .filter {
                [unowned self]
                isPwdValid in
                if isPwdValid {
                    return true
                }else {
                    self._onDetectInvalidPwdBeforeTranfer.accept(())
                    return false
                }
            }
            .flatMapLatest {
                [unowned self] _ in
                self.startTransfer().asObservable().concat(Observable.never())
            }
//            .debug("pass result")
            .bind(to: _transferState)
            .disposed(by: bag)
//            .subscribe(onNext: {
//                [unowned self]
//                result in
//                self._transferState.accept(.finished(result))
//            })
//            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var hasPwd: Observable<Bool> {
        return _pwd.map { ($0 ?? "").count > 0 }
    }
    
    public var isPwdVisible: Observable<Bool> {
        return _isPwdVisible.asObservable()
    }
    
    //MARK: - Private
    private lazy var _pwd: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _isPwdVisible: BehaviorRelay<Bool> = {
       return BehaviorRelay.init(value: false)
    }()
    
    
    //MARK: - Blockchain Transfer Flow Notifier
    private func checkPwdIsValid() -> Observable<Bool> {
        guard let _rawPwd = _pwd.value else { return Observable.just(false) }
        let isValid = input.info.asset.wallet!.isWalletPwd(rawPwd: _rawPwd)
        return Observable.just(isValid)
    }
    
    public var onDetectInvalidPwdBeforeTranfer: Observable<Void> {
        return _onDetectInvalidPwdBeforeTranfer.asObservable()
    }
    
    private lazy var _onDetectInvalidPwdBeforeTranfer: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    public var transferState: Observable<BlockchainTransferFlowState> {
        return _transferState.asObservable()
    }
    
    private lazy var _transferState: BehaviorRelay<BlockchainTransferFlowState> = {
        return BehaviorRelay.init(value: .waitingUserActivate)
    }()
    
    /// This is the main transfer happen
    ///
    /// - Returns:
    private func startTransfer() -> Observable<BlockchainTransferFlowState> {
        let info = input.info
        let chainType = info.wallet.owChainType
        return Observable.create({ [unowned self] (observer) -> Disposable in
            observer.onNext(.signing)
            switch chainType {
            case .btc:
                self.startBTCTransferFlow(with: info, progressObserver: observer)
            case .eth:
                self.startETHTransferFlow(with: info, progressObserver: observer)
            default: break
            }
            return Disposables.create()
        })
    }
}

// MARK: - BTC Transfer Flow
extension WithdrawalConfirmPwdValidationViewModel {
    private func startBTCTransferFlow(with info: WithdrawalInfo,
                                      progressObserver observer: AnyObserver<BlockchainTransferFlowState> ) {
        var info = info
        //TEST
//        info.wallet.address = "3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r"
        getBTCUnspent(fromInfo: info)
            .flatMap {
                [unowned self] result -> RxAPIResponse<SignBTCTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    switch model.result {
                    case .unspents(let unspents):
                        if info.feeCoin.identifier == Coin.usdt_identifier {
                            return self.signUSDT(with: &info, unspents: unspents)
                        }else {
                            return self.signBTC(with: &info, unspents: unspents)
                        }
                    case .insufficient:
                        let digit = Int(info.feeCoin.digit)
                        let totalFee = info.totalFee.asString(digits: digit)
                        let dls = LM.dls
                        let err: GTServerAPIError = GTServerAPIError.incorrectResult(
                            dls
                                .withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title,
                            dls
                                .withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_content(totalFee)
                        )
                        
                        observer.onNext(.finished(.failed(error: err)))
                        return .just(.failed(error: err))
                    }
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<BroadcastBTCTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastBTC(with: model.signText, withComments: info.note ?? "")
                }
            }
            .subscribe(onSuccess: { (result) in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                case .success(let model):
                    guard let record = self.saveTxToLocal(with: model.txid, info: info) else {
                        let err: GTServerAPIError = .incorrectResult(
                            LM.dls.withdrawalConfirm_pwdVerify_error_tx_save_fail, ""
                        )
                        
                        observer.onNext(.finished(.failed(error: err)))
                        return
                    }
                    
                    observer.onNext(.finished(.success(record)))
                }
            })
            .disposed(by: bag)
    }
    
    private func getBTCUnspent(fromInfo info: WithdrawalInfo) -> RxAPIResponse<GetBTCUnspentAPIModel> {
        return Server.instance.getBTCUnspent(fromBTCAddress: info.wallet.address!, targetAmt: (info.withdrawalAmt + info.totalFee))
    }
    
    private func signBTC(with info: inout WithdrawalInfo, unspents: [Unspent]) -> RxAPIResponse<SignBTCTxAPIModel> {
        let amt = BTCFeeCalculator.txSizeInByte(ofInfo: info, unspents: unspents)
        info.feeAmt = Decimal.init(amt)
        
        let totalUnspentBTC = unspents.map { $0.btcAmount }.reduce(0, +)
        let changeBTC = totalUnspentBTC - (info.withdrawalAmt + info.totalFee)
        
        if changeBTC < 0 {
            return RxAPIResponse.just(APIResult.failed(error: GTServerAPIError.incorrectResult(LM.dls.lightningTx_error_insufficient_asset_amt(info.feeCoin.inAppName!), "")))
        }
        return Server.instance.signBTCTx(pkey: info.wallet.pKey,
                                         fromAddress: info.wallet.address!, toAddress: info.address, tranferBTC: info.withdrawalAmt, isUSDTTx:false, feeBTC: info.totalFee,
                                         unspents: unspents)
    }
    
    private func signUSDT(with info: inout WithdrawalInfo, unspents: [Unspent]) -> RxAPIResponse<SignBTCTxAPIModel> {
        let amt = BTCFeeCalculator.txSizeInByte(ofInfo: info, unspents: unspents)
        info.feeAmt = Decimal.init(amt)
        
        let totalUnspentBTC = unspents.map { $0.btcAmount }.reduce(0, +)
        let changeBTC = totalUnspentBTC - info.totalFee
        
        if changeBTC < 0 {
            return RxAPIResponse.just(APIResult.failed(error: GTServerAPIError.incorrectResult(LM.dls.lightningTx_error_insufficient_asset_amt(info.feeCoin.inAppName!), "")))
        }
        return Server.instance.signBTCTx(pkey: info.wallet.pKey,
                                         fromAddress: info.wallet.address!, toAddress: info.address, tranferBTC: info.withdrawalAmt, isUSDTTx:true, feeBTC: info.totalFee,
                                         unspents: unspents)
    }
    
    private func broadcastBTC(with signText: String, withComments comments:String) -> RxAPIResponse<BroadcastBTCTxAPIModel> {
        return Server
            .instance
            .broadcastBTCTx(withSignText: signText, withComments: comments)
    }

}

// MARK: - ETH Transfer Flow
extension WithdrawalConfirmPwdValidationViewModel {
    private func startETHTransferFlow(with info: WithdrawalInfo,
                                      progressObserver observer: AnyObserver<BlockchainTransferFlowState> ) {
        getETHNonce(fromInfo: info)
            .flatMap {
                [unowned self] result -> RxAPIResponse<SignETHTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    return self.signETHTx(fromInfo: info, nonce: model.nonce)
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<BroadcastETHTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastETHTx(with: model.signText,  andComments: info.note ?? "")
                }
            }
            .subscribe(onSuccess: { (result) in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                case .success(let model):
                    guard let record = self.saveTxToLocal(with: model.txid, info: info) else {
                        let err: GTServerAPIError = .incorrectResult(
                            LM.dls.withdrawalConfirm_pwdVerify_error_tx_save_fail, ""
                        )
                        
                        observer.onNext(.finished(.failed(error: err)))
                        return
                    }
                    
                    observer.onNext(.finished(.success(record)))
                }
            })
            .disposed(by: bag)
    }
    
    private func getETHNonce(fromInfo info: WithdrawalInfo) -> RxAPIResponse<GetETHNonceAPIModel> {
        return Server.instance.getETHNonce(ethAddress: info.wallet.address!)
    }
    
    private func signETHTx(fromInfo info: WithdrawalInfo, nonce: Int) -> RxAPIResponse<SignETHTxAPIModel> {
        let digitExp = Int(info.asset.coin!.digit)
        let unitAmt = info.withdrawalAmt * pow(10, digitExp)
        return Server.instance.signETHTx(pkey: info.wallet.pKey,
                                  nonce: nonce,
                                  gasPriceInWei: info.feeRate.etherToWei,
                                  gasLimit: Int(info.feeAmt.doubleValue),
                                  toETHAddress: info.address,
                                  transferToken: info.asset.coin!,
                                  transferValueInTokenUnit: unitAmt)
    }
    
    private func broadcastETHTx(with signText: String ,andComments comments: String) -> RxAPIResponse<BroadcastETHTxAPIModel> {
        return Server.instance.broadcastETH(signText: signText, andComments: comments)
    }
    
    private func saveTxToLocal(with txid: String, info: WithdrawalInfo) -> TransRecord? {
        let record = DB.instance.create(type: TransRecord.self, setup: { (rec) in
//            rec.inoutID = TransInoutType.withdrawal.rawValue
            rec.date = Date() as NSDate
            rec.feeAmt = info.feeAmt as NSDecimalNumber
            rec.feeCoinID = info.feeCoin.identifier!
            rec.feeRate = info.feeRate as NSDecimalNumber
            rec.fromAddress = info.wallet.address!
            rec.fromAmt = info.withdrawalAmt as NSDecimalNumber
            rec.fromCoinID = info.asset.coinID!
    
            rec.status = TransRecordStatus.success.rawValue
            rec.syncDate = Date() as NSDate
            rec.toAddress = info.address
            rec.toAmt = (info.withdrawalAmt) as NSDecimalNumber
            rec.toCoinID = info.asset.coinID!
            rec.totalFee = info.totalFee as NSDecimalNumber
            rec.txID = txid

            rec.addToCoins(info.asset.coin!)
            info.asset.coin!.addToTransRecords(rec)
        })
        
        return record
    }
}
