//
//  SignETHTransaction.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/5/17.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import HDWalletKit

class SignETHTransaction {
    static func signTransaction(withdrawalInfo:WithdrawalInfo) -> RxAPIResponse<String>{
        
        let nonce = Server.instance.getETHNonce(ethAddress: withdrawalInfo.asset.wallet?.address ?? "")
       return  nonce.map { response -> Int in
            switch response {
            case .success(let model):
                return model.nonce
            case .failed(error: let error):
                throw error
            }
            }.map { nonce in
                let digitExp = Int(withdrawalInfo.asset.coin!.digit)
                let unitAmt = withdrawalInfo.withdrawalAmt * pow(10, digitExp)
                let ethTx = EthereumRawTransaction(value: Wei(unitAmt.asString(digits: 0))!,
                                                   to: withdrawalInfo.address,
                                                   gasPrice: Int(withdrawalInfo.feeRate.etherToWei.doubleValue),
                                                   gasLimit: Int(withdrawalInfo.feeAmt.doubleValue),
                                                   nonce: nonce)
                let dataPk = Data(hex: withdrawalInfo.asset.wallet!.pKey)
                let signer = EIP155Signer.init(chainId: 1)
                guard let txData = try? signer.sign(ethTx, privateKey: dataPk) else {
                    throw GTServerAPIError.incorrectResult("", "")
                }
                DLogInfo(txData.toHexString())
                return APIResult.success(txData.toHexString())
        }
    }
    
    
}
