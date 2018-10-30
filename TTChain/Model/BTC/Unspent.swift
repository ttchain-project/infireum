//
//  Unspent.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
struct Unspent {
    let txid: String
    let btcAmount: Decimal
    let confirmation: Int
    let vout: Int
}
