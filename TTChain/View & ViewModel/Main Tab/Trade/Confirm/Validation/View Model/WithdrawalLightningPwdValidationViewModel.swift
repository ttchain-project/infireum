//
//  WithdrawalLightningPwdValidationViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

enum LightningTransferFlowState {
    /// This is the default state, to notify the view layer the transfer is not happened yet.
    case waitingUserActivate
    case signing
    case broadcasting
    /// Whether success or not will return this state, and send in the request result.
    case finished(RxAPIResponse<LightningTransRecord>.E)
}

class WithdrawalLightningPwdValidationViewModel: KLRxViewModel {
    struct Input {
        let source: LightningTransRecordCreateSource
        let pwdInout: ControlProperty<String?>
        let confirmInput: Driver<Void>
        let changePwdVisibleInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalLightningPwdValidationViewModel.Input
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
            .bind(to: _transferState)
            .disposed(by: bag)
//            .subscribe(onNext: {
//                [unowned self]
//                result in
//                self._transferState.accept(result)
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
        let isValid = input.source.from.fromWallet!.isWalletPwd(rawPwd: _rawPwd)
        return Observable.just(isValid)
    }
    
    public var onDetectInvalidPwdBeforeTranfer: Observable<Void> {
        return _onDetectInvalidPwdBeforeTranfer.asObservable()
    }
    
    private lazy var _onDetectInvalidPwdBeforeTranfer: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    public var transferState: Observable<LightningTransferFlowState> {
        return _transferState.asObservable()
    }
    
    private lazy var _transferState: BehaviorRelay<LightningTransferFlowState> = {
        return BehaviorRelay.init(value: .waitingUserActivate)
    }()

}

//MARK: - CIC Tx
extension WithdrawalLightningPwdValidationViewModel {
    private func startCICTransfer(fromInfo info: LightningTransRecordCreateSource,
                                       progressObserver observer: AnyObserver<LightningTransferFlowState>) {
        observer.onNext(.signing)
        getCICTxNonce(fromInfo: info)
            .flatMap {
                [unowned self] result -> RxAPIResponse<SignCICTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    return self.signCICTx(with: info, nonce: model.nonce)
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<BroadcastCICTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastCICTx(with: model.broadcastContent, mainCoin: info.fee.feeCoin)
                }
            }.flatMap {
                [unowned self] result -> RxAPIResponse<(PostCustomCommentsAPIModel,String?)> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return RxAPIResponse.just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    let response = self.postCommentForTransaction(for: model.txid, comment: info.note)
                    return response.map {
                        _result -> APIResult<(PostCustomCommentsAPIModel, String?)>  in
                        switch _result {
                        case .failed(let e): return .failed(error: e)
                        case .success(let _m): return .success((_m, model.txid))
                        }
                    }
                }
            }
            .subscribe(onSuccess: { result in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                    return
                case .success(( _, let txID)):
                    guard let transID = txID, let record = self.saveTxToLocal(with: transID, info: info) else {
                        let err: GTServerAPIError = .incorrectResult(
                            LM.dls.ltTx_pwdVerify_error_tx_save_fail, ""
                        )
                        observer.onNext(.finished(.failed(error: err)))
                        return
                    }
                    observer.onNext(.finished(.success(record)))
                }
                
        })
            .disposed(by: bag)
    }
    
    private func getCICTxNonce(fromInfo info: LightningTransRecordCreateSource) -> RxAPIResponse<GetCICNonceAPIModel> {
        guard info.from.fromCoin!.owChainType == .cic else {
            return errorDebug(response: RxAPIResponse.just(.failed(error: .noData)))
        }
        
        let address = info.from.address
        //Till now, fee coin is always the basic coin of the chain.
        
        return Server.instance.getCICNonce(
            address: address, mainCoin: info.fee.feeCoin
        )
    }
    
    private func signCICTx(with info: LightningTransRecordCreateSource, nonce: Int) -> RxAPIResponse<SignCICTxAPIModel> {
        guard let wallet = info.from.fromWallet,
            let coin = info.from.fromCoin,
            let asset = wallet.getAsset(of: coin),
            let address = info.to.address else {
                return RxAPIResponse.just(.failed(error: .noData))
        }
        
        let feeInCICSmallestUnit = info.fee.total * pow(10, Int(info.fee.feeCoin.digit))
        
        let transferAmt_smallestUnit = info.from.amt * pow(10, Int(coin.digit))
        return Server.instance.signCICTx(fromAsset: asset,
                                         transferAmt_smallestUnit: transferAmt_smallestUnit,
                                         toAddress: address,
                                         toAddressType: .cic,
                                         feeInCICSmallestUnit: feeInCICSmallestUnit,
                                         nonce: nonce)
    }
    
    private func broadcastCICTx(with content: [String : Any], mainCoin: Coin) -> RxAPIResponse<BroadcastCICTxAPIModel> {
        return Server
            .instance
            .broadcastCICTx(contentData: content, mainCoin: mainCoin)
    }
    
    private func postCommentForTransaction(for transactionId: String, comment : String?) -> RxAPIResponse<PostCustomCommentsAPIModel> {
        let parameter = PostCustomCommentsAPI.Parameter.init(comments: comment ?? "", txID: transactionId, toIdentifier: "", toAddress: "")
        return Server.instance.postCommentsForTransaction(parameter:parameter)
    }
}

