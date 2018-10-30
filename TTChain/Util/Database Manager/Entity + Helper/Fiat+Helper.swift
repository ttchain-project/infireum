//
//  Fiat+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
extension Fiat {
    var fullSymbol: String {
        return name! + symbol!
    }
    
    static func createConstructorsFromServerAPIModelSources(_ sources: [FiatsAPIModel.FiatSource]) -> [ManagedObejctConstructor<Fiat>] {
        return sources.map {
            source -> ManagedObejctConstructor<Fiat> in
            let idUnits: [IdentifierUnit] = [
                .num(keyPath: #keyPath(id), value: source.id)
            ]
            
            let setup: (Fiat) -> Void = {
                fiat in
                fiat.id = source.id
                fiat.name = source.name
                fiat.symbol = source.symbol
            }
            
            return ManagedObejctConstructor<Fiat>(idUnits: idUnits, setup: setup)
        }
    }
    
//    static func markIdentity(_ identity: Identity) {
//        let pred = Fiat.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(id), value: identity.prefFiatID))
//        guard let fiat = DB.instance.get(type: Fiat.self, predicate: pred, sorts: nil)?.first else {
//            return errorDebug(response: ())
//        }
//        
//        fiat.identity = identity
//        identity.fiat = fiat
//        
//        DB.instance.update()
//    }
    
    @discardableResult static func markIdToIdentity(fiatId: Int16, identity: Identity) -> Bool {
        let pred = Fiat.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Fiat.id), value: fiatId))
        guard let fiat = DB.instance.get(type: Fiat.self, predicate: pred, sorts: nil)?.first else {
            return errorDebug(response: false)
        }
        
        identity.fiat = fiat
        identity.prefFiatID = fiatId
        fiat.identity = identity
        
        return DB.instance.update()
    }
}


extension Fiat {
    static var usd: Fiat? {
        let pred = Fiat.createPredicate(from: SystemDefaultFiat.USD.rawValue)
        return DB.instance.get(type: Fiat.self, predicate: pred, sorts: nil)?.first
    }
}
