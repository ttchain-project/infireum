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
        static let content = "Crystal Success Limited區塊鏈科技有限公司（以下簡稱“Crystal Success Limited”或“我們”）尊重並保護用戶（以下簡稱“您”或“用戶”）的隱私，您使用TTChain時，Crystal Success Limited將按照本隱私政策（以下簡稱“本政策”）收集、使用您的個人資訊。建議您在使用本產品（以下簡稱“TTChain”）之前仔細閱讀並理解本政策全部內容，針對免責聲明等條款在內的重要訊息將以加粗的形式呈現。 本政策有關關鍵詞定義與Crystal Success Limited《TTChain服務協議》保持一致。本政策可由Crystal Success Limited線上隨時更新，更新後的政策一旦公佈即代替原來的政策，如果您不接受修改後的條款，請立即停止使用TTChain，您繼續使用TTChain將被視為接受修改後的政策。經修改的政策一經在TTChain上公佈，立即自動生效。 您知悉本政策及其他有關規定適用於TTChain及TTChain上Crystal Success Limited所自主擁有的dApp。 一、 我們收集您的哪些資訊請您知悉，我們收集您的以下資訊是出於滿足您在TTChain服務需要的目的，且我們十分重視對您隱私的保護。在我們收集您的資訊時，將嚴格遵守“合法、正當、必要”的原則。且您知悉，若您不提供我們服務所需的相關資訊，您在TTChain的服務體驗可能因此而受到影響。 1. 我們將收集您的行動裝置訊息、操作記錄、交易記錄、錢包地址等個人資訊。 2. 為滿足您的特定服務需求，我們將收集您的姓名、銀行卡號、手機號碼、郵件地址等資訊。 3. 您知悉：您在TTChain上的錢包密碼、私鑰、助記詞、並不儲存或同步至Crystal Success Limited服務器。Crystal Success Limited不提供找回您的錢包密碼、私鑰、助記詞的服務。 4. 除上述內容之外，您知悉在您使用TTChain特定功能時，我們將在收集您的個人資訊前向您作出特別提示，要求向您收集更多的個人資訊。如您選擇不同意，則視為您放棄使用TTChain該特定功能。 5. 當您跳轉到第三方dApp後，第三方dApp會向您收集個人資訊。 TTChain不持有第三方dApp向您收集的個人資訊。 6. 在法律法規允許的範圍內，Crystal Success Limited可能會在以下情形中收集並使用您的個人資訊無需徵得您的授權同意： （1） 與國家安全、國防安全有關的；（2） 與公共安全、公共衛生、重大公共利益有關的；（3） 與犯罪偵查、起訴、審判和判決執行等有關的；（4） 所收集的個人資訊是您自行向社會公眾公開的；（5） 從合法公開披露的資訊中收集您的個人資訊，如合法的新聞報導，政府信息公開等渠道；（6） 用於維護服務的安全和合規所必需的，例如發現、處理產品和服務的故障；（7） 法律法規規定的其他情形。 7. 我們收集資訊的方式如下： （1） 您向我們提供資訊。例如，您在“個人中心”頁面中填寫姓名、手機號碼或銀行卡號，或在回覆問題時提供郵件地址，或在使用我們的特定服務時，您額外向我們提供。 （2） 我們在您使用TTChain的過程中獲取資訊，包括您行動裝置資訊以及您對TTChain的操作記錄等資訊； （3） 我們通過區塊鏈系統，拷貝您全部或部分的交易記錄。但交易記錄以區塊鏈系統的記載為準。 二、 我們如何使用您的資訊 1. 我們通過您行動裝置的唯一序列號，確認您與您的錢包的對應關係。 2. 我們將向您及時發送重要通知，如軟件更新、服務協議及本政策條款的變更。 3. 我們在TTChain的“系統設置”中為您提供“指紋登錄”選項，讓您方便且更安全地管理您的數字代幣。 4. 我們通過收集您公開的錢包地址和提供的行動裝置資訊來處理您向我們提交的回應。 5. 我們收集您的個人資訊進行??內部審計、數據分析和研究等，以期不斷提升我們的服務水平。 6. 依照《TTChain服務協議》及Crystal Success Limited其他有關規定，Crystal Success Limited將利用用戶資訊對用戶的使用行為進行管理及處理。 7. 法律法規規定及與監管機構配合的要求。 三、 您如何控制自己的資訊 您在TTChain中擁有以下對您個人資訊自主控制權： 1. 您可以通過同步錢包的方式，將您的其他錢包導入TTChain中，或者將您在TTChain的錢包導入到其他數字代幣管理錢包中。 TTChain將向您顯示導入錢包的資訊。 2. 您知悉您可以通過“資產”版塊內容修改您的數字代幣種類、進行轉賬及收款等活動。 3. 您知悉在TTChain “我”的版塊您可以自由選擇進行如下操作： （1） 在“聯絡人”中，您可以隨時查看並修改您的“聯絡人” （2） 在“系統設置”中，您可以選擇不開啟“指紋登錄”選項，即您可以選擇不使用蘋果公司提供的Touch ID驗證服務； （3） 在“個人中心”中，您並不需要提供自己的姓名、手機號碼、銀行卡等資訊，但當您使用特定服務時，您需要提供以上資訊； （4） 在“遞交回應”中，您可以隨時向我們提出您對TTChain問題及改進建議，我們將非常樂意與您溝通並積極改進我們的服務。 4. 您知悉當我們出於特定目的向您收集資訊時，我們會提前給予您通知，您有權選擇拒絕。但同時您知悉，當您選擇拒絕提供有關資訊時，即表示您放棄使用TTChain的有關服務。 5. 您知悉，您及我們對於您交易記錄是否公開並沒有控制權，因為基於區塊鏈交易系統的開源屬性，您的交易記錄在整個區塊鏈系統中公開透明。 6. 您知悉當您使用TTChain的功能跳轉至第三方dApp之後，我們的《TTChain服務協議》、《TTChain隱私政策》將不再適用，針對您在第三方dApp上對您個人資訊的控制權問題，我們建議您在使用第三方DApp之前詳細閱讀並了解其隱私規則和有關用戶服務協議等內容。 7. 您有權要求我們更新、更改、刪除您的有關資訊。 8. 您知悉我們可以根據本政策第一條第6款的要求收集您的資訊而無需獲得您的授權同意 四、 我們可能分享或傳輸您的資訊 1. Crystal Success Limited在中華民國(台灣)境內收集和產生的用戶個人資訊將存儲在中華民國(台灣)境內的伺服器上。若Crystal Success Limited確需向境外傳輸您的個人資訊，將在事前獲得您的授權，且按照有關法律法規政策的要求進行跨境數據傳輸，並對您的個人資訊履行保密義務。 2. 未經您事先同意，Crystal Success Limited不會將您的個人資訊向任何第三方共享或轉讓，但以下情況除外： （1） 事先獲得您明確的同意或授權； （2） 所收集的個人資訊是您自行向社會公眾公開的； （3） 所收集的個人資訊係從合法公開披露的資訊中收集，如合法的新聞報導，政府資訊公開等渠道； （4） 與Crystal Success Limited的關聯方共享，我們只會共享必要的用戶資訊，且受本隱私條款中所聲明的目的的約束； （5） 根據適用的法律法規、法律程序的要求、行政機關或司法機關的要求進行提供； （6） 在涉及合併、收購時，如涉及到個人資訊轉讓，Crystal Success Limited將要求個人資訊接收方繼續接受本政策的約束。 五、 我們如何保護您的資訊 1. 如Crystal Success Limited停止運營，Crystal Success Limited將及時停止繼續收集您個人資訊的活動，將停止運營的通知公告在TTChain上，並對所持有的您的個人資訊在合理期限內進行刪除或匿名化處理。 2. 為了保護您的個人資訊，Crystal Success Limited將採取數據安全技術措施，提升內部合規水平，增加內部員工資訊安全培訓，並對相關數據設置安全訪問權限等方式安全保護您的隱私資訊。 3. 我們將在TTChain “消息中心”中向您發送有關資訊安全的消息，並不時在TTChain “幫助中心”版塊更新錢包使用及資訊保護的資料，供您參考。 六、 對未成年人的保護 我們對保護未滿18周歲的未成年人做出如下特別約定： 1. 未成年人應當在父母或監護人指導下使用Crystal Success Limited相關服務。 2. 我們建議未成年人的父母和監護人應當在閱讀本政策、《TTChain服務協議》及我們的其他有關規則的前提下，指導未成年人使用TTChain。 3. TTChain將根據國家相關法律法規的規定保護未成年人的個人資訊的保密性及安全性。 七、 免責聲明 1. 請您注意，您通過TTChain接入第三方dApp後，將適用該第三方dApp發布的隱私政策。該第三方dApp對您個人資訊的收集和使用不為??所控制，也不受本政策的約束。Crystal Success Limited無法保證第三方dApp一定會按照Crystal Success Limited的要求採取個人資訊保護措施。 2. 您應審慎選擇和使用第三方dApp，並妥善保護好您的個人資訊，Crystal Success Limited對其他第三方dApp的隱私保護不負任何責任。 3. Crystal Success Limited將在現有技術水平條件下盡可能採取合理的安全措施來保護您的個人資訊，以避免資訊的洩露、篡改或者毀損。Crystal Success Limited系利用無線方式傳輸數據，因此，Crystal Success Limited無法確保通過無線網絡傳輸數據的隱私性和安全性。 八、 其他 1. 如您是中華民國(台灣)以外的用戶，您需全面了解並遵守您所在司法轄區與使用Crystal Success Limited服務所有相關法律、法規及規則。 2. 您在使用Crystal Success Limited服務過程中，如遇到任何有關個人資訊使用的問題，您可以通過在TTChain提交回應等方式聯繫我們。 3. 您可以在TTChain中查看本政策及Crystal Success Limited其他服務規則。我們鼓勵您在每次訪問TTChain時都查閱Crystal Success Limited的服務協議及隱私政策。 4. 本政策的任何譯文版本僅為方便用戶而提供，無意對本政策的條款進行修改。如果本政策的中文版本與非中文版本之間存在衝突，應以中文版本為準。 5. 本政策自2018年12月18日起適用。 本政策未盡事宜，您需遵守Crystal Success Limited不時更新的公告及相關規則。 Crystal Success Limited區塊鏈科技有限公司"
    }
    
}
