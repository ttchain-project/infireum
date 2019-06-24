//
//  CoinRate+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
extension CoinRate {
    @discardableResult static func sync(fromCoin: Coin, toCoin: Coin, rate: Decimal) -> CoinRate? {
        let con = ManagedObejctConstructor<CoinRate>.init(
            idUnits: [
                .str(keyPath: #keyPath(fromCoinID), value: fromCoin.identifier!),
                .str(keyPath: #keyPath(toCoinID), value: toCoin.identifier!)
            ],
            setup: {
                r in
                r.fromCoinID = fromCoin.identifier
                r.addToCoins(fromCoin)
                fromCoin.addToCoinToCoinRates(r)
                
                r.toCoinID = toCoin.identifier
                r.addToCoins(toCoin)
                toCoin.addToCoinToCoinRates(r)
                
                r.rate = rate as NSDecimalNumber
                r.syncDate = Date() as NSDate
        }
        )
        
        //Beacuase we can assume there's only one rate in it
        return syncEntities(constructors: [con])?.first
    }
    
    @discardableResult static func sync(fromCoinID: String, toCoinID: String, rate: Decimal) -> CoinRate? {
        let fCoinPred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.identifier), value: fromCoinID)
        )
        
        let tCoinPred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.identifier), value: toCoinID)
        )
        
        guard let fCoin = DB.instance.get(type: Coin.self, predicate: fCoinPred, sorts: nil)?.first,
            let tCoin = DB.instance.get(type: Coin.self, predicate: tCoinPred, sorts: nil)?.first else {
                return errorDebug(response: nil)
        }
        
        return sync(fromCoin: fCoin, toCoin: tCoin, rate: rate)
    }
    
    static func getRateFromDatabase(fromCoinID: String, toCoinID: String) -> CoinRate? {
        let pred = CoinRate.createPredicate(from: fromCoinID, toCoinID)
        return DB.instance.get(type: CoinRate.self, predicate: pred, sorts: nil)?.first
    }
}

import RxSwift
// MARK: - Server Update
extension CoinRate {
    /// Calling this function will attempt to get current fiat rate of the coin from server if possible, if failed, it will try to return the value from database, if still nil, means there' a network + syncing error.
    ///
    /// - Parameters:
    ///   - coin:
    ///   - fiat:
    /// - Returns:
    static func getRateFromServerIfPossible(fromCoin: Coin, toCoin: Coin) -> Single<Decimal?> {
        //TODO: Using mock data now. Shuold change to Server api.
        let fakeValue: RxAPIResponse<Decimal> = RxAPIResponse.just(.success(Decimal.init(1)))
        return fakeValue.map {
            result -> NSDecimalNumber? in
            switch result {
            case .failed:
                //If failed, try to return database value
                return self.getRateFromDatabase(fromCoinID: fromCoin.identifier!, toCoinID: toCoin.identifier!)?.rate
            case .success(let value):
                //If success, sync to the database and return the new rate
                return self.sync(fromCoin: fromCoin, toCoin: toCoin, rate: value)?.rate
            }}
            .map { $0 == nil ? nil : $0! as Decimal }
    }
}
