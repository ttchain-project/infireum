//
//  Models.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/1/23.
//  Copyright © 2018年 GIT. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import RxSwift
import SwiftMoment
import RxCocoa


enum BlockchainAPI: KLMoyaAPISet {
    var api: KLMoyaAPIData {
        switch self {
        case .createAccount(let api): return api
        case .keyToAddress(let api): return api
            
        case .getAssetAmt(let api): return api
        
        case .getTTNAssetAmt(let api):return api
        case .getTTNNOnce(let api):return api
        case .signBTCToTTNTxAPI(let api):return api
        case .signTTNTx(let api): return api
        case .broadcastTTNTx(let api): return api
        case .getTTNTxRecords(let api): return api

        case .getBTCurrentBlock(let api): return api
        case .getBTCUnspent(let api): return api
        case .getBTCTxRecords(let api): return api
            
        case .getUSDTTransaction(let api): return api
        case .getETHCurrentBlock(let api): return api
        case .getETHNonce(let api): return api
        case .getETHTxRecords(let api): return api
        case .getETHTokenTxRecords(let api): return api
            
        case .lt_signBTCRelayTx(let api): return api
        case .lt_broadcastBTCRelayTx(let api): return api
            
        case .getCICNonce(let api): return api
        case .signCICTx(let api): return api
        case .broadcastCICTx(let api): return api
        case .getCICTxRecords(let api): return api
           
//        case .getMarketTestAPI(let api): return api
//        case .getQuotesTestAPI(let api): return api
        
        case .getVersion(let api): return api
        }
        
    }
    
    case createAccount(CreateAccountAPI)
    case keyToAddress(KeyToAddressAPI)
    
    //MARK: - General
    case getAssetAmt(GetAssetAmtAPI)
    
    //MARK: - TTN
    case getTTNAssetAmt(GetTTNAssetAmountAPI)
    case getTTNNOnce(GetTTNNonceAPI)
    case signBTCToTTNTxAPI(SignBTCToTTNTxAPI)
    case signTTNTx(SignIfrcTxAPI)
    case broadcastTTNTx(BroadcastTTNTxAPI)
    case getTTNTxRecords(GetTTNTxRecordsAPI)

    //MARK: - BTC
    case getBTCurrentBlock(GetBTCCurrentBlockAPI)
    case getBTCUnspent(GetBTCUnspentAPI)
    case getBTCTxRecords(GetBTCTxRecordsAPI)
    
    case getUSDTTransaction(GetUSDTTransactionAPI)
    //MARK: - ETH
    case getETHCurrentBlock(GetETHCurrentBlockAPI)
    case getETHNonce(GetETHNonceAPI)
    case getETHTxRecords(GetETHTxRecordsAPI)
    case getETHTokenTxRecords(GetETHTokenTxRecordsAPI)
    //
    //MARK: - Lightning Trade(LT) BTC -> BTC Relay
    case lt_signBTCRelayTx(LTSignBTCRelayTxAPI)
    case lt_broadcastBTCRelayTx(LTBroadcastBTCRelayTxAPI)
    
    //MARK: - CIC
    case getCICNonce(GetCICNonceAPI)
    case signCICTx(SignCICTxAPI)
    case broadcastCICTx(BroadcastCICTxAPI)
    case getCICTxRecords(GetCICTxRecordsAPI)
//    case getMarketTestAPI(MarketTestAPI)
//    case getQuotesTestAPI(QuotesTestAPI)
    
    case getVersion(GetVersionAPI)

}

//MARK: - GET AssetAmt
struct GetAssetAmtAPI: KLMoyaAPIData {
    let asset: Asset
    
    var base: APIBaseEndPointType {
        let urlString: String
        switch (asset.coin?.owChainType,asset.coin?.identifier) {
        case (.btc?,Coin.btc_identifier):
            urlString = "https://blockchain.info"
        case (.btc?,Coin.usdt_identifier):
            urlString = "https://api.omniexplorer.info"
        case (.ifrc?,_):
            urlString = "http://3.1.196.86:9997"
        default:
//            urlString = C.BlockchainAPI.urlStr_32000
            urlString = "http://54.64.162.167:3206"
        }
        
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        
        guard let wallet = asset.wallet,let address = wallet.address else {
            return ""
        }
        switch (asset.coin!.owChainType,asset.coinID) {
        case (.btc,Coin.btc_identifier):
            return "/balance"
        case (.btc,Coin.usdt_identifier):
            return "/v1/address/addr/"
        case(.ifrc,_):
            return "/getAccount"
        default:
            return "/topChain/getBalance_app/\(address)"
        }
    }
    
    var method: Moya.Method { return asset.coin?.identifier == Coin.usdt_identifier ? .post : .get }
    
    var task: Task {
        guard let coin = asset.coin else  { return Moya.Task.requestPlain }
        switch coin.owChainType {
        case .btc:
            
            guard let wallet = asset.wallet, let address = wallet.address else {
                return Moya.Task.requestPlain
            }
            
            if asset.coinID == Coin.usdt_identifier {
                let multiPartData : [MultipartFormData] =
                    [MultipartFormData.init(provider: .data(address.data(using: .utf8)!), name: "addr"),
                     ]
                return .uploadMultipart(multiPartData)
            }
            
            return Moya.Task.requestParameters(parameters: ["active" : address], encoding: URLEncoding.default)

        case .eth:
            var params = [ "token" : "ETH" ]
            if let contract = asset.coin?.contract, contract.count > 0 {
                params["contractAddress"] = contract
            }
            
            return Moya.Task.requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
            
        case .ifrc:
            return Moya.Task.requestParameters(parameters: ["address":asset.wallet?.address ?? ""], encoding: URLEncoding.default)
        default:
             return Moya.Task.requestPlain
        }
    }
    
    var stub: Data? { return nil }
}

struct GetAssetAmtAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetAssetAmtAPI
    let balanceInCoin: Decimal
    init(json: JSON, sourceAPI: API) throws {
        guard let coin = sourceAPI.asset.coin else {
            self.balanceInCoin = 0
            return
        }
        switch coin.owChainType {
        case .btc:
            if sourceAPI.asset.coinID == Coin.usdt_identifier {
                guard let balanceArray = json["balance"].array else {
                    throw GTServerAPIError.noData
                }
                    if let balance = (balanceArray.filter {
                        $0["symbol"].string == "SP31"
                }.compactMap {
                    return $0["value"]
                        }.first?.string) {
                        self.balanceInCoin = Decimal.init(string: balance)?.satoshiToBTC ?? 0
                    }else {
                        self.balanceInCoin = 0
                }
            }else {
                guard let address = sourceAPI.asset.wallet?.address, let balanceDict = json[address].dictionary,let totalBalance = balanceDict["final_balance"]?.numberValue else {
                    throw GTServerAPIError.noData
                }
                
                self.balanceInCoin = totalBalance.decimalValue.satoshiToBTC
            }
           
        case .eth:
            guard let smallestUnitBalanceStr = json["balance"].string,
                let smallestUnitBalance = Decimal.init(string: smallestUnitBalanceStr) else {
                    throw GTServerAPIError.noData
            }
            
            let rateToCoinUnit: Decimal = 1 / pow(
                Decimal.init(10),
                Int(sourceAPI.asset.coin!.requiredDigit)
            )
            
            let coinUnitBalance = smallestUnitBalance * rateToCoinUnit
            
            self.balanceInCoin = coinUnitBalance
        case .cic:
            let balance = json["balance"]
            let identifier = sourceAPI.asset.coin!.blockchainAPI_identifier.lowercased()
            guard let cicSmallestUnit = balance[identifier].number?.decimalValue else {
                self.balanceInCoin = 0
                return
            }
            
            let rateToCoinUnit: Decimal = 1 / pow(
                Decimal.init(10),
                Int(sourceAPI.asset.coin!.digit)
            )
            
            self.balanceInCoin = cicSmallestUnit * rateToCoinUnit
        case .ttn:
            
            let rateToCoinUnit: Decimal = 1 / pow(
                Decimal.init(10),
                Int(sourceAPI.asset.coin!.requiredDigit)
            )
            if sourceAPI.asset.coin?.identifier == Coin.ttn_identifier,let balance = json["Balance"].string {
                self.balanceInCoin = (Decimal.init(string: balance) ?? 0) * rateToCoinUnit
            } else {
                if let tokenDict = json["Token"].dictionary {
                    let usdtBal = Decimal.init(string:tokenDict["usdtn"]?.string ?? "") ?? 0
                    let ethnBal = Decimal.init(string:tokenDict["ethn"]?.string ?? "") ?? 0
                    let btcnBal = Decimal.init(string:tokenDict["btcn"]?.string ?? "") ?? 0
                    let elxrBal = Decimal.init(string:tokenDict["exr"]?.string ?? "") ?? 0
                    let mccBal = Decimal.init(string:tokenDict["mcc"]?.string ?? "") ?? 0
                    switch sourceAPI.asset.coinID {
                    case Coin.usdtn_identifier:
                        self.balanceInCoin = usdtBal * rateToCoinUnit
                    case Coin.btcn_identifier:
                        self.balanceInCoin = btcnBal * rateToCoinUnit
                    case Coin.ethn_identifier:
                        self.balanceInCoin = ethnBal * rateToCoinUnit
                    case Coin.exr_identifier:
                        self.balanceInCoin = elxrBal * rateToCoinUnit
                    case Coin.mcc_identifier:
                        self.balanceInCoin = mccBal * rateToCoinUnit
                    default:
                        self.balanceInCoin = 0
                    }
                }else {
                    self.balanceInCoin = 0
                }

            }
        case .ifrc:
            
            let rateToCoinUnit: Decimal = 1 / pow(
                Decimal.init(10),
                Int(sourceAPI.asset.coin!.requiredDigit)
            )
            if sourceAPI.asset.coin?.identifier == Coin.ifrc_identifier,let balance = json["Balance"].string {
                self.balanceInCoin = (Decimal.init(string: balance) ?? 0) * rateToCoinUnit
            } else {
                self.balanceInCoin = 0
            }

        }
    }
}



