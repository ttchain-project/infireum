//
//  Constants.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/21.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
typealias C = Constants

enum Environment {
    case sit
    case uat
    case prd
}

typealias ENV = Environment
func env() -> ENV {
    #if SIT
    return .sit
    #elseif UAT
    return .uat
    #elseif PRD
    return .prd
    #else
    fatalError("Found Undefined environment")
    #endif
}

struct Constants {
    struct Crypto {
        struct AES {
            //Both key and iv in AES must be 16 bytes = 128 bits
            static let key = "gibofflinewallet"
            static let iv = "walletofflinegib"
        }
    }
    
    struct Fiat {
        static let digit: Int = 2
    }
    
    struct Coin {
        static let min_digit: Int = 4
    }
    
    struct Wallet {
        static let min_wallet: Int = 6
    }
    
    struct HTTPServerAPI {
        static var urlStr: String {
            switch env() {
            case .prd:
                //sit as prd for now
                return "http://api-trading.git4u.net:63339"
//                return "https://hopeseed-api.bibi2u.com"
            case .sit:
                return "http://api-trading.git4u.net:63339"
            case .uat:
                return "http://api-trading.git4u.net:63339"
            }
        }
        static var rocketChatURL:String {
            switch env() {
            case .prd:
                //sit as prd for now

                return "http://api-trading.git4u.net:3000"
//                return "http://hopeseed-im.bibi2u.com:3000"
            case .sit:
                return "http://192.168.51.21:3000"
            case .uat:
                return "http://api-trading.git4u.net:3000"
            }
        }
    }
    
    
    
    struct BlockchainAPI {
        static var urlStr_3206: String {
            return "http://125.227.132.127:3206"
            //            switch env() {
            //            case .prd:
            //                return "http://127.0.0.1:3200"
            //            case .sit:
            //                return "http://127.0.0.1:3200"
            //            case .uat:
            //                return "http://127.0.0.1:3200"
            //            }
        }
        
        static var urlStr_32000: String {
            return "http://125.227.132.127:32000"
//            switch env() {
//            case .prd:
//                return "http://127.0.0.1:3200"
//            case .sit:
//                return "http://127.0.0.1:3200"
//            case .uat:
//                return "http://127.0.0.1:3200"
//            }
        }
        
        struct LightningTrade {
            //TODO: Need to confirm
            /// Use this address to receive btc lightning transfer to btcrelay.
            static var lt_officialBTCAddress: String {
                return  "1Pi1Spap6vdfAWJPfMkYUCtG4EYM5fPWeR"
            }
        }
        
        struct BlockExplorer {
            static var apiBase: String {
                return "https://blockexplorer.com/api"
            }
            
            static var testNet_apiBase: String {
                return "https://testnet.blockexplorer.com/api"
            }
        }
        
        
        struct ChainSo {
            static var apiBase: String {
                return "https://chain.so/api/v2"
            }
        }
        
        struct Etherscan {
            static var apiBase: String {
                return "https://api.etherscan.io/api"
            }
            
            static var apiKey: String {
                return "W673F5JT2IIGUWSCQYJ3ZMQTYMPHHNMZGA"
            }
            
            static var apiSuccessStatus: Int {
                return 1
            }
            
            static var maxBlock: Int {
                return 99999999
            }
        }
        
        struct Mainnet {
            static var apiBase: String {
                return "https://mainnet.infura.io"
            }
        }
        
        static var maxTracingTxRecordDays: Int {
            return 90
        }
        
        
        static var blockSpeed: Int {
            return 14
        }
    }
    
    enum Hockey {
        enum Identifier {
            static let SIT = "d8b8be3f3acb4bd0a04a60b3b171a56f"
            static let UAT = ""
            static let PRD = "63a4426399584000a095574752efa5a5"
        }
    }
    
    struct IMDateFormat {
        static let dateFormatForIM:String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    enum PrivateMode {
        //When private mode is on, all the asset amt would be changed to the disguisedValueStr.
        static let disguisedValueStr = "****"
    }
    
    enum Application {
        static var version: String {
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            //            let build = dictionary["CFBundleVersion"] as! String
            //            return "1.0.0"
            return version
        }
        
        static var ipaUrlStr: String {
            return "https://rink.hockeyapp.net/apps/bbd5ede5ffdb4704bc1f658ad2670fb6"
        }
    }
    
    enum FAQ {
        static var FAQURL: URL {
            let root = "https://hopeseed.zendesk.com"
            let path = "/hc/\(LangManager.instance.lang.value._db_name)/sections/360002421291"
            var urlcomps = URLComponents(string: root)!
            urlcomps.path = path
            let url = urlcomps.url!
            
            return url
        }
    }
}
