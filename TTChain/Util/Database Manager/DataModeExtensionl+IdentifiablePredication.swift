//
//  DatabaseIdentityDistinct.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

//TODO: Implement Default constructors
// KLIdentifiableManagedObject
extension CoinSelection: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [#keyPath(walletEPKey), #keyPath(coinIdentifier)]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<CoinSelection>] {
        return []
    }
}

extension Coin: KLIdentifiableManagedObject {
    static var defaultImgData: Data {
        let img = #imageLiteral(resourceName: "iconListNoimage")
        return img.compressedData(quality: 1)!
    }
    
    static var idenifierKeys: [String] {
        return [ #keyPath(identifier) ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<Coin>] {
        let BTC = ManagedObejctConstructor<Coin>(
            idUnits: [
            .str(keyPath: #keyPath(identifier), value: Coin.btc_identifier)
            ],
            setup: { coin in
                coin.contract = nil
                coin.fullname = "Bitcoin"
                if coin.icon == nil {
                    coin.icon = UIImagePNGRepresentation(#imageLiteral(resourceName: "iconListWalletBtc")) as NSData?
                }
                
                coin.identifier = Coin.btc_identifier
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.chainName = "BTC"
                coin.inAppName = "BTC"
                coin.chainType = 0
                coin.digit = 8
                coin.walletMainCoinID = Coin.btc_identifier
            })
        
        let ETH = ManagedObejctConstructor<Coin>(
            idUnits: [
                .str(keyPath: #keyPath(identifier), value: Coin.eth_identifier)
            ],
            setup: { coin in
                coin.contract = Coin.eth_identifier
                coin.fullname = "Ethereum"
                if coin.icon == nil {
                    //Prevent replace existing data
                    coin.icon = defaultImgData as NSData
                }
                coin.identifier = Coin.eth_identifier
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.chainName = "ETH"
                coin.inAppName = "ETH"
                coin.chainType = 1
                coin.digit = 18
                coin.walletMainCoinID = Coin.eth_identifier
        })
        
//        let SNT = ManagedObejctConstructor<Coin>(
//            idUnits: [
//                .str(keyPath: #keyPath(identifier), value: "0x744d70fdbe2ba4cf95131626614a1763df805b9e")
//            ],
//            setup: { coin in
//                coin.contract = "0x744d70fdbe2ba4cf95131626614a1763df805b9e"
//                coin.fullname = "StatusNetwork"
//                coin.icon = defaultImgData as NSData
//                coin.identifier = "0x744d70fdbe2ba4cf95131626614a1763df805b9e"
//                coin.isActive = true
//                coin.isDefault = true
//                coin.isDefaultSelected = true
//                coin.isActive = true
//                coin.name = "SNT"
//                coin.chainType = 1
//        })
        
//        let EOS = ManagedObejctConstructor<Coin>(
//            idUnits: [
//                .str(keyPath: #keyPath(identifier), value: "0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0")
//            ],
//            setup: { coin in
//                coin.contract = "0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0"
//                coin.fullname = "EOS"
//                coin.icon = defaultImgData as NSData
//                coin.identifier = "0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0"
//                coin.isActive = true
//                coin.isDefault = true
//                coin.isDefaultSelected = true
//                coin.isActive = true
//                coin.name = "EOS"
//                coin.chainType = 1
//        })
        
        let CIC = ManagedObejctConstructor<Coin>(
            idUnits: [
                .str(keyPath: #keyPath(identifier), value: Coin.cic_identifier)
            ],
            setup: { coin in
                coin.contract = Coin.cic_identifier
                coin.fullname = "CICoin"
                if coin.icon == nil{
                    coin.icon = UIImagePNGRepresentation(#imageLiteral(resourceName: "iconFundsCic")) as NSData?
                }

                coin.identifier = Coin.cic_identifier
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.chainName = "cic"
                coin.inAppName = "CIC"
                coin.chainType = 2
                coin.digit = 18
                coin.walletMainCoinID = Coin.cic_identifier
        })
        
        let BTC_Relay = ManagedObejctConstructor<Coin>(
            idUnits: [
                .str(keyPath: #keyPath(identifier), value: Coin.btcRelay_identifier)
            ],
            setup: { coin in
                coin.contract = Coin.btcRelay_identifier
                coin.fullname = "BTC Relay"
                if coin.icon == nil{
                    coin.icon = defaultImgData as NSData
                }
                coin.identifier = Coin.btcRelay_identifier
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.inAppName = "BTR"
                coin.chainName = "btr"
                coin.chainType = 2
                coin.digit = 8
                coin.walletMainCoinID = Coin.cic_identifier
        })
        
        let guc = ManagedObejctConstructor<Coin>(
            idUnits: [
                .str(keyPath: #keyPath(identifier), value: Coin.guc_identifier)
            ],
            setup: { coin in
                coin.contract = nil
                coin.fullname = "Global Universal Coin"
                if coin.icon == nil{
                    coin.icon = UIImagePNGRepresentation(#imageLiteral(resourceName: "bgContent4Guclogo")) as NSData?
                }
                coin.identifier = Coin.guc_identifier
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.isActive = true
                coin.inAppName = "GUC"
                coin.chainName = "GUC"
                coin.chainType = 2
                coin.digit = 18
                coin.walletMainCoinID = Coin.guc_identifier
        })
        
        /*let test = ManagedObejctConstructor<Coin>(
            idUnits: [
                .str(keyPath: #keyPath(identifier), value: "Test_Identifier")
            ],
            setup: { coin in
                coin.contract = nil
                coin.fullname = "Test Coin"
                if coin.icon == nil{
                    coin.icon = UIImagePNGRepresentation(#imageLiteral(resourceName: "bgContent4Guclogo")) as NSData?
                }
                coin.identifier = "Test_Identifier"
                coin.isActive = true
                coin.isDefault = true
                coin.isDefaultSelected = true
                coin.isActive = true
                coin.inAppName = "Test"
                coin.chainName = "Test"
                coin.chainType = 2
                coin.digit = 18
                coin.walletMainCoinID = "Test_Identifier"
        })*/
        
//        return [BTC, ETH, BTC_Relay]
        return [BTC, ETH, CIC, BTC_Relay, guc]
//        return [BTC, ETH, CIC, BTC_Relay, guc, test]
    }
}

extension Asset: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(walletEPKey), #keyPath(coinID)
        ]
    }
    static var defaultConstrutors: [ManagedObejctConstructor<Asset>] { return [] }
}

extension Language: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [#keyPath(id)]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<Language>] {
        let zh_cn = ManagedObejctConstructor<Language>(
            idUnits: [.num(keyPath: #keyPath(id), value: 0)],
            setup: { (lang) in
                lang.id = Lang.zh_cn.rawValue
                lang.name = Lang.zh_cn._db_name
        })
        
        let zh_tw = ManagedObejctConstructor<Language>(
            idUnits: [.num(keyPath: #keyPath(id), value: 0)],
            setup: { (lang) in
                lang.id = Lang.zh_tw.rawValue
                lang.name = Lang.zh_tw._db_name
        })

        let en_us = ManagedObejctConstructor<Language>(
            idUnits: [.num(keyPath: #keyPath(id), value: 0)],
            setup: { (lang) in
                lang.id = Lang.en_us.rawValue
                lang.name = Lang.en_us._db_name
        })
        
        return [zh_cn,zh_tw,en_us]
    }
}

extension FiatToFiatRate: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(fromFiatID), #keyPath(toFiatID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<FiatToFiatRate>] { return [] }
}

extension Identity: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(id)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<Identity>] { return [] }
}

extension CoinToFiatRate: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(fromCoinID), #keyPath(toFiatID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<CoinToFiatRate>] { return [] }
}

extension CoinRate: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(fromCoinID), #keyPath(toCoinID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<CoinRate>] { return [] }
}

extension AddressBookUnit: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(identityID), #keyPath(address), #keyPath(mainCoinID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<AddressBookUnit>] { return [] }
}

extension LightningTransRecord: KLIdentifiableManagedObject {
    
    static var idenifierKeys: [String] {
        return [
            #keyPath(txID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<LightningTransRecord>] { return []
    }
}

extension TransRecord: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [
            #keyPath(txID)
        ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<TransRecord>] { return [] }
}

extension Wallet: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [ #keyPath(encryptedPKey), #keyPath(chainType), #keyPath(walletMainCoinID) ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<Wallet>] { return [] }
}

enum SystemDefaultFiat: Int16 {
    case CNY = 0
    case TWD = 1
    case USD = 2
    
    var name: String {
        switch self {
        case .CNY: return "CNY"
        case .TWD: return "TWD"
        case .USD: return "USD"
        }
    }
    
    var symbol: String {
        switch self {
        case .CNY: return "¥"
        case .TWD, .USD: return "$"
        }
    }
}

extension Fiat: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [ #keyPath(id) ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<Fiat>] {
        let CNY = ManagedObejctConstructor<Fiat>(
            idUnits: [
                .num(keyPath: #keyPath(id), value: SystemDefaultFiat.CNY.rawValue)
            ],
            setup: {
                fiat in
                fiat.id = SystemDefaultFiat.CNY.rawValue
                fiat.name = SystemDefaultFiat.CNY.name
                fiat.symbol = SystemDefaultFiat.CNY.symbol
        })
        
        let TWD = ManagedObejctConstructor<Fiat>(
            idUnits: [
                .num(keyPath: #keyPath(id), value: SystemDefaultFiat.TWD.rawValue)
            ],
            setup: {
                fiat in
                fiat.id = SystemDefaultFiat.TWD.rawValue
                fiat.name = SystemDefaultFiat.TWD.name
                fiat.symbol = SystemDefaultFiat.TWD.symbol
        })
        
        let USD = ManagedObejctConstructor<Fiat>(
            idUnits: [
                .num(keyPath: #keyPath(id), value: SystemDefaultFiat.USD.rawValue)
            ],
            setup: {
                fiat in
                fiat.id = SystemDefaultFiat.USD.rawValue
                fiat.name = SystemDefaultFiat.USD.name
                fiat.symbol = SystemDefaultFiat.USD.symbol
        })
        
        return [ CNY, TWD, USD ]
    }
}

extension SubAddress: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [ #keyPath(mainAddress), #keyPath(subAddress) ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<SubAddress>] { return [] }
}

extension ServerSyncRecord: KLIdentifiableManagedObject {
    static var idenifierKeys: [String] {
        return [ #keyPath(syncDate), #keyPath(syncIdentityName) ]
    }
    
    static var defaultConstrutors: [ManagedObejctConstructor<ServerSyncRecord>] { return [] }
}