//MARK: - GET https://blockexplorer.com/api/status?q=getBlockCount
struct GetBTCCurrentBlockAPI: KLMoyaAPIData {
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.BlockchainAPI.BlockExplorer.apiBase)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/status" }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "q" : "getBlockCount" ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetBTCCurrentBlockAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetBTCCurrentBlockAPI
    let blockHeight: Int
    init(json: JSON, sourceAPI: API) throws {
        guard let height = json["blockcount"].int else {
            throw GTServerAPIError.noData
        }
        
        self.blockHeight = height
    }
}

//MARK: - GET https://blockexplorer.com/api/addr/{address}/utxo
struct GetBTCUnspentAPI: KLMoyaAPIData {
    
    let btcAddress: String
    /// This is for unspent calculations
    let targetAmt: Decimal
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.HTTPServerAPI.urlStr)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "\(LangManager.instance.lang.value._db_name)/BtcTransaction/\(btcAddress)" }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
    
}

//Error Response: Invalid address: Checksum mismatch. Code:1
struct GetBTCUnspentAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetBTCUnspentAPI
    enum Result {
        case insufficient
        case unspents([Unspent])
    }
    
    let result: Result
    init(json: JSON, sourceAPI: API) throws {
        guard let unspentJSONs = json.array else {
            if let errorDesc = json.string {
                throw GTServerAPIError.incorrectResult("Get Unspent Failed", errorDesc)
            }else {
                throw GTServerAPIError.noData
            }
        }
        
        let target = sourceAPI.targetAmt
        let fromAddress = sourceAPI.btcAddress
        
        let maxToMinUnspents: [Unspent] = unspentJSONs.compactMap { (uJSON) -> Unspent? in
            guard let addr = uJSON["address"].string, addr == fromAddress,
                let txid = uJSON["txid"].string,
                let amount = uJSON["amount"].number?.decimalValue,
                let confirmations = uJSON["confirmations"].int,
                let vout = uJSON["vout"].int,
                let scriptPubKey = uJSON["scriptPubKey"].string,
                let satoshis = uJSON["satoshis"].int
                else {
                    return nil
            }
            
            
            let height = uJSON["height"].int ?? 0
            let object = Unspent.init(address: addr, amount: amount, confirmations: confirmations, height: height, satoshis: satoshis, scriptPubKey: scriptPubKey, txid: txid, vout: vout)
            return object.address != fromAddress ? nil : object
            }
            .sorted { $0.amount > $1.amount }
        
        var usedUnspents: [Unspent] = []
        var accumulatedUnspentAmount: Decimal = 0
        
        var i = 0
        while i < maxToMinUnspents.count && accumulatedUnspentAmount < target {
            let unspent = maxToMinUnspents[i]
            usedUnspents.append(unspent)
            
            accumulatedUnspentAmount += unspent.amount
            i += 1
        }
        
        //TEST
        //        usedUnspents.append(Unspent.init(txid: "c6b327db5c1f4b75594fc47ae9bf780fb7c74e645bd384aa3532ea9246f7e933", btcAmount: 5.34675, confirmation: 331, vout: 0))
        //        accumulatedUnspentAmount += 5.34675
        if accumulatedUnspentAmount >= target {
            result = .unspents(usedUnspents)
        }else {
            result = .insufficient
        }
    }
}

//MARK: - POST /{lang}/SignBTCRelay
struct SignBTCTxAPI: KLMoyaAPIData {
    
    let btcWalletPrivateKey: String
    let fromBTCAddress: String
    let toBTCAddress: String
    let isUSDTTx:Bool
    let transferBTC: Decimal
    let feeBTC: Decimal
    let compressed:Bool
    let unspents: [Unspent]
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "\(LangManager.instance.lang.value._db_name)/SignBTCRelay"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        let totalUnspentBTC = unspents.map { $0.amount }.reduce(0, +)
        let changeBTC = totalUnspentBTC.decimalValue - ((isUSDTTx ? 0 : transferBTC) + feeBTC)
        guard changeBTC >= 0 else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        guard let encryptedPKey = try? APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: btcWalletPrivateKey) else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        let transferSatoshi = transferBTC.btcToSatoshi
        let changeSatoshi = changeBTC.btcToSatoshi
        
        let unspentParams = unspents.map {
            unspent -> [String : Any] in
            return [
                "txid" : unspent.txid,
                "value" : unspent.vout
            ]
        }
        
        return Moya.Task.requestParameters(
            parameters: [
                "token" : isUSDTTx ? "usdt" : "btc",
                "encry" : true,
                "privatekey" : encryptedPKey,
                "tx": [
                    [
                        "address" : toBTCAddress,
                        "value" : transferSatoshi
                    ],
                    [
                        "address" : fromBTCAddress,
                        "value" : changeSatoshi
                    ]
                ],
                "unspend" : unspentParams,
                "compressed" :  compressed
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct SignBTCTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = SignBTCTxAPI
    let signText: String
    init(json: JSON, sourceAPI: API) throws {
        guard let signText = json["signText"].string else {
            if let errorCode = json["error"].string,
                let message = json["message"].string {
                throw GTServerAPIError.incorrectResult(errorCode, message)
            }
            
            throw GTServerAPIError.noData
        }
        
        self.signText = signText
    }
}

//MARK: - POST /{lang}/BlockExplorer

struct BroadcastBTCTxAPI: KLMoyaAPIData {
    
    let signText: String
    let comments: String
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.HTTPServerAPI.urlStr)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return true }
    
    var path: String { return "\(LangManager.instance.lang.value._db_name)/BlockExplorer" }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "rawtx" : signText,
                          "comments": comments],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

//Error Response: Invalid address: Checksum mismatch. Code:1
struct BroadcastBTCTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = BroadcastBTCTxAPI
    
    let txid: String
    init(json: JSON, sourceAPI: API) throws {
        guard let txid = json.string else {
            throw GTServerAPIError.noData
        }
        
        self.txid = txid
    }
}

//MARK: - GET https://blockexplorer.com/api/addrs/[:addrs]/txs[?from=&to=]
struct GetBTCTxRecordsAPI: KLMoyaAPIData {
    
    let btcAddress: String
    let from: Int
    let to: Int
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: "https://blockchain.info")!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/rawaddr/\(btcAddress)" }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "limit" : (to - from),
                          "offset" : from ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetBTCTxRecordsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetBTCTxRecordsAPI
//    let total: Int
    let from: Int
    let to: Int
    let txs: [BTCTx]
    init(json: JSON, sourceAPI: API) throws {
        //https://blockexplorer.com/api/addrs/3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r/txs?from=0&to=1
        if let errorString = json.string {
            throw GTServerAPIError.incorrectResult("Cannot Get BTC Tx Records", errorString)
        }else {
            guard
                let items = json["txs"].array else {
                    throw GTServerAPIError.noData
            }
            
            let txs = items.compactMap { (item) -> BTCTx? in
                guard let txid = item["hash"].string,
                    let blockHeight = item["block_height"].int,
                    let time = item["time"].double,
                    let vin = item["inputs"].array,
                    let vout = item["out"].array else {
                        return nil
                }
                
                let inUnitParse: (JSON) -> BTCTx.TxUnit? = {
                    j in
                    guard let dict = j["prev_out"].dictionary,
                        let _addr = dict["addr"]?.string,
                        let _btcAmt = dict["value"]?.number?.decimalValue else {
                            return nil
                    }
                    
                    return BTCTx.TxUnit(addr: _addr, btc: _btcAmt.satoshiToBTC)
                }
                
                let outUnitParse: (JSON) -> BTCTx.TxUnit? = {
                    j in
                    guard
                        let _addr = j["addr"].string,
                        let _btcAmt = j["value"].number?.decimalValue else {
                            return nil
                    }
                    
                    return BTCTx.TxUnit(addr: _addr, btc: _btcAmt.satoshiToBTC)
                }
                
                
                let ins = vin.compactMap(inUnitParse)
                let outs = vout.compactMap(outUnitParse)
                
                guard !ins.isEmpty && !outs.isEmpty else { return nil }
                
                let valueIn = ins.map { $0.btc }.reduce(0,+)
                
                let valueOut = outs.map { $0.btc }.reduce(0,+)
                let fees = (valueIn - valueOut)
                
                return BTCTx(txid: txid,
                             blockHeight: blockHeight,
                             confirmations: 0,
                             vins: ins,
                             vouts: outs,
                             totalFeeBTC: fees,
                             totalInBTC: valueIn,
                             totalOutBTC: valueOut,
                             timestamp: time)
            }
            
//            self.total = totalItems
            self.from = sourceAPI.from
            self.to = sourceAPI.to
            self.txs = txs
        }
    }
}


//MARK: - POST https://api.omniexplorer.info/v1/transaction/address

struct GetUSDTTransactionAPI : KLMoyaAPIData {
    var path: String {return "/v1/transaction/address"}
    var page: Int
    var address: String
    var method: Moya.Method {return .post}
    
    var task: Task {
        let multiPartData : [MultipartFormData] =
            [MultipartFormData.init(provider: .data(address.data(using: .utf8)!), name: "addr"),
             MultipartFormData.init(provider: .data(page.string.data(using: .utf8)!), name: "page"),
        ]
        return .uploadMultipart(multiPartData)
    }
    
    var stub: Data? {return nil}

    var authNeeded: Bool {return false}
    
    var langDepended: Bool {return false}
    
    var base : APIBaseEndPointType {
        let url  = URL.init(string: "https://api.omniexplorer.info")!
        return .custom(url:url)
    }
    var headers: [String : String]? {
        return ["Content-Type" : "application/x-www-form-urlencoded"]
    }
}

struct GetUSDTTransactionAPIModel:KLJSONMappableMoyaResponse {
    typealias API = GetUSDTTransactionAPI
    
    let currentPage: Int
    let pages: Int
    let transactions : [USDTTx]
    
    init(json: JSON, sourceAPI: API) throws {
       
        guard let currentPage = json["current_page"].number?.intValue,
        let pages = json["pages"].number?.intValue,
            let tx = json["transactions"].array else {
                throw GTServerAPIError.noData
        }
        
        let transactions = tx.compactMap { (json) -> USDTTx? in
            guard
                let txid = json["txid"].string,
                let blockHeight = json["block"].number?.intValue,
                let confirmations = json["confirmations"].number?.intValue,
                let amountDecimal = Double.init(json["amount"].stringValue),
                let feeDecimal = Double.init(json["fee"].stringValue),
                let timeStamp = json["blocktime"].double,
                let fromAddress = json["sendingaddress"].string,
                let toAddress = json ["referenceaddress"].string,
                let valid = json["valid"].bool
                else {
                    return nil
            }
            
            return USDTTx.init(txid: txid, blockHeight: blockHeight, confirmations: confirmations, amount: Decimal.init(amountDecimal), fee: Decimal.init(feeDecimal), timestamp: timeStamp, fromAddress: fromAddress, toAddress: toAddress, valid: valid)
        }
        
        self.transactions = transactions
        self.currentPage = currentPage
        self.pages = pages
    }
}

