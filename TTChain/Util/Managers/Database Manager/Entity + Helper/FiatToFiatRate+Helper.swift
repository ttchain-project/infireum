//
//  DatabaseEntity+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
extension FiatToFiatRate {
    static func createConstructorsFromUSDRateTableAPIModel(_ model: FiatRateTableAPIModel) -> [ManagedObejctConstructor<FiatToFiatRate>] {
        let usdID = SystemDefaultFiat.USD.rawValue
        let fromUnit: IdentifierUnit = IdentifierUnit.num(keyPath: #keyPath(fromFiatID) , value: usdID)
        let constructors = model.source.map { (k, v) -> ManagedObejctConstructor<FiatToFiatRate> in
            let toUnit: IdentifierUnit = IdentifierUnit.num(keyPath: #keyPath(toFiatID) , value: k)
            return ManagedObejctConstructor<FiatToFiatRate>(idUnits: [fromUnit, toUnit], setup: { ffRate in
                ffRate.fromFiatID = usdID
                ffRate.toFiatID = k
                ffRate.rate = v as NSDecimalNumber
                ffRate.syncDate = Date() as NSDate
                
                let fromPred = Fiat.genPredicate(fromIdentifierType: IdentifierUnit.num(keyPath: #keyPath(Fiat.id), value: usdID))
                let toPred = Fiat.genPredicate(fromIdentifierType: IdentifierUnit.num(keyPath: #keyPath(Fiat.id), value: k))
                let pred = NSCompoundPredicate.init(orPredicateWithSubpredicates: [fromPred, toPred])
                if let fiats = DB.instance.get(type: Fiat.self, predicate: pred, sorts: nil), fiats.count <= 2 {
                    for fiat in fiats {
                        fiat.addToFiatToFiatRates(ffRate)
                    }
                    
                    ffRate.addToFiats(NSOrderedSet.init(array: fiats))
                }else {
                    errorDebug(response: ())
                }
            })
        }
        
        return constructors
    }
}


extension FiatToFiatRate {
    static func sync() -> Single<Bool> {
        return Server.instance.getFiatTable().map {
            result -> Bool in
            switch result {
            case .failed:
                //NOTE: SHould we handle error here?
                return false
            case .success(let model):
                FiatToFiatRate.syncEntities(constructors: FiatToFiatRate.createConstructorsFromUSDRateTableAPIModel(model))
                ServerSyncRecord.markEntitySyncRecord(entityType: FiatToFiatRate.self)
                return true
            }
        }
    }
    
    static func get(fromFiat fFiat: Fiat, toFiat tFiat: Fiat) -> FiatToFiatRate? {
        let pred = FiatToFiatRate.createPredicate(from: fFiat.id, tFiat.id)
        guard let rate = DB.instance.get(type: FiatToFiatRate.self, predicate: pred, sorts: nil)?.first else {
            return errorDebug(response: nil)
        }
        
        return rate
    }
}
