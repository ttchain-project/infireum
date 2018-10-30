//
//  MnemonicHelper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

class MnemonicHelper {
    static func split(source: String) -> [String] {
        return source.split(separator: " ").map { String($0) }
    }
    
    static func concat(sources: [String]) -> String {
        return sources.reduce("", { (mnemonic, str) -> String in
            if mnemonic.isEmpty {
                return str
            }else {
                return mnemonic + " " + str                
            }
        })
    }
    
    static func random(source: String) -> String {
        var splits = split(source: source)
        var randoms: [String] = []
        while !splits.isEmpty {
            let count = splits.count
            let idx = Int(arc4random()) % count
            randoms.append(splits.remove(at: idx))
        }
        
        return concat(sources: randoms)
    }
}