// MARK: - BTC Relay Tx
extension WithdrawalLightningPwdValidationViewModel {
    private func startBTCRelayTransfer(fromInfo info: LightningTransRecordCreateSource,
                                       progressObserver observer: AnyObserver<LightningTransferFlowState>) {
        var info = info
        observer.onNext(.signing)
        getRelayTxUnspent(fromInfo: info)
            .flatMap {
                [unowned self] result -> RxAPIResponse<LTSignBTCRelayTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                    return .just(.failed(error: err))
                case .success(let model):
                    switch model.result {
                    case .unspents(let unspents):
                        return self.signBTCRelay(with: &info, unspents: unspents)
                    case .insufficient:
                        //THIS SHUOLD NOT HAPPENED
                        let dls = LM.dls
                        let digit = Int(info.fee.feeCoin.digit)
                        let totalFee = info.fee.total.asString(digits: digit)
                        let err: GTServerAPIError = GTServerAPIError.incorrectResult(
                            dls.ltTx_pwdVerify_error_btc_insufficient_fee_title,
                            dls.ltTx_pwdVerify_error_btc_insufficient_fee_content(
                                totalFee
                            )
                        )
                        
                        observer.onNext(.finished(.failed(error: err)))
                        return .just(
                            .failed(
                                error: err
                            )
                        )
                    }
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<LTBroadcastBTCRelayTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastBTCRelayTx(with: model.signText, comments: info.note ?? "")
                }
            }.flatMap {
                [unowned self] result -> RxAPIResponse<(PostCustomCommentsAPIModel,String?)> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return RxAPIResponse.just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    let response = self.postCommentForTransaction(for: model.txid, comment: info.note)
                    return response.map {
                        _result -> APIResult<(PostCustomCommentsAPIModel, String?)>  in
                        switch _result {
                        case .failed(let e): return .failed(error: e)
                        case .success(let _m): return .success((_m, model.txid))
                        }
                    }
                }
            }
            .subscribe(onSuccess: { result in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                    return
                case .success(( _, let txID)):
                    guard let transID = txID, let record = self.saveTxToLocal(with: transID, info: info) else {
                        let err: GTServerAPIError = .incorrectResult(
                            LM.dls.ltTx_pwdVerify_error_tx_save_fail, ""
                        )
                        observer.onNext(.finished(.failed(error: err)))
                        return
                    }
                    observer.onNext(.finished(.success(record)))
                }
            })
            .disposed(by: bag)
    }
    
    private func getRelayTxUnspent(fromInfo info: LightningTransRecordCreateSource) -> RxAPIResponse<GetBTCUnspentAPIModel> {
        guard info.to.toCoin?.identifier == Coin.btcRelay_identifier else {
            return errorDebug(response: RxAPIResponse.just(.failed(error: .noData)))
        }
        
        let address = info.from.address
        let amt = info.from.amt
        return Server.instance.getBTCUnspent(fromBTCAddress: address, targetAmt: amt)
    }
    
    private func signBTCRelay(with info: inout LightningTransRecordCreateSource, unspents: [Unspent]) -> RxAPIResponse<LTSignBTCRelayTxAPIModel> {
        let amt = BTCFeeCalculator.txSizeInByte(ofLTInfo: info, unspents: unspents)
        info.fee.amt = Decimal.init(amt)
        return Server.instance.lt_signBTCRelayTx(
            btcWalletPrivateKey: info.from.fromWallet!.pKey,
            fromBTCAddress: info.from.address,
            toCICAddress: info.to.address!,
            unspents: unspents,
            transferBTC: info.from.amt,
            feeBTC: info.fee.total)
    }
    
    private func broadcastBTCRelayTx(with signText: String, comments: String) -> RxAPIResponse<LTBroadcastBTCRelayTxAPIModel> {
        return Server
            .instance
            .lt_broadcastBTCRelayTx(withSignText: signText, comments: comments)
    }
}

