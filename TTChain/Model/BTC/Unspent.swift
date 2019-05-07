//
//  Unspent.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

import HDWalletKit

struct Unspent:Codable {
    public let address: String
    public let amount: Double
    public let confirmations: Int
    public let height: Int?
    public let satoshis: Int
    public let scriptPubKey: String
    public let txid: String
    public let vout: Int
}

extension Unspent{
    var unspendTx: UnspentTransaction {
        let lockingScript: Data = Data(hex: scriptPubKey)
        let txidData: Data = Data(hex: String(txid))
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: UInt64(satoshis), lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: UInt32(vout))
        return UnspentTransaction(output: output, outpoint: outpoint)
    }
}

