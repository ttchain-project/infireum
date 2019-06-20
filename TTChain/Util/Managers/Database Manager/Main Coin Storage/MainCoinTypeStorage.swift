//
//  MainCoinTypeStorage.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
struct MainCoinTypStorage {
    
    /// Flags to check is the main coin sync has finished in this launch.
    static private var syncedFlag: Bool = false
    
    static var onSynced: Observable<Void> {
        if syncedFlag {
            return .just(())
        }else {
            return OWRxNotificationCenter.instance.onSyncedRemoteMainCoinIDs
        }
    }
    
    static var supportMainCoins: [Coin] {
        return supportMainCoinIDs.compactMap { Coin.getCoin(ofIdentifier: $0) }
    }
    
    static var supportMainCoinIDs: [String]
        = [
        Coin.btc_identifier,
        Coin.eth_identifier
//        Coin.cic_identifier
//        Coin.guc_identifier
    ]
    
    static func syncRemoteMainCoinIDs(_ ids: [String]) {
        print("Syncing Rate Main CoinIDs:\n\(ids)")
        for id in ids {
            if !supportMainCoinIDs.contains(id) &&
                Coin.getCoin(ofIdentifier: id) != nil {
                supportMainCoinIDs.append(id)
            }
        }
        
        syncedFlag = true
        OWRxNotificationCenter.instance.didSyncRemoteMainCoinIDs()
    }
}
