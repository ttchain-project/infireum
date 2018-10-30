//
//  AddressBookUnit+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

struct AddressBookUnitCreateSource {
    let id: String
    let chainType: ChainType
    let mainCoinID: String
    let address: String
    let name: String
    let note: String?
}

extension AddressBookUnitCreateSource {
    func transformToSyncConcstructorIfPossible() -> ManagedObejctConstructor<AddressBookUnit>? {
        guard let mainCoin = Coin.getCoin(ofIdentifier: self.mainCoinID) else  { return nil }
        
        let setup : (AddressBookUnit) -> Void = {
            unit in
            
            unit.id = self.id
            let identity = Identity.singleton!
            unit.identity = identity
            unit.identityID = identity.id
            identity.addToAddressbookUnits(unit)
            unit.address = self.address
            unit.name = self.name
            unit.note = self.note
            unit.chainType = self.chainType.rawValue
            unit.mainCoinID = self.mainCoinID
            
            unit.mainCoin = mainCoin
            mainCoin.addToAsMainInAddressbookUnits(unit)
        }
        
        return ManagedObejctConstructor(
            idUnits: [
                IdentifierUnit.str(keyPath: #keyPath(AddressBookUnit.id), value: id)
            ],
            setup: setup
        )
    }
}

extension Sequence where Element == AddressBookUnitCreateSource {
    func syncToDatabase() -> [AddressBookUnit] {
        //For each element required to sync into the database, it must has a txid, right now the nil-txid case will only occured locally, which means there's no need to sync.
        guard let syncedRecords = AddressBookUnit.syncEntities(constructors: compactMap { $0.transformToSyncConcstructorIfPossible() }) else {
            return errorDebug(response: [])
        }
        
        return syncedRecords
    }
}


// MARK: - Helper
extension AddressBookUnit {
    var owChainType: ChainType {
        return ChainType.init(rawValue: chainType)!
    }
    
    static func findUnit(identity: Identity, addr: String, mainCoinID: String) -> AddressBookUnit? {
        let pred = AddressBookUnit.createPredicate(from: identity.id!, addr, mainCoinID)
        return DB.instance.get(type: self, predicate: pred, sorts: nil)?.first
    }
}

// MARK: - Mock
/*extension AddressBookUnit {
    @discardableResult static func mockUnits(ofIdentity identity: Identity) -> [AddressBookUnit] {
        let setups: [(AddressBookUnit) -> Void] = [ChainType.btc, ChainType.eth, ChainType.cic].map {
            chainType in
            return {
                unit in
                unit.id = UUID.init().uuidString
                unit.address = "0x123f298svjl2o8yFdkhdD"
                unit.chainType = chainType.rawValue
                unit.identity = identity
                unit.identityID = identity.id
                unit.note = "\(chainType) note"
                unit.name = "\(identity.name!) \(chainType)"
                unit.mainCoinID = ""
                identity.addToAddressbookUnits(unit)
            }
        }
        
        guard let units = DB.instance.batchCreate(type: AddressBookUnit.self, setups: setups) else {
            return errorDebug(response: [])
        }
        
        return units
    }
}*/
