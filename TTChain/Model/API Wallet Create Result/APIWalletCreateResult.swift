//
//  APIWalletCreateResult.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

struct APIWalletCreateResult {
    struct WalletResource {
        let pKey: String
        let address: String
        let mainCoin: Coin
    }
    
    let name: String
    let mnemonic: String
    let walletsResource: [WalletResource]
    let pwd: String
    let pwdHint: String
}
