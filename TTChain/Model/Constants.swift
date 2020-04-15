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
                return "http://sit-api.ttchainwallet.com"
//                return "https://hopeseed-api.bibi2u.com"
            case .sit:
                return "http://sit-api.ttchainwallet.com"
            case .uat:
                return "http://sit-api.ttchainwallet.com"
            }
        }
        static var rocketChatURL:String {
            switch env() {
            case .prd:
                //sit as prd for now

                return "http://3.113.34.69:3000"
//                return "http://hopeseed-im.bibi2u.com:3000"
            case .sit:
                return "http://3.113.34.69:3000/"
            case .uat:
                return "http://3.113.34.69:3000/"
            }
        }
    }
    
    
    
    struct BlockchainAPI {
        static var urlStr_3206: String {
            return "http://sit-api.ttchainwallet.com"
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
            static let PRD = "3764ef676a9549c3ae4310baae0b5021"
        }
    }
    
    struct IMDateFormat {
        static let dateFormatForIM:String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
    }
    
    struct BTCFee {
        static let regular = Decimal.init(15000)
        static let priority = Decimal.init(30000)
    }
    
    struct TTNTx {
        static let withdrawInputPrefix = "b2bbbbbb0000000000000001"
        static let officialTTNAddress = "e658e4a47103b4578fd2ba6aa52af1b9fc67c129"
        static let officialBTCAddress = "16RmMmRGYoCugQAdfBRYoDPCU8CEpeUfqc"
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
            return "https://rink.hockeyapp.net/apps/3764ef676a9549c3ae4310baae0b5021"
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
     struct PrivacyPolicyString {
        static let content = "Article 1 Purpose and Basis.\nIn order to provide the services of the Platform to Users, Infireum needs to collect some of your information when you register with the Platform, log in to the Platform and/or use the services offered by the Platform. This Privacy Policy, in combination with Infireum Wallet Global’s User Service Agreement, User Service Agreement for the InfiniteChain Global APP and any other applicable policies, set out the rules as to the use and protection of the collected information in order to prevent misuse.\n\nArticle 2 Designation. \nFor the convenience of wording in this agreement (the “Agreement”), the Platform is referred to as “we”, “us” or “our”. Users of and other visitors to the Platform are referred to as “you”, “your” or “User”. We and you are collectively referred to as “both parties” and as “a/one party” individually.\n\nArticle 3 Definition and Interpretation.\nThe following terms or expressions shall have the meanings ascribed to them below, unless any other term or condition hereunder provides otherwise:\n\n(1)Personal Information:\nall information that is recorded electronically or otherwise and can be used, whether independently or in combination with any other information, to identify any particular natural person or reflect the pattern of behaviour, including, but not limited to, sensitive personal information;\n(2)Sensitive Personal Information: \nFor the purpose of this Privacy Policy, Personal Data means any information, whether recorded in a material form or not, from which the identity of an individual is apparent or can be reasonably and directly ascertained by the entity holding the information, or when put together with other information would directly and certainly identify an individual. "
    }
    
}
