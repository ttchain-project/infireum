//
//  Asset+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
extension Asset {
    static func getAllWalletAssetsUnderCurrenIdentity(wallet: Wallet, selectedOnly: Bool) -> [Asset] {
        /*
         let assetPred = Asset.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(walletEPKey), value: wallet.encryptedPKey!))
         guard let assets = DB.instance.get(type: self, predicate: assetPred, sorts: nil)?.filter({
         $0.wallet! == wallet
         }) else {
         return errorDebug(response: [])
         }
         */
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: selectedOnly)
        let assets = selections.compactMap { $0.findAsset() }
        return assets
    
    }
    
    
    static func getRSCAssets(forETHWallet wallet:Wallet) -> [Asset]{
        guard wallet.chainType == ChainType.eth.rawValue else {
            return []
        }
        
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: true)
        let assets = selections.filter { $0.coinIdentifier?.contains("_RSC") == true  }.compactMap { $0.findAsset() }
        return assets
    }
    
    static func getAirDropAssets(forETHWallet wallet:Wallet) -> [Asset]{
        guard wallet.chainType == ChainType.eth.rawValue else {
            return []
        }
        return []

//        let selections = CoinSelection.getAllSelections(of: wallet,
//                                                        filterIsSelected: true)
//        let assets = selections.filter { $0.coinIdentifier?.contains("_AIRDROP") == true  }.compactMap { $0.findAsset() }
//        return assets
    }
    
    static func getETHAssets(forETHWallet wallet:Wallet) -> [Asset] {
        guard wallet.chainType == ChainType.eth.rawValue else {
            return []
        }
        
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: true)
        let assets = selections.filter { $0.coinIdentifier?.contains("_FIAT") == false  }.compactMap { $0.findAsset() }
        return assets
    }
    
    static func getBTCAssets(forBTCWallet wallet:Wallet) -> [Asset] {
        guard wallet.chainType == ChainType.btc.rawValue else {
            return []
        }
        
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: true)
        let assets = selections.filter { $0.coinIdentifier != Coin.usdt_identifier  }.compactMap { $0.findAsset() }
        return assets
    }
    
    static func getStableETHAssets(forETHWallet wallet:Wallet) -> [Asset] {
        guard wallet.chainType == ChainType.eth.rawValue else {
            return []
        }
        
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: true)
        let assets = selections.filter { $0.coinIdentifier?.contains("_FIAT") == true  }.compactMap { $0.findAsset() }
        return assets
    }
    
    static func getStableBTCAssets(forBTCWallet wallet:Wallet) -> [Asset] {
        guard wallet.chainType == ChainType.btc.rawValue else {
            return []
        }
        
        let selections = CoinSelection.getAllSelections(of: wallet,
                                                        filterIsSelected: true)
        let assets = selections.filter { $0.coinIdentifier == Coin.usdt_identifier  }.compactMap { $0.findAsset() }
        return assets
    }
    
    static func getAssetsForCoin(coin:Coin) -> [Asset] {
        let assetPred = Asset.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(coinID), value: coin.identifier!))
        guard let assets = DB.instance.get(type: self, predicate: assetPred, sorts: nil)?.filter({ $0.wallet != nil }) else {
            return errorDebug(response: [])
        }
        return assets
    }
    
    static func createDefaultEntitiesOfWallet(wallet: Wallet) -> [Asset] {
        let coinPred = Coin.genPredicate(
            fromIdentifierType:
            .str(
                keyPath: #keyPath(Coin.walletMainCoinID),
                value: wallet.walletMainCoinID!
            )
        )
        
        guard let _coins = DB.instance.get(type: Coin.self, predicate: coinPred, sorts: nil) else {
            return errorDebug(response: [])
        }
        
        let defaultCoins = _coins.filter { $0.isDefault }
        let assetSetups: [(Asset) -> Void] = defaultCoins.map {
            coin -> ((Asset) -> Void) in
            return {
                asset in
                asset.coinID = coin.identifier!
                #if DEBUG
                //                asset.amount = 100
                asset.amount = 0
                #else
                asset.amount = 0
                #endif
                
                asset.walletEPKey = wallet.encryptedPKey
                asset.wallet = wallet
                //Wallet Asset add will perform later
                asset.coin = coin
                coin.addToAssets(asset)
            }
        }
        
        guard let assets = DB.instance.batchCreate(type: Asset.self, setups: assetSetups) else {
            return errorDebug(response: [])
        }
        
        let coinSelectionSetups: [(CoinSelection) -> Void] = defaultCoins.map {
            coin -> ((CoinSelection) -> Void) in
            return {
                selection in
                selection.coinIdentifier = coin.identifier
                selection.coin = coin
                coin.addToCoinSelections(selection)
                selection.walletEPKey = wallet.encryptedPKey!
                
                selection.wallet = wallet
                //Wallet selection add will perform later
                
                selection.isSelected = coin.isDefaultSelected
                
            }
        }
        
        guard let selections = DB.instance.batchCreate(type: CoinSelection.self, setups: coinSelectionSetups) else {
            return errorDebug(response: assets)
        }
        
        wallet.addToCoinSelections(NSOrderedSet.init(array: selections))
        wallet.addToAssets(NSOrderedSet.init(array: assets))
        
        DB.instance.update()
        
        return assets
    }
    
    func updateAmt(_ amt: Decimal) {
        self.amount = amt as NSDecimalNumber
        DB.instance.update()
    }
    
}

import RxSwift
// MARK: - Server Update
extension Asset {
    /// Calling this function will attempt to get the amt of the asset from Blockchain if possible, if failed, it will try to return the value from database, if still nil, means there' a network + syncing error.
    /// NOTE: Asset getFromsServer function is assumed to be instance function because there should always has asset first in current spec.
    ///
    /// - Parameters:
    ///   - coin:
    ///   - fiat:
    /// - Returns:
    func getAmtFromServerIfPossible() -> Single<Decimal?> {
        
        return Server.instance.getAssetAmt(ofAsset: self)
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: _): return self.amount as Decimal?
                case .success(let model):
                    let balance = model.balanceInCoin
                    self.amount = balance as NSDecimalNumber
                    DB.instance.update()
                    return balance
                }
        }
    }
}

// MARK: - Block Cache
extension Asset {
    var latestBlockHeightCache: Int? {
        return TxBlockCache.blockHeight(forAsset: self)
    }
    
    func setBlockHeight(_ height: Int) {
        TxBlockCache.setBlockHeight(height, forAsset: self)
    }
}