// MARK: - Transfer
extension WithdrawalLightningPwdValidationViewModel {
    
    private func saveTxToLocal(with txid: String, info: LightningTransRecordCreateSource) -> LightningTransRecord? {
        let record = DB.instance.create(type: LightningTransRecord.self, setup: { (rec) in
            //            rec.inoutID = TransInoutType.withdrawal.rawValue
            rec.date = Date() as NSDate
            rec.feeAmt = info.fee.amt as NSDecimalNumber
            rec.feeCoinID = info.fee.feeCoin.identifier!
            rec.feeRate = info.fee.rate as NSDecimalNumber
            rec.fromAddress = info.from.address
            rec.fromAmt = info.from.amt as NSDecimalNumber
            rec.fromCoinID = info.from.fromCoin!.identifier!
            
            rec.status = TransRecordStatus.success.rawValue
            rec.syncDate = Date() as NSDate
            rec.toAddress = info.to.address
            rec.toAmt = (info.to.amt) as NSDecimalNumber
            rec.toCoinID = info.to.toCoin!.identifier!
            rec.totalFee = info.fee.total as NSDecimalNumber
            rec.txID = txid
            rec.note = info.note
            let mapRecToCoin: (Coin) -> Void  = {
                coin in
                rec.addToCoins(coin)
                coin.addToLightningTransRecords(rec)
            }
        
            mapRecToCoin(info.from.fromCoin!)
            mapRecToCoin(info.to.toCoin!)
            mapRecToCoin(info.fee.feeCoin)
        })
        
        return record
    }
    
    /// This is where the main transfer happen
    ///
    /// - Returns:
    private func startTransfer() -> Observable<LightningTransferFlowState> {
        //TODO: Complete with two concated observable, signing and broadcasting
        return Observable.create({ [unowned self] (observer) -> Disposable in
            let info = self.input.source
            let fromCoin = info.from.fromCoin!
            let toCoin = info.to.toCoin!
            switch (fromCoin.identifier!, toCoin.identifier!) {
            case (Coin.btc_identifier, Coin.btcRelay_identifier):
                self.startBTCRelayTransfer(
                    fromInfo: info,
                    progressObserver: observer
                )
            default:
                guard fromCoin.owChainType == .cic && toCoin.owChainType == .cic,
                    fromCoin.identifier == toCoin.identifier else {
                        observer.onNext(.finished(.failed(error: .noData)))
                        return Disposables.create ()
                }
                
                self.startCICTransfer(fromInfo: info, progressObserver: observer)
            }
            
            return Disposables.create()
        })
    }
}

