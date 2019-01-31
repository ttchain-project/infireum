//
//  USDTTx.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/31.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

struct USDTTx {
    
    let txid: String
    let blockHeight: Int
    let confirmations: Int
    let amount:Decimal
    let fee: Decimal
    let timestamp: TimeInterval
    let fromAddress:String
    let toAddress: String
    let valid:Bool
    var date: Date {
        return Date.init(timeIntervalSince1970: timestamp)
    }
    
}

extension Sequence where Element == USDTTx {
    func mapToTransRecords(fromAddress address: String) -> [TransRecord]? {
        let constructors = map { $0.transformToSyncConcstructor(fromAddress: address) }
        return TransRecord.syncEntities(
            constructors: constructors,
            returnNewEntitiesOnly: true
        )
    }
}

extension USDTTx {
    
    private func transRecordSetup(withAddress addr: String)
        -> (TransRecord) -> Void {
            return {
                //            [unowned self]
                record in
                
                let fCoin = Coin.USDT
                let fromAmt: Decimal = self.amount
                let toAmt: Decimal =  self.amount
                
                record.addToCoins(fCoin)
                record.fromCoinID = fCoin.identifier
                record.fromAddress = self.fromAddress
                fCoin.addToTransRecords(record)
                
                let tCoin = Coin.USDT
                record.addToCoins(tCoin)
                record.toCoinID = tCoin.identifier
                record.toAddress = self.toAddress
                tCoin.addToTransRecords(record)
                
                record.fromAmt = fromAmt as NSDecimalNumber
                record.toAmt = toAmt as NSDecimalNumber
                
                let feeCoin = Coin.USDT
                record.feeCoinID = feeCoin.identifier
                //this cannot be fetched, use origin data if possible
                record.feeAmt = record.feeAmt ?? 1
                record.feeRate = record.feeRate ?? 1
                record.totalFee = self.fee as NSDecimalNumber
                
                //From the blockchain status will always be success
                record.status = TransRecordStatus.success.rawValue
                record.date = Date.init(timeIntervalSince1970: self.timestamp) as NSDate
                record.syncDate = Date() as NSDate
                record.confirmations = Int64(self.confirmations)
                record.txID = self.txid
                //this cannot be fetched, use origin data if possible
                record.note = record.note ?? nil
                record.block = Int64(self.blockHeight)
            }
    }
    
    func transformToSyncConcstructor(fromAddress addr: String) -> ManagedObejctConstructor<TransRecord> {
        let setup : (TransRecord) -> Void = transRecordSetup(withAddress: addr)
        
        return ManagedObejctConstructor(
            idUnits: [
                IdentifierUnit.str(keyPath: #keyPath(TransRecord.txID), value: txid)
            ],
            setup: setup
        )
    }
}
