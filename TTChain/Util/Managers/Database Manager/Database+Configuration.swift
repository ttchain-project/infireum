//
//  Database+Configuration.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

fileprivate let _flag_configed_identifier: String = "_flag_configed_identifier"

extension DatabaseManager {
    
    var hasConfiged: Bool {
        return UserDefaults.standard.bool(forKey: _flag_configed_identifier)
    }
    
    func markConfiged() {
        UserDefaults.standard.set(true, forKey: _flag_configed_identifier)
    }
    
    func markUnconfiged() {
        UserDefaults.standard.set(false, forKey: _flag_configed_identifier)
    }
    
    func defaultConfigure() -> Single<Bool> {
        let configureResults = Observable.combineLatest(localConfigure(), remoteConfigure()).debug().map { $0 && $1 }.map {
            [unowned self] result -> Bool in
            
            if result {
                self.markConfiged()
            }
            
            return result
            
        }.asSingle()
        
        return configureResults
    }
    
    fileprivate func configureDefaultEntity<E: KLIdentifiableManagedObject>(type: E.Type, flag: inout Bool) {
        guard flag else { return }
        if type.createDefaultEntities() == nil {
            flag = true
        }
    }
    
    fileprivate func localConfigure() -> Observable<Bool> {
        var finishFlag: Bool = true
        
        configureDefaultEntity(type: Asset.self, flag: &finishFlag)
        configureDefaultEntity(type: Language.self, flag: &finishFlag)
        configureDefaultEntity(type: FiatToFiatRate.self, flag: &finishFlag)
        configureDefaultEntity(type: Identity.self, flag: &finishFlag)
        configureDefaultEntity(type: CoinToFiatRate.self, flag: &finishFlag)
        configureDefaultEntity(type: CoinRate.self, flag: &finishFlag)
        configureDefaultEntity(type: AddressBookUnit.self, flag: &finishFlag)
        configureDefaultEntity(type: LightningTransRecord.self, flag: &finishFlag)
        configureDefaultEntity(type: TransRecord.self, flag: &finishFlag)
        configureDefaultEntity(type: Wallet.self, flag: &finishFlag)
        configureDefaultEntity(type: Fiat.self, flag: &finishFlag)
        configureDefaultEntity(type: SubAddress.self, flag: &finishFlag)
        configureDefaultEntity(type: Coin.self, flag: &finishFlag)
        configureDefaultEntity(type: ServerSyncRecord.self, flag: &finishFlag)
        
        return Observable.just(finishFlag)
    }
    
    fileprivate func remoteConfigure() -> Observable<Bool> {
        //Fire API and wait for configuration responses
        let getCoin = Server.instance.getCoins(
            queryString: nil,
            chainType: nil,
            defaultOnly: true,
            mainCoinID: nil
            ).map {
                
            result -> Bool in
            switch result {
            case .failed(let err):
                print(err)
                //NOTE: Should we handle error here?
                return false
            case .success(let model):
                if let allCoins = Coin.syncEntities(constructors: Coin.createConstructorsFromServerAPIModelSources(model.sources)) {
                    let mainCoins = allCoins.reduce([], { (coinIDs, coin) -> [String] in
                        if coinIDs.contains(coin.walletMainCoinID!) {
                            return coinIDs
                        }else {
                            return coinIDs + [coin.walletMainCoinID!]
                        }
                    })
                    
//                    MainCoinTypStorage.syncRemoteMainCoinIDs(mainCoins)
                }
                
                ServerSyncRecord.markEntitySyncRecord(entityType: Coin.self)
                return true
            }
                
           
        }
        
        
        let getFiat = Server.instance.getFiats().map {
            result -> Bool in
            switch result {
            case .failed:
                //NOTE: SHould we handle error here?
                return false
            case .success(let model):
                Fiat.syncEntities(constructors: Fiat.createConstructorsFromServerAPIModelSources(model.sources))
                ServerSyncRecord.markEntitySyncRecord(entityType: Fiat.self)
                return true
            }
        }
        
        let getUSDFiatRateTable = FiatToFiatRate.sync()
        
        return Observable.combineLatest(
            getCoin.asObservable(), getFiat.asObservable(), getUSDFiatRateTable.asObservable()
            )
            //            .debug("Get remotae configure (coins, fiats, fiatRateTable)")
            .map {
                $0 && $1 && $2
                
        }
    }
}
