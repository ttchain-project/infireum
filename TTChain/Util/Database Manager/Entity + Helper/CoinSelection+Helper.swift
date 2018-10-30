//
//  CoinSelection+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/26.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

extension CoinSelection {
    /// Attempting marking a coinSelection of the wallet, will auto check if there's a correspond CoinSelection, create new CoinSelection if needed.
    ///
    /// - Parameters:
    ///   - wallet:
    ///   - coin:
    ///   - isSelected:
    /// - Returns:
    static func markSelection(of wallet: Wallet, coin: Coin, isSelected: Bool) -> CoinSelection? {
        let pred = CoinSelection.createPredicate(from: wallet.encryptedPKey!, coin.identifier!)
        guard let sel = DB.instance.get(type: self, predicate: pred, sorts: nil)?.first else {
            //Not found a matched CoinSelectoin, try to create a new one.
            return createSelection(of: wallet, coin: coin, isSelected: isSelected)
        }
        
        sel.isSelected = isSelected
        guard DB.instance.update() else {
            return errorDebug(response: nil)
        }
        
        return sel
    }
    
    /// Create a new CoinSelection of the wallet, will auto check if there's a correspond asset, create new asset if needed.
    ///
    /// - Parameters:
    ///   - wallet:
    ///   - coin:
    ///   - isSelected:
    /// - Returns:
    static func createSelection(of wallet: Wallet, coin: Coin, isSelected: Bool) -> CoinSelection? {
        guard let newSel = DB.instance.create(type: self, setup: {
            sel in
            sel.isSelected = isSelected
            sel.coin = coin
            sel.coinIdentifier = coin.identifier
            coin.addToCoinSelections(sel)
            
            sel.wallet = wallet
            sel.walletEPKey = wallet.encryptedPKey
            wallet.addToCoinSelections(sel)
        }) else {
            return errorDebug(response: nil)
        }
        
        // After create new coin selection, check is there's a corresponding asset exist in db, if not, creat a new one.
        if let _assets = wallet.assets?.array as? [Asset] {
            guard _assets.contains(where: { (asset) -> Bool in
                return asset.coinID! == coin.identifier!
            }) else {
                //In here means there's no asset found in the wallet assets list. so create a new one.
                guard wallet.createNewAsset(ofCoin: coin) != nil else {
                    return nil
                }
                
                DB.instance.update()
                return newSel
            }
            
            //In here means find a correspond asset, just return newSel
            DB.instance.update()
            return newSel
        } else {
            //In here means there's no asset found in the wallet assets list. so create a new one.
            guard wallet.createNewAsset(ofCoin: coin) != nil else {
                return nil
            }
            
            DB.instance.update()
            return newSel
        }
    }
    
    static func getAllSelections(of wallet: Wallet, filterIsSelected: Bool) -> [CoinSelection] {
        let pred = CoinSelection.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(walletEPKey), value: wallet.encryptedPKey!))
        guard let sels = DB.instance.get(type: CoinSelection.self, predicate: pred, sorts: nil)?.filter({ (sel) -> Bool in
            return sel.wallet!.walletMainCoinID == wallet.walletMainCoinID
        }) else {
            return errorDebug(response: [])
        }
        
        if filterIsSelected {
            return sels.filter { $0.isSelected }
        }else {
            return sels
        }
    }
    
    func findAsset() -> Asset? {
        let pred = Asset.createPredicate(from: walletEPKey!, coinIdentifier!)
        guard let asset = DB.instance.get(type: Asset.self, predicate: pred, sorts: nil)?.first else {
            return errorDebug(response: nil)
        }
        
        return asset
    }
}
