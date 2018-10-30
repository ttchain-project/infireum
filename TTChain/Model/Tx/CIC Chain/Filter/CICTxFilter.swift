//
//  CICTxFilter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

class CICTxFilter: TxFilter {
    typealias Tx = CICTx
    typealias ConditionInput = Coin
    func filter(source: [Tx], condition: ConditionInput) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        var valid: [Tx] = []
        var unused: [Tx] = []
        let unsupports: [Tx] = []
        
        for tx in source {
            if tx.coin.identifier == condition.identifier {
                valid.append(tx)
            }else {
                unused.append(tx)
            }
        }
        
        return (valid: valid, unused: unused, unsupports: unsupports)
    }
}
