//
//  ETHTxFilter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class ETHTxFilter: TxFilter {
    typealias Tx = ETHTx
    typealias ConditionInput = Void
    func filter(source: [Tx], condition: Void) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        var valid: [Tx] = []
        var unused: [Tx] = []
        var unsupports: [Tx] = []
        for tx in source {
            if tx.valueInCoinUnit > 0 && tx.contract.count == 0 && tx.input == "0x" {
                valid.append(tx)
            }else if tx.input.count > 0 {
                //This might be a erc-20 token, be careful here does not check if the matched coin is exist in DB or not.
                unused.append(tx)
            }else {
                unsupports.append(tx)
            }
        }
        
        return (valid: valid, unused: unused, unsupports: unsupports)
    }
    
    func filter(source: [Tx]) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        return filter(source: source, condition: ())
    }
}