//MARK: - POST /CustomComments -
struct GetCustomCommentsAPI: KLMoyaAPIData  {
    
    let txIDs : [String?]
    
    var path: String {return "/CustomComments"}
    
    var method: Moya.Method { return .post }
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.HTTPServerAPI.urlStr)!
        return .custom(url: url)
    }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "txIDs" : txIDs],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? {return nil}
    
    var authNeeded: Bool {return false}
    
    var langDepended: Bool {return false}
    
}

struct GetCustomCommentsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetCustomCommentsAPI
    var comments:[CommentsModel] = []
    
    init(json: JSON, sourceAPI: API) throws {
        
        guard let comments = json.array else {
            throw GTServerAPIError.noData
        }
        let commentModelList = comments.compactMap { dict -> CommentsModel? in
            guard let txID = dict["txID"].string,
                let comment = dict["comments"].string else {
                    return nil
            }
            let toIdentifier = dict["toIdentifier"].string
            let toAddress = dict["toAddress"].string
            let commentModel = CommentsModel(txID: txID, comment: comment, toIdentifier: toIdentifier,toAddress:toAddress)
            return commentModel
        }
        self.comments = commentModelList
    }
}

//MARK: - POST /CustomComments Post Comments for CIC and GUC
struct PostCustomCommentsAPI: KLMoyaAPIData  {
    
    struct Parameter:Paramenter {
        let comments : String?
        let txID : String
        let toIdentifier:String
        let toAddress:String
    }
    let parameter:Parameter
    
    var path: String {return "/CustomComment"}
    
    var method: Moya.Method { return .post }
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.HTTPServerAPI.urlStr)!
        return .custom(url: url)
    }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameter.asDictionary(),
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? {return nil}
    
    var authNeeded: Bool {return false}
    
    var langDepended: Bool {return false}
}

struct PostCustomCommentsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = PostCustomCommentsAPI
    init(json: JSON, sourceAPI: API) throws {
        print(json)
    }
}

//MARK: - GET https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=YourApiKeyToken
struct GetETHCurrentBlockAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "" }
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: C.BlockchainAPI.Etherscan.apiBase)!
        return .custom(url: url)
    }
    
    var method: Moya.Method { return .post }
    
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [
                "module" : "proxy",
                "action" : "eth_blockNumber",
                "apikey" : C.BlockchainAPI.Etherscan.apiKey
            ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetETHCurrentBlockAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetETHCurrentBlockAPI
    let blockHeight: Int
    init(json: JSON, sourceAPI: API) throws {
        guard let heightStr = json["result"].string else {
            throw GTServerAPIError.noData
        }
        
        let height = heightStr.hexaToDecimal
        self.blockHeight = height
    }
}

//MARK: - POST https://mainnet.infura.io
struct GetETHNonceAPI: KLMoyaAPIData {
    
    let ethAddress: String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "" }
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: "http://sit-api.ttchainwallet.com/MainnetInfura")!
        return .custom(url: url)
    }
    
    var method: Moya.Method { return .post }
    
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [
                "jsonrpc" : "2.0",
                "method" : "eth_getTransactionCount",
                "params" : [
                    ethAddress,
                    "latest"
                ],
                "id" : 1
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetETHNonceAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetETHNonceAPI
    
    let nonce: Int
    init(json: JSON, sourceAPI: API) throws {
        guard let hexNonce = json.string?.drop0xPrefix
            else {
//                let error = json["error"]
//                if let code = error["code"].int,
//                    let msg = error["message"].string  {
//                    throw GTServerAPIError.incorrectResult(String(code), msg)
//                }else {
//                    throw GTServerAPIError.noData
//                }
                throw GTServerAPIError.noData
        }
        
        let nonce = hexNonce.hexaToDecimal
        self.nonce = nonce
        //        self.nonce = nonce + 1
    }
}

//MARK: POST /{lang}/SignETHContract
struct SignETHTxAPI: KLMoyaAPIData {
    let nonce: Int
    let gasPriceInWei: Decimal
    let gasLimit: Int
    let toETHAddress: String
    let transferToken: Coin
    let transferValueInToken: Decimal
    //    let transferTokenName: String
    let pKey: String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var base: APIBaseEndPointType {
        return .custom(url: URL.init(string: C.HTTPServerAPI.urlStr)!)
    }
    
    var path: String {
        return "\(LangManager.instance.lang.value._db_name)/SignETHContract"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        guard let encryptedPKey = try?  APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: pKey) else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        var params: [String : Any] = [
            "token" : "eth",
            "privateKey" : encryptedPKey,
            "encry" : true
        ]
        
        if let contract = transferToken.contract, transferToken.identifier != Coin.eth_identifier {
            params["contractAddress"] = contract
        }
        
        let nonceStr = "0x" + String.init(nonce, radix: 16, uppercase: false)
        let urlParams : [String : String] = [
            "nonce" : nonceStr,
            "gasLimit" : String(gasLimit),
            "to" : toETHAddress,
            "value" : transferValueInToken.asString(digits: 0),
            "gasPrice" : gasPriceInWei.asString(digits: 0)
        ]
        
        return Moya.Task.requestCompositeParameters(bodyParameters: params, bodyEncoding: JSONEncoding.default, urlParameters: urlParams)
        //        return Moya.Task.requestParameters(
        //            parameters: params,
        //            encoding: JSONEncoding.default
        //        )
    }
    
    var stub: Data? { return nil }
    
    private var pathParamsDictionaryStr: String {
        let nonceStr = "0x" + String.init(nonce, radix: 16, uppercase: false)
        let params : [String : String] = [
            "nonce" : nonceStr,
            "gasLimit" : String(gasLimit),
            "to" : toETHAddress,
            "value" : transferValueInToken.asString(digits: 0),
            "gasPrice" : gasPriceInWei.asString(digits: 0)
        ]
        
        return params.jsonString() ?? errorDebug(response: "")
    }
}

struct SignETHTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = SignETHTxAPI
    let signText: String
    init(json: JSON, sourceAPI: API) throws {
        guard let signText = json["signText"].string else {
            guard let errorTitle = json["error"].string,
                let errorMsg = json["message"].string else {
                    throw GTServerAPIError.noData
            }
            
            throw GTServerAPIError.incorrectResult(errorTitle, errorMsg)
        }
        //gasLimit=120000&gasPrice=21725371465&nonce=0x4
        self.signText = signText
    }
}

//MARK: - POST /{lang}/MainnetInfura
struct BroadcastETHTxAPI: KLMoyaAPIData {
    
    let signText: String
    let comments: String
    
    var base: APIBaseEndPointType {
        return .custom(url: URL.init(string: C.HTTPServerAPI.urlStr)!)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return true }
    
