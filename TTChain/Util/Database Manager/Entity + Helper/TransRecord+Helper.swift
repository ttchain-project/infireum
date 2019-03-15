//
//  TransRecord+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import CoreData

/// Describe all the needed properties to create a valid source, this is mainly used for parsing the data from server,
/// and attempt syncing to the database.
struct TransRecordCreateSource {
    struct From {
        let coinID: String
        let amt: Decimal
        let address: String
    }
    
    struct To {
        let coinID: String
        let amt: Decimal
        let address: String
    }
    
    struct Fee {
        let coinID: String
        //e.g. gas
        let amt: Decimal
        //e.g. gas price
        let rate: Decimal
        //e.g gWei = gas * gas price
        let total: Decimal
    }
    
    
    let from: From
    let to: To
    let fee: Fee
//    let wallet: Wallet
    let status: TransRecordStatus
//    let inoutType: TransInoutType
    let date: Date
    let confirmations: Int64
    
    //Optional
    let txID: String?
    let note: String?
    let block: Int64
    
    var transRecordSetup: (TransRecord) -> Void {
        return {
//            [unowned self]
            record in
            if record.fromCoinID! != self.from.coinID {
                warning("Detect diff FROM coin, this should not happened as coin should be always the same.")
                if let fCoin = Coin.getCoin(ofIdentifier: self.from.coinID) {
                    record.addToCoins(fCoin)
                    record.fromCoinID = self.from.coinID
                    record.fromAddress = self.from.address
                    fCoin.addToTransRecords(record)
                }
            }
            
            
            if record.toCoinID! != self.to.coinID {
                warning("Detect diff TO coin, this should not happened as coin should be always the same.")
                if let tCoin = Coin.getCoin(ofIdentifier: self.to.coinID) {
                    record.addToCoins(tCoin)
                    record.toCoinID = self.to.coinID
                    record.toAddress = self.to.address
                    tCoin.addToTransRecords(record)
                }
            }
            
            record.fromAmt = self.from.amt as NSDecimalNumber
            record.toAmt = self.to.amt as NSDecimalNumber
            
            if record.feeCoinID! != self.fee.coinID {
                warning("Detect diff FEE coin, this should not happened as coin should be always the same.")
                record.feeCoinID = self.to.coinID
            }
            
            record.feeAmt = self.fee.amt as NSDecimalNumber
            record.feeRate = self.fee.rate as NSDecimalNumber
            record.totalFee = self.fee.total as NSDecimalNumber
            
//            record.wallet = self.wallet
//            record.walletEPKey = self.wallet.encryptedPKey
            record.status = self.status.rawValue
//            record.inoutID = self.inoutType.rawValue
            record.date = self.date as NSDate
            record.confirmations = self.confirmations
            
            record.txID = self.txID
            record.note = self.note
            record.block = self.block
        }
    }
    
