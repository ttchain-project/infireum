//
//  CICTx.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
struct CICTx {
    let toAddress: String
    let fromAddress: String
    let coin: Coin
    let valueInCoinUnit: Decimal
    let feeInCICUnit: Decimal
    let nonce: Int
    let txid: String
    let blockHeight: Int
    let confirmations: Int
    let timestamp: TimeInterval
    var date: Date {
        return Date.init(timeIntervalSince1970: timestamp)
    }
}

extension Sequence where Element == CICTx {
    func mapToTransRecords() -> [TransRecord]? {
        let constructors = map { $0.transformToSyncConcstructor() }
        return TransRecord.syncEntities(
            constructors: constructors,
            returnNewEntitiesOnly: true
        )
    }
}

extension CICTx {
    private func transRecordSetup()
        -> (TransRecord) -> Void {
            return {
                //            [unowned self]
                record in
                
                let fCoin = self.coin
                record.addToCoins(fCoin)
                record.fromCoinID = fCoin.identifier
                record.fromAddress = self.fromAddress
                fCoin.addToTransRecords(record)
                
                let tCoin = self.coin
                record.addToCoins(tCoin)
                record.toCoinID = tCoin.identifier
                record.toAddress = self.toAddress
                tCoin.addToTransRecords(record)
                
                record.fromAmt = self.valueInCoinUnit as NSDecimalNumber
                record.toAmt = self.valueInCoinUnit as NSDecimalNumber
                
                let feeCoin = Coin.eth
                record.feeCoinID = feeCoin.identifier
                //this cannot be fetched, use origin data if possible
                record.feeAmt = self.feeInCICUnit as NSDecimalNumber
                //Because right now CIC doesn't has fee rate, so we assume the rate is 1 and amt is == CIC unit.
                record.feeRate = 1 as NSDecimalNumber
                record.totalFee =
                    self.feeInCICUnit as NSDecimalNumber
                
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
    
    func transformToSyncConcstructor() -> ManagedObejctConstructor<TransRecord> {
        let setup : (TransRecord) -> Void = transRecordSetup()
        
        return ManagedObejctConstructor(
            idUnits: [
                IdentifierUnit.str(keyPath: #keyPath(TransRecord.txID), value: txid)
            ],
            setup: setup
        )
    }
}
