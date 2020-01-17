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

enum ToAddressSource {
    case local(wallet: Wallet)
    case remote(addr: String?)
    
    var address: String? {
        switch self {
        case .local(wallet: let wallet): return wallet.address
        case .remote(addr: let addr): return addr
        }
    }
}


struct LightningTransRecordCreateSource {
    struct From {
        let coinID: String
        let amt: Decimal
        let address: String
        
        var fromCoin: Coin? {
            return Coin.getCoin(ofIdentifier: coinID)
        }
        
        var fromWallet: Wallet? {
            if let coin = fromCoin {
                return Wallet.getWallet(ofAddress: address, mainCoinID: coin.walletMainCoinID!)
            }else {
                return nil
            }
        }
    }
    
    struct To {
        let coinID: String
        let amt: Decimal
        let addressSource: ToAddressSource
        var address: String? {
            return addressSource.address
        }
        
        var toCoin: Coin? {
            return Coin.getCoin(ofIdentifier: coinID)
        }
        
        var toWallet: Wallet? {
            if let coin = toCoin, let addr = address {
                return Wallet.getWallet(ofAddress: addr, mainCoinID: coin.walletMainCoinID!)
            }else {
                return nil
            }
        }
    }
    
    struct Fee {
        let coinID: String
        //e.g. gas
        var amt: Decimal
        //e.g. gas price
        let rate: Decimal
        //e.g gWei = gas * gas price
        var total: Decimal {
            return amt * rate
        }
        
        let option: FeeManager.Option?
        
        var feeCoin: Coin {
            return Coin.getCoin(ofIdentifier: coinID)!
        }
    }
    
    
    let from: From
    let to: To
    let transRate: Decimal
    var fee: Fee
    
    let status: TransRecordStatus
//    let inoutType: TransInoutType
    let date: Date
    let confirmations: Int64
    
    //Optional
    let txID: String?
    let note: String?
    let block: Int64
    
