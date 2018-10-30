//
//  TxFilter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
protocol TxFilter {
    associatedtype Tx
    associatedtype ConditionInput
    func filter(source: [Tx], condition: ConditionInput) -> (valid: [Tx], unused: [Tx], unsupports: [Tx])
}

class NoneFilter<T>: TxFilter {
    typealias ConditionInput = Void
    typealias Tx = T
    func filter(source: [NoneFilter<Tx>.Tx], condition: Void) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        return (valid: source, unused: [], unsupports: [])
    }
    
    func filter(source: [NoneFilter<Tx>.Tx]) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        return (valid: source, unused: [], unsupports: [])
    }
}
