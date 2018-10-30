//
//  AssetSort.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

struct AssetSortingManager {
    enum Sort: Int {
        case none = 1
        case assetAmt = 2
        case alphabetic = 3
    }
    
    private static let sortingKey = "sortingKey"
    static func getSortOption() -> Sort {
        let raw = UserDefaults.standard.integer(forKey: sortingKey)
        if let sort = Sort.init(rawValue: raw) {
            return sort
        }else {
            setSorting(.alphabetic)
            return getSortOption()
        }
    }
    
    static func setSorting(_ sort: Sort) {
        UserDefaults.standard.set(sort.rawValue, forKey: sortingKey)
        UserDefaults.standard.synchronize()
    }
}
