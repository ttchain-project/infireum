//
//  ETHTx.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/1.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
protocol ERC20Tx {
    var txid: String { get set }
    var blockHeight: Int { get set }
    var confirmations: Int { get set }
    var fromAddress: String { get set }
    var toAddress: String { get set }
    
    var gasLimit: Decimal { get set }
    var gasUsed: Decimal { get set }
    var gasPriceInWei: Decimal { get set }
    var nonce: Int { get set }
    var coin: Coin { get }
    var valueInCoinUnit: Decimal { get set }
    var timestamp: TimeInterval { get set }
    var isError: Bool { get set }
    var input: String { get set }
}

extension ERC20Tx {
    var date: Date {
        return Date.init(timeIntervalSince1970: timestamp)
    }
}

struct TokenTx: ERC20Tx {
    var txid: String
    var blockHeight: Int
    var confirmations: Int
    var fromAddress: String
    var toAddress: String
    
    var gasLimit: Decimal
    var gasUsed: Decimal
    var gasPriceInWei: Decimal
    var nonce: Int
    /// This is under discussion as it might not able to get the local coin without system support.
    var coin: Coin {
        return token
    }
    
    var token: Coin
    var valueInCoinUnit: Decimal
    var timestamp: TimeInterval
    var isError: Bool
    var input: String
}

struct ETHTx: ERC20Tx {
    var txid: String
    var blockHeight: Int
    var confirmations: Int
    var fromAddress: String
    var toAddress: String
   
    var gasLimit: Decimal
    var gasUsed: Decimal
    var gasPriceInWei: Decimal
    var nonce: Int
    /// This is under discussion as it might not able to get the local coin without system support.
    var coin: Coin { return Coin.eth }
    var valueInCoinUnit: Decimal
    var timestamp: TimeInterval
    var isError: Bool
    var input: String
    
    var contract: String
}

extension Sequence where Element: ERC20Tx {
    func mapToTransRecords() -> [TransRecord]? {
        let constructors = map { $0.transformToSyncConcstructor() }
        return TransRecord.syncEntities(
            constructors: constructors,
            returnNewEntitiesOnly: true
        )
    }
}

extension ERC20Tx {
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
                record.feeAmt = self.gasUsed as NSDecimalNumber
                record.feeRate = self.gasPriceInWei.weiToEther as NSDecimalNumber
                record.totalFee =
                    (self.gasUsed * self.gasPriceInWei.weiToEther)  as NSDecimalNumber
                
                //From the blockchain status will always be success
                record.status = self.isError ?
                    TransRecordStatus.failed.rawValue :
                    TransRecordStatus.success.rawValue
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
                //                IdentifierUnit.str(keyPath: #keyPath(TransRecord.), value: wallet.encryptedPKey!)
            ],
            setup: setup
        )
    }
}
