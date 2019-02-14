//
//  CoinToFiatRate+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

extension CoinToFiatRate {
    @discardableResult static func sync(coin: Coin, fiat: Fiat, rate: Decimal) -> CoinToFiatRate? {
        let con = ManagedObejctConstructor<CoinToFiatRate>.init(
            idUnits: [
                .str(keyPath: #keyPath(fromCoinID), value: coin.identifier!),
                .num(keyPath: #keyPath(toFiatID), value: fiat.id)
            ],
            setup: {
                r in
                r.coin = coin
                r.fromCoinID = coin.identifier
                coin.addToCoinToFiatRates(r)
                
                r.fiat = fiat
                r.toFiatID = fiat.id
                fiat.addToCoinToFiatRates(r)
                
                r.rate = rate as NSDecimalNumber
                r.syncDate = Date() as NSDate
            }
        )
        
        syncEntities(constructors: [con])
        return getRateFromDatabase(coinID: coin.identifier!, fiatID: fiat.id)
    }
    
    @discardableResult static func sync(coinID: String, fiatID: Int16, rate: Decimal) -> CoinToFiatRate? {
        let coinPred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.identifier), value: coinID)
        )
        
        let fiatPred = Fiat.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Fiat.id), value: fiatID))
        
        guard let coin = DB.instance.get(type: Coin.self, predicate: coinPred, sorts: nil)?.first,
            let fiat = DB.instance.get(type: Fiat.self, predicate: fiatPred, sorts: nil)?.first else {
                return errorDebug(response: nil)
        }
        
        return sync(coin: coin, fiat: fiat, rate: rate)
    }
    
    static func getRateFromDatabase(coinID: String, fiatID: Int16) -> CoinToFiatRate? {
        let pred = CoinToFiatRate.createPredicate(from: coinID, fiatID)
        return DB.instance.get(type: CoinToFiatRate.self, predicate: pred, sorts: nil)?.first
    }
}

import RxSwift
// MARK: - Server Update
extension CoinToFiatRate {
    /// Calling this function will attempt to get USD rate of the coin from server if possible, if failed, it will try to return the value from database, multiplied the USD-to-Fiat Rate, if still nil, means there' a network + syncing error.
    ///
    /// - Parameters:
    ///   - coin:
    ///   - fiat:
    /// - Returns:
    static func getRateFromServerIfPossible(coin: Coin, fiat: Fiat) -> Single<Decimal?> {
        
        let usdRate = Server.instance.getCoinToUSDRate(of: coin)
        guard let usd = Fiat.usd else {
            return errorDebug(response: Single.just(nil))
        }
        
        let usdToFiatRate = FiatToFiatRate.get(fromFiat: usd, toFiat: fiat)?.rate
        
        return usdRate.map {
            result -> NSDecimalNumber? in
            switch result {
                case .failed:
                    //If failed, try to return database value.mult
                    if let dbCoinToUSDRate = self.getRateFromDatabase(coinID: coin.identifier!, fiatID: usd.id)?.rate,
                        let usdToFiat = usdToFiatRate {
                        
                        return dbCoinToUSDRate.multiplying(by: usdToFiat)
                    }else {
                        return nil
                    }
                case .success(let model):
                    //If success, sync to the database and return the new rate
                    if let syncedUSDRate = self.sync(coin: coin, fiat: usd, rate: model.rate)?.rate,
                       let usdToFiat = usdToFiatRate {
                       return syncedUSDRate.multiplying(by: usdToFiat)
                    }else {
                        return nil
                    }
                
            }
        }
        .map { $0 == nil ? nil : $0! as Decimal }
    }
}
