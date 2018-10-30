//
//  TokenTxFilter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class TokenTxFilter: TxFilter {
    typealias Tx = TokenTx
    typealias ConditionInput = Coin?
    func filter(source: [TokenTx], condition: TokenTxFilter.ConditionInput) -> (valid: [TokenTx], unused: [TokenTx], unsupports: [TokenTx]) {
        var valid: [Tx] = []
        var unused: [Tx] = []
        //Because not-matched coins already been filtered from api response.
        let unsupports: [Tx] = []
        for tx in source {
            if let coin = condition {
                if tx.coin.contract == coin.contract {
                    valid.append(tx)
                }else {
                    unused.append(tx)
                }
            }else {
                valid.append(tx)
            }
        }
        
        return (valid: valid, unused: unused, unsupports: unsupports) 
    }
}
