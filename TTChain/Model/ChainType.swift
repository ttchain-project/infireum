//
//  ChainType.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
enum ChainType: Int16 {
    case btc = 0
    case eth = 1
    case cic = 2
    case ttn = 3
    case ifrc = 6

    var undeletableCoinIds: [String] {
        switch self {
        case .btc: return [Coin.btc_identifier]
        case .eth: return [Coin.eth_identifier]
        case .cic: return [Coin.cic_identifier, Coin.guc_identifier]
        case .ttn: return [""]
        case .ifrc: return [""]
        }
    }
    
    var name: String {
        switch self {
        case .btc: return "BTC"
        case .cic: return "CIC"
        case .eth: return "ETH"
        case .ttn: return "TTN"
        case .ifrc: return "IFRC"
        }
    }
    
    /** DefaultCoin is for case that the system is unable to find the coin from
        mainCoinID input, it will return the most basic coin for each chain.
    */
    var defaultCoin: Coin {
        switch self {
        case .btc: return Coin.btc
        case .eth: return Coin.eth
        case .cic: return Coin.cic
        case .ttn: return Coin.ttn
        case .ifrc: return Coin.ifrc
        }
    }
}
