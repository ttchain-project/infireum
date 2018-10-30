//
//  EtherscanUrlCreator.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/12.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
class EtherscanURLCreator {
    private static let base = "https://etherscan.io/tx/"
    static func url(ofTxID id: String) -> URL {
        return URL.init(string: base + id)!
    }
}
