//
//  TxBlockCache.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/2.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class TxBlockCache {
    private static let btcBlockHeightCacheKey = "btcBlockHeightCacheKey"
    private static let ethBlockHeightCacheKey = "ethBlockHeightCacheKey"
    private static let cicBlockHeightCacheKey = "cicBlockHeightCacheKey"
    
    //Address: [CoinID:BlockHeight]
    typealias AssetBlockMap = [String : AddressMap]
    typealias AddressMap = [String : Int]
    
    static var btcTxBlockHeight: Int? {
        let height = UserDefaults.standard.integer(forKey: btcBlockHeightCacheKey)
        return height > 0 ? height : nil
    }
    
    public static func setBlockHeight(_ height: Int, forAsset asset: Asset) {
        let key: String
        switch asset.coin!.owChainType {
        case .btc:
            key = btcBlockHeightCacheKey
        case .eth:
            key = ethBlockHeightCacheKey
        case .cic:
            key = cicBlockHeightCacheKey
        case .ttn,.ifrc:
            key = ""
        }
        
        var map = assetBlockMap(forKey: key)
        if map[asset.wallet!.address!] != nil {
            map[asset.wallet!.address!]![asset.coinID!] = height
        }else {
            map[asset.wallet!.address!] = [asset.coinID! : height]
        }
        
        UserDefaults.standard.set(map, forKey: key)
    }
    
    public static func blockHeight(forAsset asset: Asset) -> Int? {
        return nil
        let assetBlock = assetBlockMap(forAsset: asset)
        if let addressMap = assetBlock[asset.wallet!.address!] {
            return addressMap[asset.coinID!]
        }else {
            return nil
        }
    }
    
    private static func assetBlockMap(forAsset asset: Asset) -> AssetBlockMap {
        switch asset.coin!.owChainType {
        case .btc:
            return btcAssetBlockMap
        case .eth:
            return ethAssetBlockMap
        case .cic,.ttn,.ifrc:
            fatalError()
        }
    }
    
    private static var btcAssetBlockMap: AssetBlockMap {
        return assetBlockMap(forKey: btcBlockHeightCacheKey)
    }
    
    private static var ethAssetBlockMap: AssetBlockMap {
        return assetBlockMap(forKey: ethBlockHeightCacheKey)
    }

    private static func assetBlockMap(forKey key: String) -> AssetBlockMap {
        if let localMap = UserDefaults.standard.object(forKey: key) as? AssetBlockMap {
            return localMap
        }else {
            let newMap = AssetBlockMap()
            UserDefaults.standard.set(newMap, forKey: key)
            return newMap
        }
    }
}