    var path: String {
        return "\(LangManager.instance.lang.value._db_name)/MainnetInfura"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [
                "jsonrpc" : "2.0",
                "method" : "eth_sendRawTransaction",
                "params" : ["0x\(signText)"],
                "id" : 1,
                "comments": comments
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

//Error Response: Invalid address: Checksum mismatch. Code:1
struct BroadcastETHTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = BroadcastETHTxAPI
    
    let txid: String
    init(json: JSON, sourceAPI: API) throws {
        guard let txid = json.string else {
            throw GTServerAPIError.noData
        }
        
        self.txid = txid
    }
}


//MARK: - GET //https://api.etherscan.io/api?module=account&action=txlist&address=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae&startblock=0&endblock=99999999&sort=desc&apikey=YourApiKeyToken
struct GetETHTxRecordsAPI: KLMoyaAPIData {
    let startBlock: Int
    let endBlock: Int
    var ethAddress: String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var base: APIBaseEndPointType {
        return .custom(url: URL.init(string: C.BlockchainAPI.Etherscan.apiBase)!)
    }
    
    //https://api.etherscan.io/api?module=account&action=txlist&address=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae&startblock=0&endblock=99999999&sort=desc&apikey=YourApiKeyToken
    var path: String {
        return ""
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        
        return Moya.Task.requestParameters(
            parameters: [
                "module" : "account",
                "action" : "txlist",
                "sort" : "desc",
                "address" : ethAddress,
                //                "address" : "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae",
                //                0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
                "startblock" : startBlock,
                "endblock" : endBlock,
                "apikey" : C.BlockchainAPI.Etherscan.apiKey
            ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}


struct GetETHTxRecordsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetETHTxRecordsAPI
    
    let originTxsCount: Int
    let ethTxs: [ETHTx]
    init(json: JSON, sourceAPI: API) throws {
        guard let statusStr = json["status"].string,
            let status = Int(statusStr) else {
                throw GTServerAPIError.noData
        }
        
        //If cannot found any tx, will also return error code, but the result will be an array, which means it's just a valid empty result, so just need to check if is array or not.
        guard let result = json["result"].array else {
            if let errorMsg = json["message"].string {
                throw GTServerAPIError.incorrectResult(String(status), errorMsg)
            }else {
                throw GTServerAPIError.noData
            }
        }
        
        self.originTxsCount = result.count
        let txs = result.compactMap { (r) -> ETHTx? in
            guard let txid = r["hash"].string,
                let blockHeight = Int(r["blockNumber"].stringValue),
                let confirmations = Int(r["confirmations"].stringValue),
                let from = r["from"].string,
                let to = r["to"].string,
                let gasLimit = Decimal.init(string: r["gas"].stringValue),
                let gasUsed = Decimal.init(string: r["gasUsed"].stringValue),
                let gasPriceInWei = Decimal.init(string:  r["gasPrice"].stringValue),
                let nonce = Int(r["nonce"].stringValue),
                let valueInWei = Decimal.init(string: r["value"].stringValue),
                let timestamp = Double.init(r["timeStamp"].stringValue),
                let contractAddress = r["contractAddress"].string,
                let input = r["input"].string else {
                    return nil
            }
            
            let isError = (r["isError"].string == "1")
            let divisionDenominator: Decimal = pow(10, 18)
            let valueInETH = valueInWei / divisionDenominator
            var contract: String
            if input != "0x" && valueInWei == 0 {
                contract = to
            }else {
                contract = contractAddress
            }
            
            //            guard valueInETH > 0,
            //                Value.count == 0 else {
            //                    //In this case this might be a ERC-20 Token Transfer
            //                    return nil
            //            }
            
            return ETHTx(txid: txid,
                         blockHeight: blockHeight,
                         confirmations: confirmations,
                         fromAddress: from,
                         toAddress: to,
                         gasLimit: gasLimit,
                         gasUsed: gasUsed,
                         gasPriceInWei: gasPriceInWei,
                         nonce: nonce,
                         valueInCoinUnit: valueInETH,
                         timestamp: timestamp,
                         isError: isError,
                         input: input,
                         contract: contract)
        }
        
        self.ethTxs = txs
    }
    
}

//MARK: - GET
//  https://api.etherscan.io/api?module=account&action=tokentx&
//  [contractaddress=0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2]
//  &address=0x4e83362442b8d1bec281594cea3050c8eb01311c&page=1&
//  offset=100&sort=desc&apikey=YourApiKeyToken
struct GetETHTokenTxRecordsAPI: KLMoyaAPIData {
    let startBlock: Int
    let endBlock: Int
    let ethAddress: String
    let token: Coin?
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var base: APIBaseEndPointType {
        return .custom(url: URL.init(string: C.BlockchainAPI.Etherscan.apiBase)!)
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        var params: [String: Any] = [
            "module" : "account",
            "action" : "tokentx",
            "sort" : "desc",
            "address" : ethAddress,
            "startblock" : startBlock,
            "endblock" : endBlock,
            "apikey" : C.BlockchainAPI.Etherscan.apiKey
        ]
        
        if let contract = token?.contract {
            params["contractaddress"] = contract
        }
        
        return Moya.Task.requestParameters(
            parameters: params,
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetETHTokenTxRecordsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetETHTokenTxRecordsAPI
    
    let originTxsCount: Int
    let tokenTxs: [TokenTx]
    init(json: JSON, sourceAPI: API) throws {
        guard let statusStr = json["status"].string,
            let status = Int(statusStr) else {
                throw GTServerAPIError.noData
        }
        
        //If cannot found any tx, will also return error code, but the result will be an array, which means it's just a valid empty result, so just need to check if is array or not.
        guard let result = json["result"].array else {
            if let errorMsg = json["message"].string {
                throw GTServerAPIError.incorrectResult(String(status), errorMsg)
            }else {
                throw GTServerAPIError.noData
            }
        }
        
        self.originTxsCount = result.count
        let txs = result.compactMap { (r) -> TokenTx? in
            guard let txid = r["hash"].string,
                let blockHeight = Int(r["blockNumber"].stringValue),
                let confirmations = Int(r["confirmations"].stringValue),
                let from = r["from"].string,
                let to = r["to"].string,
                let gasLimit = Decimal.init(string: r["gas"].stringValue),
                let gasUsed = Decimal.init(string: r["gasUsed"].stringValue),
                let gasPriceInWei = Decimal.init(string:  r["gasPrice"].stringValue),
                let nonce = Int(r["nonce"].stringValue),
                let valueInToken = Decimal.init(string: r["value"].stringValue),
                let tokenDecimal = Int(r["tokenDecimal"].stringValue),
                let timestamp = Double.init(r["timeStamp"].stringValue),
                let input = r["input"].string,
                let contractAddress = r["contractAddress"].string else {
                    return nil
            }
            
            let isError = (r["isError"].string == "1")
            let divisionDenominator: Decimal = pow(10, tokenDecimal)
            let tokenInTokenUnit = valueInToken / divisionDenominator
            
            guard valueInToken > 0 else {
                return nil
            }
            
            var finalToken: Coin
            if let token = sourceAPI.token,
                let contract = token.contract {
                //If target for specific token, check if address is same
                guard contractAddress == contract else {
                    return nil
                }
                
                finalToken = token
            }else {
                //If for general records, check the contract address has local mapped coin.
                guard let token = Coin.getCoin(ofContractAddress: contractAddress) else {
                    return nil
                }
                
                finalToken = token
            }
            
            return TokenTx(txid: txid,
                           blockHeight: blockHeight,
                           confirmations: confirmations,
                           fromAddress: from,
                           toAddress: to,
                           gasLimit: gasLimit,
                           gasUsed: gasUsed,
                           gasPriceInWei: gasPriceInWei,
                           nonce: nonce,
                           token: finalToken,
                           valueInCoinUnit: tokenInTokenUnit,
                           timestamp: timestamp,
                           isError: isError,
                           input: input)
        }
        
        self.tokenTxs = txs
    }
}

//MARK: - POST /{lang}/SignBTCRelay
struct LTSignBTCRelayTxAPI: KLMoyaAPIData {
    let btcWalletPrivateKey: String
    var epKey: String? {
        return try? APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: btcWalletPrivateKey)
    }
    let fromBTCAddress: String
    let toCICAddress: String
    let unspents: [Unspent]
    let transferBTC: Decimal
    let feeBTC: Decimal
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "\(LangManager.instance.lang.value._db_name)/SignBTCRelay"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        guard let _epKey = epKey else { return Moya.Task.requestPlain }
        
        let totalUnspentBTC = unspents.map { $0.amount }.reduce(0, +)
        let changeBTC = totalUnspentBTC.decimalValue - (transferBTC + feeBTC)
        guard changeBTC >= 0 else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        let transferSatoshi = transferBTC.btcToSatoshi
        let changeSatoshi = changeBTC.btcToSatoshi
        var truncedCICAddress: String = toCICAddress
        while truncedCICAddress.hasPrefix("cx") {
            truncedCICAddress = (truncedCICAddress as NSString).substring(from: 2)
        }
        
        let unspentParams = unspents.map {
            unspent -> [String : Any] in
            return [
                "txid" : unspent.txid,
                "value" : unspent.vout
            ]
        }
        
        return Moya.Task.requestParameters(
            parameters: [
                "token" : "btcrelay",
                "encry" : true,
                "privatekey" : _epKey,
                "cicAddress" : truncedCICAddress,
                "tx": [
                    [
                        "address" : C.BlockchainAPI.LightningTrade.lt_officialBTCAddress,
                        "value" : transferSatoshi
                    ],
                    [
                        "address" : fromBTCAddress,
                        "value" : changeSatoshi
                    ]
                ],
                "unspend" : unspentParams,
                "compressed" : false
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct LTSignBTCRelayTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = LTSignBTCRelayTxAPI
    let signText: String
    init(json: JSON, sourceAPI: API) throws {
        guard let signText = json["signText"].string else {
            if let errorCode = json["error"].string,
                let message = json["message"].string {
                throw GTServerAPIError.incorrectResult(errorCode, message)
            }
            
            throw GTServerAPIError.noData
        }
        
        self.signText = signText
    }
}

//MARK: - LT broadcast btc realy (same as btc braodcast)
typealias LTBroadcastBTCRelayTxAPI = BroadcastBTCTxAPI
typealias LTBroadcastBTCRelayTxAPIModel = BroadcastBTCTxAPIModel

//MARK: GET CIC Nonce
struct GetCICNonceAPI: KLMoyaAPIData {
    let address: String
    let mainCoin: Coin
    
    var base: APIBaseEndPointType {
        let urlString = C.BlockchainAPI.urlStr_32000
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/topChain/getBalance_app/\(address)"
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "token" : mainCoin.chainName!.uppercased() ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetCICNonceAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetCICNonceAPI
    let nonce: Int
    init(json: JSON, sourceAPI: API) throws {
        guard let nonce = json["nonce"].int else {
            throw GTServerAPIError.noData
        }
        
        self.nonce = nonce
    }
}

//MARK: - http://125.227.132.127:3206/topChain/newSignAll/{cic private key}/{}
struct SignCICTxAPI: KLMoyaAPIData {
    let fromAsset: Asset
    var epKey: String? {
        return try? APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: fromAsset.wallet!.pKey)
    }
    let transferAmt_smallestUnit: Decimal
    let toAddress: String
    let toAddressType: ChainType
    let feeInSmallestUnit: Decimal
    let nonce: Int
    //Change to store variable if open input field in future.
    var input: String { return "" }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/topChain/newSignAll/{}/{}"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        guard let _epKey = epKey else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        //        let wallet = fromAsset.wallet!
        let coin = fromAsset.coin!
        let addressTypeStr: String
        let token = fromAsset.wallet!.mainCoin!.chainName!.lowercased()
        switch toAddressType {
        case .btc: addressTypeStr = "btc"
        case .eth: addressTypeStr = "eth"
        case .cic:
            addressTypeStr = token
        case .ttn,.ifrc:
            addressTypeStr = ""
        }
        
        return Moya.Task.requestParameters(
            parameters: [
                "token" : token,
                "fee" : feeInSmallestUnit.asString(digits: 0),
                "address" : toAddress,
                "coin" : coin.blockchainAPI_identifier.lowercased(),
                "balance" : transferAmt_smallestUnit.asString(digits: 0),
                "nonce" : String(nonce),
                "type" : addressTypeStr,
                "input" : input,
                "PrivateKey" : _epKey,
                "encry" : true
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct SignCICTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = SignCICTxAPI
    let broadcastContent: [String : Any]
    init(json: JSON, sourceAPI: API) throws {
        guard let content = json["result"].dictionaryObject else {
            throw GTServerAPIError.noData
        }
        
        self.broadcastContent = content
    }
}

//MARK: - CIC Broadcast
struct BroadcastCICTxAPI: KLMoyaAPIData {
    let contentData: [String : Any]
    let mainCoin: Coin
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/topChain/CICBroadcast" }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [
                "method" : "sendTransaction",
                "token" : mainCoin.chainName!.lowercased(),
                "param" : [contentData]
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct BroadcastCICTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = BroadcastCICTxAPI
    let txid: String
    init(json: JSON, sourceAPI: API) throws {
        //TODO: Need to confirm the response checking format
        guard let txid = sourceAPI.contentData["txid"] as? String else {
            throw GTServerAPIError.noData
        }
        
        if let result = json["result"].bool {
            guard result else {
                throw GTServerAPIError.noData
            }
        }else if let results = json["result"].array {
            guard let resultCheck = results.first?.bool,
                resultCheck else {
                    if let reason = results.last?.string {
                        throw GTServerAPIError.incorrectResult(reason, reason)
                    }else {
                        throw GTServerAPIError.noData
                    }
            }
        }
        
        self.txid = txid
    }
}

//MARK: - get CIC Tx
struct GetCICTxRecordsAPI: KLMoyaAPIData {
    let address: String
    let mainCoin: Coin
    
    var base: APIBaseEndPointType {
        let urlString: String = C.BlockchainAPI.urlStr_32000
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/topChain/getBalance_app/\(address)"
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "token" : mainCoin.chainName!.uppercased() ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetCICTxRecordsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetCICTxRecordsAPI
    let txs: [CICTx]
    init(json: JSON, sourceAPI: API) throws {
        guard let txJSONs = json["transactions"].array else { throw GTServerAPIError.noData }
        
        //        let identifier = sourceAPI.asset.coin!.blockchainAPI_identifier.lowercased()
        let txs = txJSONs.compactMap { (txJSON) -> CICTx? in
            guard let txid = txJSON["txid"].string,
                let to = txJSON["to"].string,
                //                let from = txJSON["from"].string,
                let feeStr = txJSON["fee"].string,
                let feeInCICSmallestUnit = Decimal.init(string: feeStr),
                let timestamp = txJSON["timestamp"].number?.doubleValue,
                let nonceStr = txJSON["nonce"].string,
                let nonce = Int(nonceStr),
                let out = txJSON["out"].dictionary else {
                    return nil
            }
            
            let from: String
            if to == sourceAPI.address {
                guard let _from = txJSON["from"].string else { return nil }
                from = _from
            }else {
                from = sourceAPI.address
            }
            
            guard let firstOutPair = out.first else { return nil }
            let name = firstOutPair.key
            
            let caseInsensitiveCoin = Coin.getCoin(ofChainName: name, chainType: .cic) ?? Coin.getCoin(ofChainName: name.uppercased(), chainType: .cic)
            
            guard let coin = caseInsensitiveCoin,
                coin.walletMainCoinID == sourceAPI.mainCoin.identifier else {
                    return nil
            }
            
            guard let smallestAmtStr = firstOutPair.value.string,
                let smallestAmt = Decimal.init(string: smallestAmtStr) else {
                    return nil
            }
            
            let coinUnitAmt = smallestAmt / pow(10, Int(coin.digit))
            let feeInCICAmt = feeInCICSmallestUnit / pow(10, Int(Coin.cic.digit))
            
            
            //NOTE: Blockheight and confirmation cannot search from the api response now, these two fields is only design for future features. so it's fine to set it to 0 now.
            return CICTx(toAddress: to,
                         fromAddress: from,
                         coin: coin,
                         valueInCoinUnit: coinUnitAmt,
                         feeInCICUnit: feeInCICAmt,
                         nonce: nonce,
                         txid: txid,
                         blockHeight: 0,
                         confirmations: 0,
                         timestamp: timestamp)
        }
        
        
        self.txs = txs
    }
}


//MARK: TTN

struct GetTTNAssetAmountAPI:KLMoyaAPIData {
    let address: String
    
    var base: APIBaseEndPointType {
        let urlString = "http://3.1.196.86:9997"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/getAccount"
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(parameters: ["address":address ], encoding: URLEncoding.default)
    }
    
    var stub: Data? { return nil }
}

struct GetTTNAssetAmountAPIModel : KLJSONMappableMoyaResponse {
    typealias API = GetTTNAssetAmountAPI
    struct Balance {
        let ttnBalance:Decimal
        let usdtnBalance:Decimal
        let ethnBalance:Decimal
        let exrBalance:Decimal
        let btcnBalance:Decimal
        let mccBalance:Decimal
    }
    var balance:Balance!
    init(json: JSON, sourceAPI: API) throws {
        guard let ttnBalanceStr = json["Balance"].string, let ttnBal = Decimal.init(string: ttnBalanceStr) else {
            balance = Balance.init(ttnBalance: 0, usdtnBalance: 0, ethnBalance: 0, exrBalance: 0, btcnBalance: 0, mccBalance: 0)
            return
        }
        let tokenDict = json["Token"].dictionary ?? [:]
        let rateToCoinUnit: Decimal = 1 / pow(
            Decimal.init(10),
            Int(18)
        )
        
        let rateToCoinUnitBTCN: Decimal = 1 / pow(
            Decimal.init(10),
            Int(8)
        )
        
        let usdtBal = Decimal.init(string:tokenDict["usdtn"]?.string ?? "") ?? 0
        let ethnBal = Decimal.init(string:tokenDict["ethn"]?.string ?? "") ?? 0
        let btcnBal = Decimal.init(string:tokenDict["btcn"]?.string ?? "") ?? 0
        let exrBal = Decimal.init(string:tokenDict["exr"]?.string ?? "") ?? 0
        let mccBal = Decimal.init(string:tokenDict["mcc"]?.string ?? "") ?? 0
        self.balance = Balance.init(ttnBalance: ttnBal*rateToCoinUnit,
                                    usdtnBalance: usdtBal*rateToCoinUnitBTCN,
                                    ethnBalance: ethnBal*rateToCoinUnit,
                                    exrBalance: exrBal*rateToCoinUnit,
                                    btcnBalance: btcnBal*rateToCoinUnitBTCN,
                                    mccBalance: mccBal*rateToCoinUnit)
    }
}

//MARK: GET CIC Nonce
struct GetTTNNonceAPI: KLMoyaAPIData {
    let address: String
    let mainCoin: Coin
    var base: APIBaseEndPointType {
        let urlString = "http://3.1.196.86:9997"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/getAccount"
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(parameters: ["address":address ], encoding: URLEncoding.default)
    }
    
    var stub: Data? { return nil }
}

struct GetTTNNonceAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetTTNNonceAPI
    let nonce: Int
    init(json: JSON, sourceAPI: API) throws {
        guard let nonce = json["Nonce"].int else {
            throw GTServerAPIError.noData
        }
        
        self.nonce = nonce
    }
}

struct SignBTCToTTNTxAPI: KLMoyaAPIData {
    
    let btcWalletPrivateKey: String
    let fromBTCAddress: String
    let toBTCAddress: String
    let isUSDTTx:Bool
    let transferBTC: Decimal
    let feeBTC: Decimal
    let compressed:Bool
    let unspents: [Unspent]
    let ttnAddress:String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var base: APIBaseEndPointType {
        let urlString = "http://3.112.106.186:32000"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    var path: String {
        return "/topChain/newSignAll/1/1"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        let totalUnspentBTC = unspents.map { $0.amount }.reduce(0, +)
        let changeBTC = totalUnspentBTC.decimalValue - ((isUSDTTx ? 0 : transferBTC) + feeBTC)
        guard changeBTC >= 0 else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        guard let encryptedPKey = try? APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: btcWalletPrivateKey) else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        let transferSatoshi = transferBTC.btcToSatoshi
        let changeSatoshi = changeBTC.btcToSatoshi
        
        let unspentParams = unspents.map {
            unspent -> [String : Any] in
            return [
                "txid" : unspent.txid,
                "value" : unspent.vout
            ]
        }
        
        return Moya.Task.requestParameters(
            parameters: [
                "token" : "btcrelay",
                "encry" : true,
                "privatekey" : encryptedPKey,
                "cicAddress":ttnAddress,
                "tx": [
                    [
                        "address" : toBTCAddress,
                        "value" : transferSatoshi
                    ],
                    [
                        "address" : fromBTCAddress,
                        "value" : changeSatoshi
                    ]
                ],
                "unspend" : unspentParams,
                "compressed" :  compressed
            ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct SignBTCToTTNTxAPIModel: KLJSONMappableMoyaResponse {
    typealias API = SignBTCToTTNTxAPI
    let signText: String
    init(json: JSON, sourceAPI: API) throws {
        guard let signText = json["signText"].string else {
            if let errorCode = json["error"].string,
                let message = json["message"].string {
                throw GTServerAPIError.incorrectResult(errorCode, message)
            }
            
            throw GTServerAPIError.noData
        }
        
        self.signText = signText
    }
}


struct SignIfrcTxAPI:KLMoyaAPIData {
    let fromAsset: Asset
    var epKey: String? {return fromAsset.wallet?.pKey }
    let transferAmt_smallestUnit: Decimal
    let toAddress: String
    let feeInSmallestUnit: Decimal
    let nonce: Int
    let transType:TransType
    enum TransType {
        case ifrcTx
        case btcnWithdraw
    }
    
    var input: String { return transType == .btcnWithdraw ? C.TTNTx.withdrawInputPrefix + toAddress : ""}
    
    var base: APIBaseEndPointType {
        let urlString = "http://3.1.196.86:9997"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "/signTransaction"
    }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        
        var param : [String:Any] = [
            "fee" : "0",
            "address" : transType == .btcnWithdraw ? C.TTNTx.officialTTNAddress : toAddress,
            "crypto" : "cic",
            "balance" : transferAmt_smallestUnit.asString(digits: 0),
            "nonce" : nonce,
            "type" : "ifrc",
            "input" : input,
            "PrivateKey" : epKey ?? ""
        ]
        
        if fromAsset.coinID != Coin.ifrc_identifier {
            let balance = self.transType == .btcnWithdraw ? transferAmt_smallestUnit + feeInSmallestUnit : transferAmt_smallestUnit
            let outDict = ["balance":balance.asString(digits: 0),"token" : fromAsset.coin?.chainName?.lowercased() ?? ""]
            let outArray : [[String:String]] = [outDict]
            param["out"] = outArray
            param["balance"] = "0"
        }
        
        return Moya.Task.requestParameters(
            parameters: param,
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct SignTTNTxAPIModel:KLJSONMappableMoyaResponse {
   
    let broadcastContent: [String : Any]
    init(json: JSON, sourceAPI: SignIfrcTxAPI) throws {
        guard let content = json["result"].dictionaryObject else {
            throw GTServerAPIError.noData
        }
        
        self.broadcastContent = content
    }
    
    typealias API = SignIfrcTxAPI
}

struct BroadcastTTNTxAPI: KLMoyaAPIData {
    let contentData: [String : Any]
    let mainCoin: Coin
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var base: APIBaseEndPointType {
        let urlString = "http://3.1.196.86:9997"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var path: String { return "/broadcastPy" }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters:contentData,
            encoding: JSONEncoding.default
        )
    }
    
    
    var stub: Data? { return nil }
}

struct BroadcastTTNTxAPIModel: KLJSONMappableMoyaResponse {
    init(json: JSON, sourceAPI: BroadcastTTNTxAPI) throws {
        //TODO: Need to confirm the response checking format
        guard let txid = sourceAPI.contentData["tx"] as? String else {
            throw GTServerAPIError.noData
        }
        guard let tx = json["txid"].string,let result = json["result"].bool else {
            throw GTServerAPIError.noData
        }
        if result {
            if tx == txid {
                self.txid = tx
            }else {
                self.txid = ""
            }
        }else {
            self.txid = ""

            if let msg = json["message"].string {
            throw GTServerAPIError.incorrectResult("", msg)
            }else {
                throw GTServerAPIError.incorrectResult("", "")
            }
        }
    }
    
    typealias API = BroadcastTTNTxAPI
    let txid: String
}

struct GetTTNTxRecordsAPI: KLMoyaAPIData {
    let address: String
    let mainCoin: Coin
    
    var base: APIBaseEndPointType {
        let urlString = "http://3.1.196.86:9997"
        let url = URL.init(string: urlString)!
        return .custom(url: url)
    }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String {
        return "getAccount"
    }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "address" : address ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetTTNTxRecordsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetTTNTxRecordsAPI
    let txs: [TTNTx]
    init(json: JSON, sourceAPI: API) throws {
        guard let txJSONs = json["Transaction"].array else { throw GTServerAPIError.noData }
        
        //        let identifier = sourceAPI.asset.coin!.blockchainAPI_identifier.lowercased()
        let txs = txJSONs.compactMap { (txJSON) -> TTNTx? in
            guard let txid = txJSON["tx"].string,
                var to = txJSON["to"].string,
                let feeStr = txJSON["fee"].string,
                let feeInSmallestUnit = Decimal.init(string: feeStr),
                let timestamp = txJSON["timestamp"].number?.doubleValue,
                let nonce = txJSON["nonce"].int,
                var from = txJSON["from"].string else {
                    return nil
            }
            
            if to == sourceAPI.address {
                guard let _from = txJSON["from"].string else { return nil }
                from = _from
            }else {
                from = sourceAPI.address
            }
     
            var balance:Decimal?
            var coin:Coin?
            if let outArray = txJSON["out"].array, let outDict = outArray.first {
                if let token = outDict["token"].string {
                    balance = Decimal.init(string:outDict["balance"].string ?? "") ?? 0
                    if let input = txJSON["input"].string, input.contains(C.TTNTx.withdrawInputPrefix, caseSensitive: false) {
                        to = input.replacingOccurrences(of: C.TTNTx.withdrawInputPrefix, with: "")
                    }
                    if token == "btcn" {
                        coin = Coin.getCoin(ofIdentifier: Coin.btcn_identifier)!
                    }else if token == "usdtn" {
                        coin = Coin.getCoin(ofIdentifier: Coin.usdtn_identifier)!
                    }else if token == "exr" {
                        coin = Coin.getCoin(ofIdentifier: Coin.exr_identifier)!
                    }else if token == "ethn" {
                        coin = Coin.getCoin(ofIdentifier: Coin.ethn_identifier)!
                    }
                }
                
            }else {
                balance = Decimal.init(string:txJSON["balance"].string ?? "") ?? 0
                coin = Coin.getCoin(ofIdentifier: Coin.ifrc_identifier)!
            }
            guard coin != nil else {
                return nil
            }
            let coinUnitAmt = balance! / pow(10, Int(coin!.requiredDigit))
            let feeInTTNAmt = feeInSmallestUnit > 0 ? (feeInSmallestUnit / pow(10, Int(coin!.requiredDigit))) : 0
            
            
            //NOTE: Blockheight and confirmation cannot search from the api response now, these two fields is only design for future features. so it's fine to set it to 0 now.
            return TTNTx(toAddress: to,
                         fromAddress: from,
                         coin: coin!,
                         valueInCoinUnit: coinUnitAmt,
                         feeInTTNUnit: feeInTTNAmt,
                         nonce: nonce,
                         txid: txid,
                         blockHeight: 0,
                         confirmations: 0,
                         timestamp: timestamp)
        }
        self.txs = txs
    }
}
//MARK: - Post /topChain/account
struct CreateAccountAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/topChain/account" }
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        if let mnemonic = defaultMnemonic {
            do {
                let encryptedMnemonic = try APISensitiveDataCrypter
                    .encryptMnemonic(rawMnemonic: mnemonic)
                return Moya.Task.requestParameters(
                    parameters: ["mnemonic" : encryptedMnemonic,
                                 "encry" : true],
                    encoding: JSONEncoding.default
                )
            }
            catch let error {
                warning("Crypt Error: \(error)")
                return errorDebug(response: Moya.Task.requestPlain)
            }
        }else {
            return Moya.Task.requestParameters(
                parameters: ["encry" : true,"word":"cs"],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var stub: Data? { return nil }
    
    let defaultMnemonic: String?
}

struct CreateAccountAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CreateAccountAPI
    typealias WalletInfo = (pKey: String, address: String)
    
    let mnemonic: String
    let hdKey: String
    //MainCoinID : WalletInfo
    private(set) var walletsMap: [String : WalletInfo]
    //    let bitcoin: WalletInfo
    //    let ethereum: WalletInfo
    //    let cic: WalletInfo
    
    init(json: JSON, sourceAPI: API) throws {
        guard let content = json["eprivatekey"].string else {
            throw GTServerAPIError.noData
        }
        
        guard let jsonString = try? APISensitiveDataCrypter.decrypt(enc: content) else {
            throw GTServerAPIError.noData
        }
        
        guard let dictionaryOptional = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments),
            let dictionary = dictionaryOptional as? [String : Any] else {
                throw GTServerAPIError.noData
        }
        
        let json = JSON.init(dictionary)
        #if DEBUG
        print("create account decyrpted content:\n\(json.description)")
        #endif
        
        guard let mnemonic = json["mnemonic"].string,
            let hdKey = json["HDkey"].string else {
                throw GTServerAPIError.noData
        }
        
        
        let fetchWallet: (JSON) -> WalletInfo? = {
            json in
            guard let pKey = json["privateKey"].string,
                let address = json["address"].string else {
                    return nil
            }
            
            return (pKey: pKey, address: address)
            //            #if DEBUG
            //            return (pKey: pKey, address: "0xEEC9b74b073A3Ee2cc36F75DecF1DDEEDD243d06".lowercased())
            //            #else
            //            0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
            //            #endif
        }
        
        let fetchBTCWallet: (JSON) -> WalletInfo? = {
            json in
            guard let pKey = json["privateKey"].string,
                let address = json["UncompressAddress"].string else {
                    return nil
            }
            
            //3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r
            //            #if DEBUG
            //            return (pKey: pKey, address: "3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r")
            //            #else
            
            return (pKey: pKey, address: address)
            //            #endif
        }
        
        let jsonMap = json.dictionaryValue
        walletsMap = [:]
        for (k, v) in jsonMap where v.dictionary != nil {
            switch k {
            case "bitcoin":
                guard let btc = fetchBTCWallet(v) else { throw GTServerAPIError.noData }
                walletsMap[Coin.btc_identifier] = btc
            case "ethereum":
                guard let eth = fetchWallet(v) else { throw GTServerAPIError.noData }
                walletsMap[Coin.eth_identifier] = eth
            case "cic":
                guard let cic = fetchWallet(v) else { throw GTServerAPIError.noData }
                walletsMap[Coin.cic_identifier] = cic
            default:
                guard let mainCoin = Coin.getCoin(ofChainName: k, chainType: .cic),
                    let wallet = fetchWallet(v) else {
                        continue
                        //                        throw GTServerAPIError.noData
                }
                
                walletsMap[mainCoin.identifier!] = wallet
            }
        }
        
        self.mnemonic = mnemonic
        self.hdKey = hdKey
    }
}

//MARK: - Post /topChain/keyToAddress
struct KeyToAddressAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/topChain/keyToAddress" }
    
    var method: Moya.Method { return .post }
    
    let pKey: String
    let encrypted:Bool
    var task: Task {
        guard let encryptedPKey = try? APISensitiveDataCrypter.encryptPrivateKey(rawPrivateKey: pKey) else {
            return errorDebug(response: Moya.Task.requestPlain)
        }
        
        return Moya.Task.requestParameters(
            parameters: [ "privateKey" : encrypted ? encryptedPKey : pKey,
                          "encry" : encrypted ],
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct KeyToAddressAPIModel: KLJSONMappableMoyaResponse {
    typealias API = KeyToAddressAPI
    typealias WalletInfo = (pKey: String, address: String)
    
    let pKey: String
    private(set) var addressMap: [String : String]
    
    init(json: JSON, sourceAPI: API) throws {
        
        //        let fetchWallet: (JSON) -> WalletInfo? = {
        //            json in
        //            guard let pKey = json["privateKey"].string,
        //                let address = json["address"].string else {
        //                    return nil
        //            }
        //
        //            return (pKey: pKey, address: address)
        //        }
        //
        //Prevent any decrypted-failed case, assume all the address result to optional.
        guard let map = json.dictionary else { throw GTServerAPIError.noData }
        addressMap = [:]
        for (k, v) in map {
            guard let addr = v.string else { continue }
            switch k {
            case "BitcoinAddress:":
                addressMap[Coin.btc_identifier] = addr
            case "EthereumAddress:":
                addressMap[Coin.eth_identifier] = addr
            case "CICAddress:":
                addressMap[Coin.cic_identifier] = addr
            case "BitcoinAddressUncompress:":
                let key = "\(Coin.btc_identifier)uncompressed"
                addressMap[key] = addr
            default:
                //API Response format is really suck.
                let clearedKey = k.replacingOccurrences(of: ":", with: "")
                guard let mainCoin = Coin.getCoin(ofChainName: clearedKey, chainType: .cic) else { continue }
                addressMap[mainCoin.identifier!] = addr
            }
        }
        
        self.pKey = sourceAPI.pKey
    }
}

struct MarketTestAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/en-us/GetMarketInfo" }
    
    var method: Moya.Method { return .get }
        
    var task: Task {
//        var lang: String
//        switch LangManager.instance.lang.value._db_name {
//        case Lang.en_us._db_name:
//            lang = "en"
//        case Lang.zh_cn._db_name:
//            lang = "cs"
//        case Lang.zh_tw._db_name:
//            lang = "zh"
//        default:
//            lang = "zh"
//        }
//        return Moya.Task.requestParameters(
//            parameters: [ "language" : lang
//                          ],
//            encoding: URLEncoding.default
//        )
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
}


struct MarketTestAPIModel: KLJSONMappableMoyaResponse{
    typealias API = MarketTestAPI
    
    init(json: JSON, sourceAPI: API) throws {
        guard json != JSON.null else {
            throw GTServerAPIError.noData
        }
        MarketTestHandler.shared.manageMarketTestData(json: json)
        
    }
}

struct QuotesTestAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/CrypetocurrencyQuotes" }
    
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
}


struct QuotesTestAPIModel: KLJSONMappableMoyaResponse{
    typealias API = QuotesTestAPI
    
    init(json: JSON, sourceAPI: API) throws {
        guard json != JSON.null else {
            throw GTServerAPIError.noData
        }
        MarketTestHandler.shared.managetQuotesTestData(json: json)
        
    }
}

enum HelperAPI: KLMoyaAPISet {
    var api: KLMoyaAPIData {
        switch self {
        case .getCoins(let api): return api
        case .getCoinsTest(let api): return api
        case .getFiats(let api): return api
        case .getFiatRateTable(let api): return api
        case .getAddressBook(let api): return api
        case .createAddressBookUnit(let api): return api
        case .updateAddressBookUnit(let api): return api
        case .deleteAddressBookUnit(let api): return api
        case .getBTCFee(let api): return api
        case .getETHFee(let api): return api
        case .getCICFee(let api): return api
        case .getLightningTransRate(let api): return api
        case .getCoinToUSDRate(let api): return api
            
        case .broadcastETHTx(let api): return api
        case .broadcastBTCTx(let api): return api
        case .customComments(let api): return api
            
        case .postCustomComment(let api): return api
            
        case .signETHTx(let api): return api
        case .signBTCTx(let api): return api
            
        case .getMarketTestAPI(let api): return api
        case .getQuotesTestAPI(let api): return api
        }
    }
    
    case getAddressBook(GetAddressBookAPI)
    case createAddressBookUnit(CreateAddressBookUnitAPI)
    case updateAddressBookUnit(UpdateAddressBookUnitAPI)
    case deleteAddressBookUnit(DeleteAddressBookUnitAPI)
    case getCoins(CoinsAPI)
    case getCoinsTest(CoinsTestAPI)
    case getFiats(FiatsAPI)
    case getFiatRateTable(FiatRateTableAPI)
    
    case getBTCFee(GetBTCFeeAPI)
    case getETHFee(GetETHFeeAPI)
    case getCICFee(GetCICFeeAPI)
    case getLightningTransRate(GetLightningTransRateAPI)
    case getCoinToUSDRate(GetCoinToUSDRateAPI)
    
    
    case broadcastETHTx(BroadcastETHTxAPI)
    case broadcastBTCTx(BroadcastBTCTxAPI)
    
    case customComments(GetCustomCommentsAPI)
    case postCustomComment(PostCustomCommentsAPI)
    case signETHTx(SignETHTxAPI)
    case signBTCTx(SignBTCTxAPI)
    
    case getMarketTestAPI(MarketTestAPI)
    case getQuotesTestAPI(QuotesTestAPI)
}

//MARK: - GET /Addressbook
struct GetAddressBookAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    let identity: Identity
    
    var path: String { return "/AddressBook" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "identityID" : identity.id! ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetAddressBookAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetAddressBookAPI
    let abUnitResources: [AddressBookUnitCreateSource]
    init(json: JSON, sourceAPI: API) throws {
        guard let unitJSONs = json.array else {
            throw GTServerAPIError.noData
        }
        
        abUnitResources = unitJSONs.compactMap({ (unitJSON) in
            guard let id = unitJSON["id"].string,
                let chainTypeRaw = unitJSON["chainType"].int16,
                let chainType = ChainType.init(rawValue: chainTypeRaw),
                let mainCoinID = unitJSON["mainCoinID"].string,
                let address = unitJSON["address"].string,
                let name = unitJSON["name"].string else {
                    return nil
            }
            
            let note = unitJSON["note"].string
            return AddressBookUnitCreateSource(
                id: id,
                chainType: chainType,
                mainCoinID: mainCoinID,
                address: address,
                name: name,
                note: note
            )
        })
    }
}

//MARK: - POST /Addressbook
struct CreateAddressBookUnitAPI: KLMoyaAPIData {
    let identity: Identity
    let id: String
    let chainType: ChainType
    let mainCoinID: String
    let address: String
    let name: String
    let note: String?
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/AddressBook" }
    var method: Moya.Method { return .post }
    
    var task: Task {
        var unit: [String: Encodable] = [
            "id" : id,
            "chainType" : chainType.rawValue,
            "address" : address,
            "name" : name,
            "mainCoinID" : mainCoinID
        ]
        
        if let _note = note {
            unit["note"] = _note
        }
        
        let inputUnits = [unit]
        let json = JSON.init(inputUnits)
        guard let data = try? json.rawData() else {
            fatalError()
        }
        
        return Moya.Task.requestCompositeData(bodyData: data, urlParameters: [ "identityID" : identity.id! ]
        )
    }
    
    var stub: Data? { return nil }
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
}

struct CreateAddressBookUnitAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CreateAddressBookUnitAPI
    init(json: JSON, sourceAPI: API) throws { }
}


//MARK: - PUT /Addressbook
struct UpdateAddressBookUnitAPI: KLMoyaAPIData {
    let identity: Identity
    let id: String
    let chainType: ChainType
    let mainCoinID: String
    let address: String
    let name: String
    let note: String?
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/AddressBook" }
    var method: Moya.Method { return .put }
    
    var task: Task {
        var unit: [String: Encodable] = [
            "id" : id,
            "chainType" : chainType.rawValue,
            "address" : address,
            "name" : name,
            "mainCoinID" : mainCoinID
        ]
        
        if let _note = note {
            unit["note"] = _note
        }
        
        guard let data = unit.jsonData() else {
            fatalError()
        }
        
        return Moya.Task.requestCompositeData(bodyData: data, urlParameters: [ "identityID" : identity.id! ]
        )
    }
    
    var stub: Data? { return nil }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
}

struct UpdateAddressBookUnitAPIModel: KLJSONMappableMoyaResponse {
    typealias API = UpdateAddressBookUnitAPI
    init(json: JSON, sourceAPI: API) throws { }
}

//MARK: - Delete /Addressbook
struct DeleteAddressBookUnitAPI: KLMoyaAPIData {
    let identity: Identity
    let id: String
    let chainType: ChainType
    let mainCoinID: String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/AddressBook" }
    var method: Moya.Method { return .delete }
    
    var task: Task {
        let unit: [String: Encodable] = [
            "identityID" : identity.id!,
            "uuid" : id,
            "chainType" : chainType.rawValue,
            "mainCoinID" : mainCoinID
        ]
        
        return Moya.Task.requestParameters(
            parameters: unit,
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
}

struct DeleteAddressBookUnitAPIModel: KLJSONMappableMoyaResponse {
    typealias API = DeleteAddressBookUnitAPI
    init(json: JSON, sourceAPI: API) throws { }
}

//MARK: - GET /coins
struct CoinsAPI: KLMoyaLangAPIData {
    var path: String { return "/coins" }
    var method: Moya.Method { return .get }
    
    let query: String?
    let defaultOnly: Bool
    let chainType: ChainType?
    let mainCoinID: String?
    
    var task: Task {
        var params: [String : Any] = [
            "defaultOnly" : defaultOnly
        ]
        
        if let q = query {
            params["queryString"] = q
        }
        
        if let type = chainType {
            params["chainType"] = type.rawValue
        }
        
        if let mainCoinID = mainCoinID {
            params["mainCoinID"] = mainCoinID
        }
        
        return Moya.Task.requestParameters(
            parameters: params,
            encoding: URLEncoding.init(destination: URLEncoding.Destination.queryString, arrayEncoding: URLEncoding.ArrayEncoding.brackets, boolEncoding: URLEncoding.BoolEncoding.literal
            )
        )
    }
    
    var stub: Data? { return nil }
}

struct CoinsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CoinsAPI
    struct CoinSource {
        var chainType: ChainType
        var identifier: String
        var contract: String?
        var chainName: String
        var inAppName: String
        var fullName: String
        var isDefault: Bool
        var isDefaultSelected: Bool
        var isActive: Bool
        var iconUrlStr: String
        var digit: Int
        var walletMainCoinID: String
    }
    
    let sources: [CoinSource]
    init(json: JSON, sourceAPI: API) throws {
        guard let coinJSONs = json.array else {
            throw GTServerAPIError.noData
        }
        
        let _sources = coinJSONs.compactMap {
            coinJSON -> CoinSource? in
            guard
                //                let chainTypeRaw = coinJSON["walletType"].int16,
                let chainTypeRaw = coinJSON["chainType"].int16,
                let chainType = ChainType.init(rawValue: chainTypeRaw),
                let identifier = coinJSON["identifier"].string,
                let chainName = coinJSON["chainName"].string,
                let displayName = coinJSON["displayName"].string,
                //                let chainName = coinJSON["name"].string,
                //                let displayName = coinJSON["name"].string,
                let fullname = coinJSON["fullName"].string,
                let iconURLStr = coinJSON["icon"].string,
                let isDefault = coinJSON["isDefault"].bool,
                let isDefaultSelected = coinJSON["isDefaultSelected"].bool,
                let isActive = coinJSON["isActive"].bool,
                //FIXME:
                let mainCoinID = coinJSON["mainCoinID"].string
                else {
                    return errorDebug(response: nil)
            }
            
            //FIXME:
            //            let mainCoinID: String
            //            switch chainType {
            //            case .btc: mainCoinID = Coin.btc_identifier
            //            case .eth: mainCoinID = Coin.eth_identifier
            //            case .cic: mainCoinID = Coin.cic_identifier
            //            }
            
            let contract: String? = coinJSON["contract"].string
            let digit = coinJSON["digit"].int ?? 18
            return CoinSource(chainType: chainType,
                              identifier: identifier,
                              contract: contract,
                              chainName: chainName,
                              inAppName: displayName,
                              fullName: fullname,
                              isDefault: isDefault,
                              isDefaultSelected: isDefaultSelected,
                              isActive: isActive,
                              iconUrlStr: iconURLStr,
                              digit: digit,
                              walletMainCoinID: mainCoinID)
        }
        
        sources = _sources
    }
}

//MARK: - GET /coins
struct CoinsTestAPI: KLMoyaLangAPIData {
    var path: String { return "/topChain/coinTest" }
    var method: Moya.Method { return .get }
    
    let query: String?
    let defaultOnly: Bool
    let chainType: ChainType?
    let mainCoinID: String?
    
    var base: APIBaseEndPointType {
        let url = URL.init(string: "http://125.227.132.127:3206")!
        return .custom(url: url)
    }
    
    var task: Task {
        var params: [String : Any] = [
            "defaultOnly" : defaultOnly
        ]
        
        if let q = query {
            params["queryString"] = q
        }
        
        if let type = chainType {
            params["chainType"] = type.rawValue
        }
        
        if let mainCoinID = mainCoinID {
            params["mainCoinID"] = mainCoinID
        }
        
        return Moya.Task.requestParameters(
            parameters: params,
            encoding: URLEncoding.init(destination: URLEncoding.Destination.queryString, arrayEncoding: URLEncoding.ArrayEncoding.brackets, boolEncoding: URLEncoding.BoolEncoding.literal
            )
        )
    }
    
    var stub: Data? { return nil }
}

struct CoinsTestAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CoinsTestAPI
    let sources: [CoinsAPIModel.CoinSource]
    init(json: JSON, sourceAPI: API) throws {
        guard let coinJSONs = json.array else {
            throw GTServerAPIError.noData
        }
        
        let _sources = coinJSONs.compactMap {
            coinJSON -> CoinsAPIModel.CoinSource? in
            guard
                //                let chainTypeRaw = coinJSON["walletType"].int16,
                let chainTypeRaw = coinJSON["chainType"].int16,
                let chainType = ChainType.init(rawValue: chainTypeRaw),
                let identifier = coinJSON["identifier"].string,
                let chainName = coinJSON["chainName"].string,
                let displayName = coinJSON["displayName"].string,
                //                let chainName = coinJSON["name"].string,
                //                let displayName = coinJSON["name"].string,
                let fullname = coinJSON["fullName"].string,
                let iconURLStr = coinJSON["icon"].string,
                let isDefault = coinJSON["isDefault"].bool,
                let isDefaultSelected = coinJSON["isDefaultSelected"].bool,
                let isActive = coinJSON["isActive"].bool,
                //FIXME:
                let mainCoinID = coinJSON["mainCoinID"].string
                else {
                    return nil
            }
            
            //FIXME:
            //            let mainCoinID: String
            //            switch chainType {
            //            case .btc: mainCoinID = Coin.btc_identifier
            //            case .eth: mainCoinID = Coin.eth_identifier
            //            case .cic: mainCoinID = Coin.cic_identifier
            //            }
            
            let contract: String? = coinJSON["contract"].string
            let digit = coinJSON["digit"].int ?? 18
            return CoinsAPIModel.CoinSource(chainType: chainType,
                                            identifier: identifier,
                                            contract: contract,
                                            chainName: chainName,
                                            inAppName: displayName,
                                            fullName: fullname,
                                            isDefault: isDefault,
                                            isDefaultSelected: isDefaultSelected,
                                            isActive: isActive,
                                            iconUrlStr: iconURLStr,
                                            digit: digit,
                                            walletMainCoinID: mainCoinID)
        }
        
        sources = _sources
    }
}



//MARK: - GET /Fiats
struct FiatsAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    var path: String { return "/Fiats" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
}

struct FiatsAPIModel: KLJSONMappableMoyaResponse {
    typealias API = FiatsAPI
    struct FiatSource {
        var id: Int16
        var name: String
        var symbol: String
    }
    
    let sources: [FiatSource]
    init(json: JSON, sourceAPI: API) throws {
        guard let fiatJsons = json.array else {
            throw GTServerAPIError.noData
        }
        
        let _sources = fiatJsons.compactMap { (fiatJSON) -> FiatSource? in
            guard let id = fiatJSON["id"].int16,
                let name = fiatJSON["name"].string,
                let symbol = fiatJSON["symbol"].string else {
                    return nil
            }
            
            return FiatSource(id: id, name: name, symbol: symbol)
        }
        
        sources = _sources
    }
}

//MARK: - GET /Fee/BTC
struct GetBTCFeeAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/Fee/BTC" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
}

struct GetBTCFeeAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetBTCFeeAPI
    
    let regularFee: Decimal
    let priorityFee: Decimal
    init(json: JSON, sourceAPI: API) throws {
        guard let regular = json["regular"].number?.decimalValue,
            let priority = json["priority"].number?.decimalValue else {
                throw GTServerAPIError.noData
        }
        //        #if DEBUG
        //        regularFee = Decimal.init(25).satoshiToBTC
        //        #else
        regularFee = regular
        //        #endif
        priorityFee = priority
    }
}

//MARK: - GET /Fee/ETH
struct GetETHFeeAPI: KLMoyaAPIData {
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/Fee/ETH" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
}

struct GetETHFeeAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetETHFeeAPI
    
    let suggestGasPrice: Decimal
    let minGasPrice: Decimal
    let maxGasPrice: Decimal
    
    init(json: JSON, sourceAPI: API) throws {
        guard let suggestGasPrice = json["suggestGasPrice"].number?.decimalValue,
            let minGasPrice = json["minGasPrice"].number?.decimalValue,
            let maxGasPrice = json["maxGasPrice"].number?.decimalValue else {
                throw GTServerAPIError.noData
        }
        
        self.suggestGasPrice = suggestGasPrice
        self.minGasPrice = minGasPrice
        self.maxGasPrice = maxGasPrice
    }
}

//MARK: - GET /Fee/CIC
struct GetCICFeeAPI: KLMoyaAPIData {
    let mainCoinID: String
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/Fee/CIC" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["mainCoinID" : mainCoinID],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetCICFeeAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetCICFeeAPI
    
    let suggestGasPrice: Decimal
    let minGasPrice: Decimal
    let maxGasPrice: Decimal
    
    init(json: JSON, sourceAPI: API) throws {
        //FIXME:
        guard let suggestGasPrice = json["suggestGasPrice"].number?.decimalValue,
            let minGasPrice = json["minGasPrice"].number?.decimalValue,
            let maxGasPrice = json["maxGasPrice"].number?.decimalValue else {
                throw GTServerAPIError.noData
        }
        
        guard let coin = Coin.getCoin(ofIdentifier: sourceAPI.mainCoinID) else {
            throw GTServerAPIError.noData
        }
        
        let digit = Int(coin.requiredDigit)
        self.suggestGasPrice = suggestGasPrice.power(digit * -1)
        self.minGasPrice = minGasPrice.power(digit * -1)
        self.maxGasPrice = maxGasPrice.power(digit * -1)
        
        //        self.suggestGasPrice = Decimal.init(0).power(digit * -1)
        //        self.minGasPrice = Decimal.init(0).cicUnitToCIC.power(digit * -1)
        //        self.maxGasPrice = Decimal.init(0).cicUnitToCIC.power(digit * -1)
    }
}

//MARK: - GET /Rate/LightningTransExchange
struct GetLightningTransRateAPI: KLMoyaAPIData {
    let fromCoin: Coin
    let toCoin: Coin
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/Rate/LightningTransExchange" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [
                "fromCoinID" : fromCoin.identifier!,
                "toCoinID" : toCoin.identifier!
            ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetLightningTransRateAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetLightningTransRateAPI
    let rate: Decimal
    init(json: JSON, sourceAPI: API) throws {
        guard let r = json.number?.decimalValue else {
            throw GTServerAPIError.noData
        }
        
        rate = r
    }
}

//MARK: - GET /Rate/CoinToUSD
struct GetCoinToUSDRateAPI: KLMoyaAPIData {
    let coin: Coin
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
    
    
    var path: String { return "/Rate/CoinToUSD" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "coinID" : coin.identifier! ],
            encoding: URLEncoding.default
        )
    }
    
    var stub: Data? { return nil }
}

struct GetCoinToUSDRateAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetCoinToUSDRateAPI
    let rate: Decimal
    init(json: JSON, sourceAPI: API) throws {
        guard let r = json.number?.decimalValue else {
            throw GTServerAPIError.noData
        }
        
        rate = r
    }
}

//MARK: - GET /Rate/fiatTable
struct FiatRateTableAPI: KLMoyaAPIData {
    var path: String { return "/Rate/fiatTable" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
}

struct FiatRateTableAPIModel: KLJSONMappableMoyaResponse {
    typealias API = FiatRateTableAPI
    //Source is [fiatID:Rate]
    typealias FiatRateTableSource = [Int16:Decimal]
    
    let source: FiatRateTableSource
    
    init(json: JSON, sourceAPI: API) throws {
        guard let rateJSONs = json.array else {
            throw GTServerAPIError.noData
        }
        
        let _source: FiatRateTableSource = rateJSONs.reduce([:]) { (result, rateJSON) -> FiatRateTableSource in
            guard let id = rateJSON["fiatId"].int16,
                let rate = rateJSON["toUSDRate"].number?.decimalValue else {
                    return result
            }
            
            var newResult = result
            newResult[id] = rate
            
            return newResult
        }
        
        source = _source
    }
}

//MARK: - GET /Version
struct GetVersionAPI: KLMoyaAPIData {
    var path: String { return "/topChain/versionTest" }
    var method: Moya.Method { return .get }
    
    var task: Task {
        return Moya.Task.requestPlain
    }
    
    var stub: Data? { return nil }
    
    var authNeeded: Bool { return false }
    
    var langDepended: Bool { return false }
}

struct GetVersionAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetVersionAPI
    let minimum: String
    let latest: String
    init(json: JSON, sourceAPI: API) throws {
        let iOSVersions = json["iOS"]
        guard let latest = iOSVersions["latest"].string,
            let minimum = iOSVersions["minimum"].string else {
                throw GTServerAPIError.noData
        }
        //        self.minimum = "1.0.1"
        self.minimum = minimum
        self.latest = latest
    }
}

