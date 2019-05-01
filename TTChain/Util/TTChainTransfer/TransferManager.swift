//
//  TransferManager.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/27.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


enum TransferFlowState {
    /// This is the default state, to notify the view layer the transfer is not happened yet.
    case waitingUserActivate
    case signing
    case broadcasting
    /// Whether success or not will return this state, and send in the request result.
    case finished(RxAPIResponse<TransRecord>.E)
}

class TransferManager {
    
    static let manager = TransferManager.init()
    let bag = DisposeBag.init()
}

extension TransferManager {
    func startBTCTransferFlow(with info: WithdrawalInfo,
                                      progressObserver observer: AnyObserver<TransferFlowState>, isCompressed:Bool ) {
        var withdrawalInfo = info
        var isAddressCompressed = isCompressed
        checkForUncompressedAddress(pvtKey: info.wallet.pKey).flatMap{ [unowned self] result -> RxAPIResponse<GetBTCUnspentAPIModel> in
            let keyForUncompressed = "\(Coin.btc_identifier)uncompressed"

            switch result {
            case .failed(error: let error):
                return .just(.failed(error: error))
            case .success(let model):
                if model.addressMap[Coin.btc_identifier] == withdrawalInfo.wallet.address {
                    isAddressCompressed = true
                }else if model.addressMap[keyForUncompressed] == withdrawalInfo.wallet.address {
                    isAddressCompressed = false
                }
                return self.getBTCUnspent(fromInfo: withdrawalInfo)
            }
        }.flatMap {
                [unowned self] result -> RxAPIResponse<SignBTCTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    return .just(.failed(error: err))
                case .success(let model):
                    switch model.result {
                    case .unspents(let unspents):
                        if withdrawalInfo.feeCoin.identifier == Coin.usdt_identifier {
                            return self.signUSDT(with: &withdrawalInfo, unspents: unspents,isCompressed: isAddressCompressed)
                        }else {
                            return self.signBTC(with: &withdrawalInfo, unspents: unspents, isCompressed: isAddressCompressed)
                        }
                    case .insufficient:
                        let dls = LM.dls
                        let err: GTServerAPIError = GTServerAPIError.incorrectResult(
                            dls
                                .withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title,
                            dls
                                .insufficient_unspend_error_msg
                        )
                        return .just(.failed(error: err))
                    }
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<BroadcastBTCTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastBTC(with: model.signText, withComments: withdrawalInfo.note ?? "")
                }
            }.flatMap {
                [unowned self] result -> RxAPIResponse<(String?)> in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    
                    guard let note = info.note, note.count > 0 else {
                        return .just(.success(model.txid))
                    }
                    
                    let response = self.postCommentForTransaction(for: model.txid, comment: withdrawalInfo.note, toIdentifier: withdrawalInfo.asset.coinID!,toAddress:withdrawalInfo.address)
                    return response.map {
                        _result -> APIResult<(String?)>  in
                        switch _result {
                        //Even If the comment fails, the transaction should complete
                        case .failed(_): return .success((model.txid))
                        case .success(_): return .success((model.txid))
                        }
                    }
                }
            }
            .subscribe(onSuccess: { (result) in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                case .success(let txId):
                    guard let transID = txId, let record = self.saveTxToLocal(with: transID, info: info) else {
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
    
    private func signBTC(with info: inout WithdrawalInfo, unspents: [Unspent],isCompressed:Bool) -> RxAPIResponse<SignBTCTxAPIModel> {
        //        let amt = BTCFeeCalculator.txSizeInByte(ofInfo: info, unspents: unspents)
        //        info.feeAmt = Decimal.init(amt)
        
        let totalUnspentBTC = unspents.map { $0.btcAmount }.reduce(0, +)
        let changeBTC = totalUnspentBTC - (info.withdrawalAmt + info.totalFee)
        
        if changeBTC < 0 {
            return RxAPIResponse.just(APIResult.failed(error: GTServerAPIError.incorrectResult(LM.dls.lightningTx_error_insufficient_asset_amt(info.feeCoin.inAppName!), "")))
        }
        return Server.instance.signBTCTx(pkey: info.wallet.pKey,
                                         fromAddress: info.wallet.address!, toAddress: info.address, tranferBTC: info.withdrawalAmt, isUSDTTx:false, isCompressed: isCompressed, feeBTC: info.totalFee,
                                         unspents: unspents)
    }
    
    private func signUSDT(with info: inout WithdrawalInfo, unspents: [Unspent], isCompressed:Bool) -> RxAPIResponse<SignBTCTxAPIModel> {
        //        let amt = BTCFeeCalculator.txSizeInByte(ofInfo: info, unspents: unspents)
        //        info.feeAmt = Decimal.init(amt)
        
        let totalUnspentBTC = unspents.map { $0.btcAmount }.reduce(0, +)
        let changeBTC = totalUnspentBTC - info.totalFee
        
        if changeBTC < 0 {
            return RxAPIResponse.just(APIResult.failed(error: GTServerAPIError.incorrectResult(LM.dls.lightningTx_error_insufficient_asset_amt(info.feeCoin.inAppName!), "")))
        }
        return Server.instance.signBTCTx(pkey: info.wallet.pKey,
                                         fromAddress: info.wallet.address!, toAddress: info.address, tranferBTC: info.withdrawalAmt, isUSDTTx:true, isCompressed: isCompressed, feeBTC: info.totalFee,
                                         unspents: unspents)
    }
    
    private func broadcastBTC(with signText: String, withComments comments:String) -> RxAPIResponse<BroadcastBTCTxAPIModel> {
        return Server
            .instance
            .broadcastBTCTx(withSignText: signText, withComments: comments)
    }
    
    private func postCommentForTransaction(for transactionId: String, comment : String?,toIdentifier:String,toAddress:String) -> RxAPIResponse<PostCustomCommentsAPIModel> {
        let parameter = PostCustomCommentsAPI.Parameter.init(comments: comment ?? "", txID: transactionId, toIdentifier: toIdentifier, toAddress: toAddress)
        return Server.instance.postCommentsForTransaction(parameter:parameter)
    }
    
}

extension TransferManager {
    func startETHTransferFlow(with info: WithdrawalInfo,
                                      progressObserver observer: AnyObserver<TransferFlowState> ) {
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
            .flatMap {
                [unowned self] result -> RxAPIResponse<(String?)> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return RxAPIResponse.just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    
                    guard let note = info.note, note.count > 0 else {
                        return .just(.success(model.txid))
                    }
                    
                    let response = self.postCommentForTransaction(for: model.txid, comment: info.note, toIdentifier: info.asset.coinID!,toAddress:info.address)
                    return response.map {
                        _result -> APIResult<(String?)>  in
                        switch _result {
                        //Even If the comment fails, the transaction should complete
                        case .failed(_): return .success((model.txid))
                        case .success(_): return .success((model.txid))
                        }
                    }
                }
            }
            .subscribe(onSuccess: { (result) in
                switch result {
                case .failed(error: let err):
                    observer.onNext(.finished(.failed(error: err)))
                case .success(let txID):
                    guard let transID = txID, let record = self.saveTxToLocal(with: transID, info: info) else {
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

extension TransferManager {
    func checkForUncompressedAddress(pvtKey:String) -> RxAPIResponse<KeyToAddressAPIModel> {
        return Server.instance.convertKeyToAddress(pKey: pvtKey, encrypted: false)
    }
}
