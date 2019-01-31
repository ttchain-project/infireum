//
//  BTCTx.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
struct BTCTx {
    /// TxUnit is the unit of vin and vout
    struct TxUnit {
//        let txid: String?
        let addr: String
        let btc: Decimal
    }
    
    let txid: String
    let blockHeight: Int
    let confirmations: Int
    let vins: [TxUnit]
    let vouts: [TxUnit]
    /// inBTC = outBTC + feeBTC
    let totalFeeBTC: Decimal
    /// inBTC = outBTC + feeBTC
    let totalInBTC: Decimal
    /// inBTC = outBTC + feeBTC
    let totalOutBTC: Decimal
    let timestamp: TimeInterval
    var date: Date {
        return Date.init(timeIntervalSince1970: timestamp)
    }
    
    /*
     Based on the current support tx type limitations,
     BTCTx will only able to be created from [vin].count == 1
     in order to limit the tx a single-account transaction.
     This limitation is placed to ensure the transfer/deposit amt and
     fee from the Tx is able to be calculated. (As in a multi-to-multi
     Tx all the value is mixed up into the total in/out/fee,
     it's hard to tell neither how much each address spend/get from
     this Tx nor the fee amt each address afford.)
    */
    /// Will calculate the amount variation of the input address in this transaction.
    /// - Parameter addr: BTC Address
    /// - Returns: the amt of variation of the address in this Tx.
    ///            (out - in), if > 0, it is a deposit Tx for this
    ///            address, in opposite will be a withdrawal Tx.
    func amtVariationOfAddress(_ addr: String) -> Decimal {
        let outAmt = outAmtOfAddress(addr)
        let inAmt = inAmtOfAddress(addr)
        
        return outAmt - inAmt
    }
    
    func outAmtOfAddress(_ addr: String) -> Decimal {
        return vouts
            .filter { $0.addr == addr }
            .map {
                $0.btc
            }
            .reduce(0, +)
    }
    
    func inAmtOfAddress(_ addr: String) -> Decimal {
        return vins
            .filter { $0.addr == addr }
            .map {
                $0.btc
            }
            .reduce(0, +)
    }
    
    
    func inoutTypeOfAddress(_ addr: String) -> TransInoutType {
        if inAmtOfAddress(addr) > 0 { return .withdrawal }
        else {
            return amtVariationOfAddress(addr) > 0 ? .deposit : .withdrawal
        }
    }
}

extension Sequence where Element == BTCTx.TxUnit {
    func extractAddrList(except exceptAddress: String) -> [String] {
        let addrList = filter { $0.addr != exceptAddress }.map { $0.addr }
        let set = NSOrderedSet.init(array: addrList)
        return set.array as! [String]
    }
}

extension Sequence where Element == BTCTx {
    func mapToTransRecords(fromAddress address: String) -> [TransRecord]? {
        let constructors = map { $0.transformToSyncConcstructor(fromAddress: address) }
        return TransRecord.syncEntities(
            constructors: constructors,
            returnNewEntitiesOnly: true
        )
    }
}

//MARK: - Local DB Sync
extension BTCTx {
    
    private func describeAddrList(addrs: [String]) -> String {
        guard !addrs.isEmpty else { return  errorDebug(response: "Not found") }
        if addrs.count > 1 {
            return String.init(format: "%@(%i+)", addrs[0], addrs.count)
        }else {
            return addrs[0]
        }
    }
    
    private func transRecordSetup(withAddress addr: String)
        -> (TransRecord) -> Void {
        let inoutType = inoutTypeOfAddress(addr)
            
        return {
            //            [unowned self]
            record in
            
            let fCoin = Coin.btc
            let fromAddr: String
            let toAddr: String
            let fromAmt: Decimal = self.totalInBTC
            var toAmt: Decimal =  self.amtVariationOfAddress(addr)
            //abs(Decimal)
            toAmt = toAmt >= 0 ? toAmt : toAmt * -1
            
            switch inoutType {
            case .deposit:
                toAddr = addr
                fromAddr = self.describeAddrList(
                    addrs:  self.vins.extractAddrList(except: addr)
                )
            case .withdrawal:
                fromAddr = addr
                toAddr = self.describeAddrList(
                    addrs:  self.vouts.extractAddrList(except: addr)
                )
            }
            
            record.addToCoins(fCoin)
            record.fromCoinID = fCoin.identifier
            record.fromAddress = fromAddr
            fCoin.addToTransRecords(record)
            
            let tCoin = Coin.btc
            record.addToCoins(tCoin)
            record.toCoinID = tCoin.identifier
            record.toAddress = toAddr
            tCoin.addToTransRecords(record)
    
            record.fromAmt = fromAmt as NSDecimalNumber
            record.toAmt = toAmt as NSDecimalNumber
            
            let feeCoin = Coin.btc
            record.feeCoinID = feeCoin.identifier
            //this cannot be fetched, use origin data if possible
            record.feeAmt = record.feeAmt ?? 1
            record.feeRate = record.feeRate ?? 1
            record.totalFee = self.totalFeeBTC as NSDecimalNumber
            
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
//                IdentifierUnit.str(keyPath: #keyPath(TransRecord.), value: wallet.encryptedPKey!)
            ],
            setup: setup
        )
    }
}
