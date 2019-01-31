//
//  USDTFilter.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/31.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

class USDTTXFilter: TxFilter {
    typealias Tx = USDTTx
    typealias ConditionInput = Bool
    func filter(source: [Tx], condition: ConditionInput) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        var valid: [Tx] = []
        var unused: [Tx] = []
        let unsupports: [Tx] = []
        
        for tx in source {
            if tx.valid {
                valid.append(tx)
            }else {
                unused.append(tx)
            }
        }
        return (valid: valid, unused: unused, unsupports: unsupports)
    }
}
