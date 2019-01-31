//
//  BTCTxFilter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class BTCTxFilter: TxFilter {
    typealias Tx = BTCTx
    typealias ConditionInput = String
    func filter(source: [BTCTx], condition: String) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        let addr = condition
        var valid: [Tx] = []
        let unused: [Tx] = []
        var unsupports: [Tx] = []
        
        for tx in source {
            if tx.outAmtOfAddress(addr) != 0 || tx.inAmtOfAddress(addr) != 0 {
                valid.append(tx)
            }else {
                unsupports.append(tx)
            }
        }
        
        
        return (valid: valid, unused: unused, unsupports: unsupports)
    }
}
