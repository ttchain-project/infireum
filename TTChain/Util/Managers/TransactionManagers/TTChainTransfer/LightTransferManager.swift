//
//  LightTransferManager.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/30.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift


enum LightTransferFlowState {
    /// This is the default state, to notify the view layer the transfer is not happened yet.
    case waitingUserActivate
    case signing
    case broadcasting
    /// Whether success or not will return this state, and send in the request result.
    case finished(RxAPIResponse<Void>.E)
}
class LightTransferManager {
    
    static let manager = LightTransferManager.init()
    let bag = DisposeBag.init()
}

extension LightTransferManager {
    func startTTNTransfer(fromInfo info: WithdrawalInfo,
                          progressObserver observer: AnyObserver<LightTransferFlowState>, isWithdrawal:Bool) {
        observer.onNext(.signing)
        getIfrcNonce(fromInfo: info)
            .flatMap {
                [unowned self] result -> RxAPIResponse<SignTTNTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    return self.signIfrcTx(with: info, nonce: model.nonce,isWithdrawal: isWithdrawal)
                }
            }
            .flatMap {
                [unowned self] result -> RxAPIResponse<BroadcastTTNTxAPIModel> in
                switch result {
                case .failed(error: let err):
                    observer.onNext(
                        .finished(.failed(error: err))
                    )
                    
                    return .just(.failed(error: err))
                case .success(let model):
                    observer.onNext(.broadcasting)
                    return self.broadcastTTNTx(with: model.broadcastContent, mainCoin: info.asset.coin!)
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
                    guard txID != nil else {
                        let err: GTServerAPIError = .incorrectResult(
                            LM.dls.ltTx_pwdVerify_error_tx_save_fail, ""
                        )
                        observer.onNext(.finished(.failed(error: err)))
                        return
                    }
                    observer.onNext(.finished(.success(())))
                }
                
            })
            .disposed(by: bag)
    }
    
    private func getIfrcNonce(fromInfo info: WithdrawalInfo) -> RxAPIResponse<GetTTNNonceAPIModel> {
        guard info.asset.coin?.owChainType == .ifrc else {
            return errorDebug(response: RxAPIResponse.just(.failed(error: .noData)))
        }
        
        guard let address = info.asset.wallet?.address else {
            return  RxAPIResponse.just(.failed(error: .noData))
        }
        //Till now, fee coin is always the basic coin of the chain.
        return Server.instance.getTTNNonce(
            address: address, mainCoin: info.feeCoin
        )
    }
    
    private func signIfrcTx(with info: WithdrawalInfo, nonce: Int,isWithdrawal:Bool) -> RxAPIResponse<SignTTNTxAPIModel> {
        guard info.asset.wallet != nil
            else {
                return RxAPIResponse.just(.failed(error: .noData))
        }
            let coin = info.asset.coin!
            let asset = info.asset
            let address = info.address
        
        let feeAmt = isWithdrawal ? FeeManager.getValue(fromOption: .ttn(.btcnWithdrawal)) : 0
        
        let transferAmt_smallestUnit = info.withdrawalAmt * pow(10, Int(coin.requiredDigit))
        return Server.instance.signTTNTx(fromAsset: asset,
                                         transferAmt_smallestUnit: transferAmt_smallestUnit,
                                         toAddress: address,
                                         toAddressType: .ttn,
                                         feeInTTNSmallestUnit: feeAmt,
                                         nonce: nonce, transType: isWithdrawal ? .btcnWithdraw : .ifrcTx  )
    }
    
    private func broadcastTTNTx(with content: [String : Any], mainCoin: Coin) -> RxAPIResponse<BroadcastTTNTxAPIModel> {
        return Server
            .instance
            .broadcastTTNTx(contentData: content, mainCoin: mainCoin)
    }
}

extension LightTransferManager {
    
    private func saveTxToLocal(with txid: String, info: WithdrawalInfo,isWithdrawal:Bool) -> TransRecord? {
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
    
    private func postCommentForTransaction(for transactionId: String, comment : String?) -> RxAPIResponse<PostCustomCommentsAPIModel> {
        let parameter = PostCustomCommentsAPI.Parameter.init(comments: comment ?? "", txID: transactionId, toIdentifier: "", toAddress: "")
        return Server.instance.postCommentsForTransaction(parameter:parameter)
    }
}


extension LightTransferManager {

}
