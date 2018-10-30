//
//  CoinMigrationPolicy_InAppName.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
class MigrationPolicy_1_0_0To1_0_4: NSEntityMigrationPolicy {
//    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
//        print(sInstance)
//        let v = sInstance.value(forKey: "walletType")
//        print(v)
//    
//        return try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
//    }
    
    //Remember to add the @objc to make the selector of mapping model work.
    //Bugs fixed: Entity Mapping Function Must use NSNumber
    //https://stackoverflow.com/questions/52172414/int16-backed-enum-attribute-in-core-data-entity-appears-to-have-incorrect-value
    @objc func
        mainCoinID(ofOriginWalletTypeRaw raw: NSNumber) -> String {
        guard let chainType = ChainType.init(rawValue: raw.int16Value) else {
            warning("Unspoort raw: \(raw)")
            return ""
        }
        
        
        switch chainType {
        case .btc: return Coin.btc_identifier
        case .eth: return Coin.eth_identifier
        case .cic: return Coin.cic_identifier
        }
    }
    
    
    //MARK: Relationship
    //Use for creat to-many releationship of Coin to Wallet
    /// - Parameters:
    ///   - raw:
    ///   - manager:
    /// - Returns: [Wallets]
    @objc func asMainInWalletsRelationships(ofWalletTypeRaw raw: NSNumber, manager: NSMigrationManager) -> [NSManagedObject] {
        let req = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Wallet")
        let id = coinID(ofWalletTypeRaw: raw.int16Value)
        req.predicate = NSPredicate.init(format: "walletMainCoinID == %@", id)
        let wallets = try! manager.destinationContext.fetch(req) as! [NSManagedObject]
        
        return wallets
    }
    
    //Use for creat to-many releationship of Coin to AddressbookUnit
    /// - Parameters:
    ///   - raw:
    ///   - manager:
    /// - Returns: [AddressBookUnit]
    @objc func asMainInAddressBooksRelationships(ofWalletTypeRaw raw: NSNumber, manager: NSMigrationManager) -> [NSManagedObject] {
        let req = NSFetchRequest<NSFetchRequestResult>.init(entityName: "AddressBookUnit")
        let id = coinID(ofWalletTypeRaw: raw.int16Value)
        req.predicate = NSPredicate.init(format: "mainCoinID == %@", id)
        let abUnits = try! manager.destinationContext.fetch(req) as! [NSManagedObject]
        
        return abUnits
    }
    
    //Use for creat to-one releationship of AddressbookUnit/Wallet to Coin
    /// - Parameters:
    ///   - raw:
    ///   - manager:
    /// - Returns: Coin
    @objc func mainCoin(ofWalletTypeRaw raw: NSNumber, manager: NSMigrationManager) -> NSManagedObject {
        let req = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Coin")
        let id = coinID(ofWalletTypeRaw: raw.int16Value)
        req.predicate = NSPredicate.init(format: "identifier == %@", id)
        let originCoins = try! manager.destinationContext.fetch(req) as! [NSManagedObject]
        return originCoins[0]
    }
    
    private func coinID(ofWalletTypeRaw raw: Int16) -> String {
        let chainType = ChainType.init(rawValue: raw)!
        switch chainType {
        case .btc: return Coin.btc_identifier
        case .eth: return Coin.eth_identifier
        case .cic: return Coin.cic_identifier
        }
    }
}