    var transRecordSetup: (LightningTransRecord) -> Void {
        return {
            //            [unowned self]
            record in
            if record.fromCoinID! != self.from.coinID {
                warning("Detect diff FROM coin, this should not happened as coin should be always same.")
                if let fCoin = Coin.getCoin(ofIdentifier: self.from.coinID) {
                    record.addToCoins(fCoin)
                    record.fromCoinID = self.from.coinID
                    record.fromAddress = self.from.address
                    fCoin.addToLightningTransRecords(record)
                }
            }
            
            
            if record.toCoinID! != self.to.coinID {
                warning("Detect diff TO coin, this should not happened as coin should be always same.")
                if let tCoin = Coin.getCoin(ofIdentifier: self.to.coinID) {
                    record.addToCoins(tCoin)
                    record.toCoinID = self.to.coinID
                    record.toAddress = self.to.address
                    tCoin.addToLightningTransRecords(record)
                }
            }
            
            record.fromAmt = self.from.amt as NSDecimalNumber
            record.toAmt = self.to.amt as NSDecimalNumber
            
            if record.feeCoinID! != self.fee.coinID {
                warning("Detect diff FEE coin, this should not happened as coin should be always same.")
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
            
            record.txID = self.txID
            record.note = self.note
            record.block = self.block
        }
    }
    
    func transformToSyncConcstructor() -> ManagedObejctConstructor<LightningTransRecord> {
        let setup : (LightningTransRecord) -> Void = transRecordSetup
        
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

extension Sequence where Element == LightningTransRecordCreateSource {
    func syncToDatabase() -> [LightningTransRecord] {
        //For each element required to sync into the database, it must has a txid, right now the nil-txid case will only occured locally, which means there's no need to sync.
        guard let syncedRecords = LightningTransRecord.syncEntities(constructors: map { $0.transformToSyncConcstructor() }) else {
            return errorDebug(response: [])
        }
        
        return syncedRecords
    }
}

// MARK: - UI
//extension LightningTransRecord {
//    var recordColor: UIColor {
//        switch owStatus {
//        case .failed: return TM.palette.recordStatus_failed
//        case .success:
//            switch owInoutType {
//            case .deposit: return TM.palette.recordStatus_deposit
//            case .withdrawal: return TM.palette.recordStatus_withdrawal
//            }
//        }
//    }
//}

//MARK: - Helper
extension LightningTransRecord {
//    var owInoutType: TransInoutType {
//        return TransInoutType.init(rawValue: inoutID)!
//    }
    
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
            return LightningTransRecord.genPredicate(
                fromIdentifierType:
                IdentifierUnit.str(
                    keyPath: #keyPath(LightningTransRecord.fromAddress),
                    value: addr
                )
            )
        case .deposit:
            return LightningTransRecord.genPredicate(
                fromIdentifierType:
                IdentifierUnit.str(
                    keyPath: #keyPath(LightningTransRecord.toAddress),
                value: addr
            ))
        }
    }
    
    var owStatus: TransRecordStatus {
        return TransRecordStatus.init(rawValue: status)!
    }
    
    static func getAllRecords(ofWallet wallet: Wallet) -> [LightningTransRecord]? {
        let localRecordsPred = anyInoutPredicate(forAddress: wallet.address!)
        
        guard let recs = DB.instance.get(type: LightningTransRecord.self, predicate: localRecordsPred, sorts: nil) else {
            return errorDebug(response: [])
        }
        
        let sortedRecs = recs.sorted {
            $0.date! as Date > $1.date! as Date
        }
        
        return sortedRecs
    }
    
    static func getAllRecords(ofAsset asset: Asset) -> [LightningTransRecord]? {
        guard let walletRecs = getAllRecords(ofWallet: asset.wallet!) else {
            return errorDebug(response: [])
        }
        
        let assetsRecs = walletRecs.filter { $0.fromCoinID == asset.coinID || $0.toCoinID == asset.coinID }
        return assetsRecs
    }
    
    func transformToCreateSource() -> LightningTransRecordCreateSource {
//        let wallet = Wallet.getWallet(ofAddress: , chainType: )
        return LightningTransRecordCreateSource(
            from: LightningTransRecordCreateSource.From(
                coinID: fromCoinID!,
                amt: fromAmt! as Decimal,
                address: fromAddress!
            ),
            to: LightningTransRecordCreateSource.To(
                coinID: toCoinID!,
                amt: toAmt! as Decimal,
                addressSource: .remote(addr: toAddress!)
            ),
            transRate: (fromAmt! as Decimal) / (toAmt! as Decimal),
            fee: LightningTransRecordCreateSource.Fee(
                coinID: feeCoinID!,
                amt: feeAmt! as Decimal,
                rate: feeRate! as Decimal,
//                total: totalFee! as Decimal,
                option: nil
            ),
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
extension LightningTransRecord {
    /// Calling this function will async get local db data as first event and map the server fetched data later.
    ///
    ///
    /// - Returns:
    static func syncSources(of wallet: Wallet) -> Observable<[LightningTransRecord]> {
        //FIXME: Use mock data logic, get the local, create a new, and update it
        let inDBRecords = LightningTransRecord.getAllRecords(ofWallet: wallet) ?? []
        return Observable.just(inDBRecords).concat(Observable.never())
    }
    
    static func syncSource(ofCoin coin: Coin, wallet: Wallet) -> Observable<[LightningTransRecord]> {
        //FIXME:
        var dbValues: [LightningTransRecord] = []
        let assets = Asset.getAllWalletAssetsUnderCurrenIdentity(wallet: wallet, selectedOnly: false)
        if let idx = assets.index(where: { (asset) -> Bool in
            return asset.coinID == coin.identifier!
        }) {
            dbValues = LightningTransRecord.getAllRecords(ofAsset: assets[idx]) ?? []
        }
        
        //TODO: Fire blockchain request in here,
        return Observable.just(dbValues).concat(Observable.never())
    }
}

// MARK: - Mocking
extension LightningTransRecord {
    static func mockAllPossibleRecords(ofWallet wallet: Wallet) {
//        for fC in Coin.lightningTransactionFromCoins(ofChainType: wallet.owChainType) {
//            for tC in Coin.lightningTransactionToCoins(withFromCoin: fC) {
//                mockAllPossibleRecordsOfCoin(fromCoin: fC, toCoin: tC, ofWallet: wallet)
//            }
//        }
    }
    
    @discardableResult static func mockAllPossibleRecordsOfCoin(fromCoin: Coin, toCoin: Coin, ofWallet wallet: Wallet) -> [LightningTransRecord] {
        let setups: [(LightningTransRecord) -> Void] = TransRecordStatus.allCases.map { (status) -> (LightningTransRecord) -> Void in
            return {
                record in
                let txID: String? = status == .success ?  String(arc4random() % 100000000) : nil
                record.txID = txID
                
//                record.walletEPKey = wallet.encryptedPKey
//                record.wallet = wallet
//                wallet.addToLighningTransRecords(record)
                
                record.status = status.rawValue
                
                record.fromCoinID = fromCoin.identifier
                record.toCoinID = toCoin.identifier
                record.addToCoins(fromCoin)
                record.addToCoins(toCoin)
                fromCoin.addToLightningTransRecords(record)
                toCoin.addToLightningTransRecords(record)
                
                let fromAmt = Decimal.init(arc4random() % 1000) / Decimal.init(arc4random() % 1000)
                let feeRate = Decimal.init(arc4random() % 10) / 100.0
                let feeAmt = Decimal.init(arc4random() % 1000) / Decimal.init(arc4random() % 1000)
                let totalFee = feeAmt * feeRate
                let toAmt = fromAmt - totalFee
                
                switch fromCoin.owChainType {
                case .btc:
                    record.feeCoinID = Coin.btc_identifier
                case .cic:
                    record.feeCoinID = Coin.cic_identifier
                case .eth,.ttn,.ifrc:
                    fatalError()
                }
                record.feeAmt = feeAmt as NSDecimalNumber
                record.feeRate = feeRate as NSDecimalNumber
                record.totalFee = totalFee as NSDecimalNumber
                
                record.fromAmt = fromAmt as NSDecimalNumber
                record.fromAddress = wallet.address
                
                record.toAmt = toAmt as NSDecimalNumber
                record.toAddress = String(wallet.address!)
                record.confirmations = 0
                
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
        
        guard let records = DB.instance.batchCreate(type: LightningTransRecord.self, setups: setups) else {
            return errorDebug(response: [])
        }
        
        return records
    }
}
