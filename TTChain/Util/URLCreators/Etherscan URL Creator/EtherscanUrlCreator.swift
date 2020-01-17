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


class TTNURLCreator {
    private static let base = "http://3.112.106.186/tables_txresult.html?tx="
    static func url(txid:String)-> URL {
        return URL.init(string: "\(TTNURLCreator.base)\(txid)")!
    }
}

class IFRCURLCreator {
    private static let base = "http://3.112.106.186/tables_txresult.html?tx="
    static func url(txid:String)-> URL {
        return URL.init(string: "\(IFRCURLCreator.base)\(txid)")!
    }
}