    func transformToSyncConcstructor() -> ManagedObejctConstructor<TransRecord> {
        let setup : (TransRecord) -> Void = transRecordSetup
        
        if let id = txID {
            //If has txid, use txid + walletEPKey as identifiers
            return ManagedObejctConstructor(
                idUnits: [
                    IdentifierUnit.str(keyPath: #keyPath(TransRecord.txID), value: id)
//                    IdentifierUnit.str(keyPath: #keyPath(TransRecord.walletEPKey), value: wallet.encryptedPKey!)
                ],
                setup: setup
            )
        }else {
            //Otherwise use wallet + date as identifiers
            return ManagedObejctConstructor(
                idUnits: [
                    IdentifierUnit.date(keyPath: #keyPath(TransRecord.date), value: date as NSDate)
//                    IdentifierUnit.str(keyPath: #keyPath(TransRecord.walletEPKey), value: wallet.encryptedPKey!)
                ],
                setup: setup
            )
        }
    }
}

extension Sequence where Element == TransRecordCreateSource {
    func syncToDatabase() -> [TransRecord] {
        //For each element required to sync into the database, it must has a txid, right now the nil-txid case will only occured locally, which means there's no need to sync.
        guard let syncedRecords = TransRecord.syncEntities(constructors: map { $0.transformToSyncConcstructor() }) else {
            return errorDebug(response: [])
        }
        
        return syncedRecords
    }
}

// MARK: - UI
extension TransRecord {
    func getRecordColor(ofAddress addr: String) -> UIColor {
        switch owStatus {
        case .failed: return TM.palette.recordStatus_failed
        case .success:
            guard let inoutType = inoutRoleOfAddress(addr) else {
                return TM.palette.recordStatus_failed
            }
            
            switch inoutType {
            case .deposit: return TM.palette.recordStatus_deposit
            case .withdrawal: return TM.palette.recordStatus_withdrawal
            }
        }
    }
}

//MARK: - Helper
extension TransRecord {
    func inoutRoleOfAddress(_ addr: String) -> TransInoutType? {
        if addr == fromAddress { return .withdrawal }
        else if addr == toAddress { return .deposit }
        else { return nil }
    }
    
    static func anyInoutPredicate(forAddress addr: String) -> NSPredicate {
        return NSCompoundPredicate.init(
            orPredicateWithSubpredicates: [
                predicate(forAddress: addr, inoutType: .withdrawal),
                predicate(forAddress: addr, inoutType: .deposit)
            ]
        )
    }
    
    static func predicate(forAddress addr: String, inoutType: TransInoutType) -> NSPredicate {
        switch inoutType {
        case .withdrawal:
            return TransRecord.genPredicate(
                fromIdentifierType:
                IdentifierUnit.str(
                    keyPath: #keyPath(TransRecord.fromAddress),
                    value: addr
                )
            )
        case .deposit:
            return TransRecord.genPredicate(
                fromIdentifierType:
                IdentifierUnit.str(
                    keyPath: #keyPath(TransRecord.toAddress),
                    value: addr
            ))
        }
    }
    
    var owStatus: TransRecordStatus {
        return TransRecordStatus.init(rawValue: status)!
    }
    
    static func getAllRecords(ofAddress address: String) -> [TransRecord]? {
        let localRecordsPred = anyInoutPredicate(forAddress: address)
        
        guard let recs = DB.instance.get(type: TransRecord.self, predicate: localRecordsPred, sorts: nil) else {
            return errorDebug(response: [])
        }
        
        let sortedRecs = recs.sorted {
            $0.date! as Date > $1.date! as Date
        }
        
        return sortedRecs
    }
    
    static func getAllRecords(ofWallet wallet: Wallet) -> [TransRecord]? {
        return getAllRecords(ofAddress: wallet.address!)
    }
    
    static func getAllRecords(ofAsset asset: Asset) -> [TransRecord]? {
        guard let wallet = asset.wallet else {
           return []
        }
        guard let walletRecs = getAllRecords(ofWallet: wallet) else {
            return errorDebug(response: [])
        }
        
        let assetsRecs = walletRecs.filter { $0.fromCoinID == asset.coinID || $0.toCoinID == asset.coinID }
        return assetsRecs
    }
    
    func transformToCreateSource() -> TransRecordCreateSource {
        return TransRecordCreateSource(
            from: TransRecordCreateSource.From(
                coinID: fromCoinID!,
                amt: fromAmt! as Decimal,
                address: fromAddress!
            ),
            to: TransRecordCreateSource.To(
                coinID: toCoinID!,
                amt: toAmt! as Decimal,
                address: toAddress!
            ),
            fee: TransRecordCreateSource.Fee(
                coinID: feeCoinID!,
                amt: feeAmt! as Decimal,
                rate: feeRate! as Decimal,
                total: totalFee! as Decimal
            ),
//            wallet: wallet!,
            status: owStatus,
//            inoutType: owInoutType,
            date: date! as Date,
            confirmations: confirmations,
            txID: txID,
            note: note,
            block: block
        )
    }
}

import RxSwift

//MARK: - API Call
extension TransRecord {
    /// Calling this function will async get local db data as first event and map the server fetched data later.
    ///
    ///
    /// - Returns:
    static func syncSources(of wallet: Wallet) -> Observable<[TransRecord]> {
        //FIXME: Use current data only, noupdate
        let inDBRecords = TransRecord.getAllRecords(ofWallet: wallet) ?? []
        return Observable.just(inDBRecords).concat(Observable.never())
    }
    
    static func syncSource(ofCoin coin: Coin, wallet: Wallet) -> Observable<[TransRecord]> {
        //FIXME:
        var dbValues: [TransRecord] = []
        let assets = Asset.getAllWalletAssetsUnderCurrenIdentity(wallet: wallet, selectedOnly: false)
        if let idx = assets.index(where: { (asset) -> Bool in
            return asset.coinID == coin.identifier!
        }) {
            dbValues = TransRecord.getAllRecords(ofAsset: assets[idx]) ?? []
        }
        
        //TODO: Fire blockchain request in here,
        return Observable.just(dbValues).concat(Observable.never())
    }
}

// MARK: - Mocking
extension TransRecord {
    @discardableResult static func mockAllPossibleRecordsOfCoin(coin: Coin, ofWallet wallet: Wallet) -> [TransRecord] {
        let setups: [(TransRecord) -> Void] = TransRecordStatus.allCases.map { (status) -> (TransRecord) -> Void in
            return {
                record in
                let txID: String? = status == .success ?  String(arc4random() % 100000000) : nil
                record.txID = txID
                
//                record.walletEPKey = wallet.encryptedPKey
//                record.wallet = wallet
//                wallet.addToTransRecords(record)
                
                record.status = status.rawValue
                
                record.fromCoinID = coin.identifier
                record.toCoinID = coin.identifier
                record.addToCoins(coin)
                coin.addToTransRecords(record)
                
                let fromAmt = Decimal.init(arc4random() % 1000) / Decimal.init(arc4random() % 1000)
                let feeRate = Decimal.init(arc4random() % 10) / 100.0
                let feeAmt = Decimal.init(arc4random() % 1000) / Decimal.init(arc4random() % 1000)
                let totalFee = feeAmt * feeRate
                let toAmt = fromAmt - totalFee
                
                record.feeCoinID = wallet.feeCoinID
                record.feeAmt = feeAmt as NSDecimalNumber
                record.feeRate = feeRate as NSDecimalNumber
                record.totalFee = totalFee as NSDecimalNumber
                
                record.fromAmt = fromAmt as NSDecimalNumber
                record.fromAddress = wallet.address
                
                record.toAmt = toAmt as NSDecimalNumber
                record.toAddress = String(wallet.address!.reversed())
                
                record.note = "123"
                record.date = Date() as NSDate
                record.syncDate = Date() as NSDate
                
                record.block = Int64(arc4random() % 1000)
                
//                let inoutType = TransInoutType.init(rawValue: Int16(arc4random() % 2))!
//                record.inoutID = inoutType.rawValue
            }
        }.flatMap {
            //Three times
            [$0, $0, $0]
        }
        
        guard let records = DB.instance.batchCreate(type: TransRecord.self, setups: setups) else {
            return errorDebug(response: [])
        }
        
        return records
    }
}
