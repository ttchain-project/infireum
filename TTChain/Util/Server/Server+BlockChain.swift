 //
//  ServerAPIHandler.swift
//  ECommerce
//
//  Created by Keith Lee on 2017/2/13.
//  Copyright © 2017年 Keith Lee. All rights reserved.
//

//API errror response
let kGTAPIResponseOK : Int = 0
//let kGTAPIResponseInvalidToken: Int = 9005
//let kGTAPIResponseNeedRefreshToken: Int = 9007
//
//let kDefaultNationID: String = "1"
//let kDefaultSetCookie: String = "\(kDefaultNationID)"
//let kWDDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

import Foundation
import Moya
import SwiftyJSON
import RxSwift
import Alamofire

extension URLRequest {
    
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    public var cURL: String {
        
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
            else {
                return ""
        }
        
        var curlCommand = "curl \n"
        
        // URL
        curlCommand = curlCommand.appendingFormat(" '%@' \n", url.absoluteString)
        
        // Method if different from GET
        if "GET" != httpMethod {
            curlCommand = curlCommand.appendingFormat(" -X %@ \n", httpMethod)
        }
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys  = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \n", key, self.value(forHTTPHeaderField: key)!)
        }
        
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat(" --data '%@' \n", escapedHttpBody)
        }
        
        return curlCommand
    }
    
    /// Escapes all single quotes for shell from a given string.
    static func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}

//MARK: - Server (Define network request)

enum APIResult<Value> {
    case success(Value)
    case failed(error: GTServerAPIError)
}

typealias RxAPIResponse<E> = Single<APIResult<E>>
typealias RxAPIVoidResponse = Single<APIResult<Void>>
 
 class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 10 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 10 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
 }
 
/// Server is a class where defines all the api calls,
/// In the Offline Wallet, server sperate into two parts, first is from internal server, the other is from blockchain library.
class Server: MoyaProvider<Router> {
    class Logger: PluginType {
        func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
            let start = request.cURL.startIndex
            let end = request.cURL.index(start, offsetBy: min(request.cURL.count - 1, 999))
            let url = request.cURL.count > 1000 ? String(request.cURL[start...end]) : request.cURL
            line()
            print("prepare request url: \(url)")
            line(sepFront: false)
            return request
        }
    }
    
    static let instance = Server.init()
    
    required init() {
        super.init(manager: DefaultAlamofireManager.sharedManager,
                   plugins: [Logger.init()])
        
    }
    
    private func fire<Model: KLJSONMappableMoyaResponse>(
        router: Router,
        shouldEnsureVersionIsValid: Bool = true
        ) -> RxAPIResponse<Model> {
        let request: RxAPIResponse<Model> = self.rx
            .request(router)
            .process(to: Model.self,
                     withAPI: router.api.api as! Model.API)
            .share()
            .asSingle()
            .subscribeOn(
                ConcurrentDispatchQueueScheduler.init(qos: .default)
            )
            .observeOn(MainScheduler.asyncInstance)
        
        if shouldEnsureVersionIsValid {
            return VersionChecker.sharedInstance.checkVersionIfNeeded()
                .flatMap {
                    result in
                    switch result {
                    case .failed(error: _): break
                    case .success(let checkResult):
                        switch checkResult {
                        case .localVersionIsNewer, .localVersionIsSupported: break
                        case .localVersionIsTooOld:
                            return RxAPIResponse.just(
                                .failed(error: GTServerAPIError.invalidVerision)
                            )
                        }
                    }
                    
                    return request
            }
        }else {
            return request
        }
        
        
    }
    
    //MARK: - GET /Addressbook
    func getAddressbook(identity: Identity) -> RxAPIResponse<GetAddressBookAPIModel> {
        let api = GetAddressBookAPI.init(identity: identity)
        return fire(router: .helper(.getAddressBook(api)))
    }
    
    //MARK: - POST /Addressbook
    func createAddressBookUnit(
        identity: Identity,
        unitID: String,
        chainType: ChainType,
        mainCoinID: String,
        address: String,
        name: String,
        note: String?
        ) -> RxAPIResponse<CreateAddressBookUnitAPIModel> {
        let api = CreateAddressBookUnitAPI.init(
            identity: identity,
            id: unitID,
            chainType: chainType,
            mainCoinID: mainCoinID,
            address: address,
            name: name,
            note: note
        )
        
        return fire(router: .helper(.createAddressBookUnit(api)))
    }
    
    //MARK: - PUT /Addressbook
    func updateAddressBookUnit(
        identity: Identity,
        unitID: String,
        chainType: ChainType,
        mainCoinID: String,
        address: String,
        name: String,
        note: String?
        ) -> RxAPIResponse<UpdateAddressBookUnitAPIModel> {
        let api = UpdateAddressBookUnitAPI.init(
            identity: identity,
            id: unitID,
            chainType: chainType,
            mainCoinID: mainCoinID,
            address: address,
            name: name,
            note: note
        )
        return fire(router: .helper(.updateAddressBookUnit(api)))
    }
    
    //MARK: - Delete /Addressbook
    func deleteAddressBookUnit(
        identity: Identity,
        unitID: String,
        chainType: ChainType,
        mainCoinID: String
        ) -> RxAPIResponse<DeleteAddressBookUnitAPIModel> {
        let api = DeleteAddressBookUnitAPI.init(
            identity: identity,
            id: unitID,
            chainType: chainType,
            mainCoinID: mainCoinID
        )
        return fire(router: .helper(.deleteAddressBookUnit(api)))
    }
    
    //MARK: - GET /coins
    func getCoins(
        queryString: String?,
        chainType: ChainType?,
        defaultOnly: Bool,
        mainCoinID: String?
        ) -> RxAPIResponse<CoinsAPIModel> {
        let api = CoinsAPI.init(
            query: queryString,
            defaultOnly: defaultOnly,
            chainType: chainType,
            mainCoinID: mainCoinID
        )
        return fire(router: .helper(.getCoins(api)))
    }
    
    //MARK: - GET /Fiats
    func getFiats() -> RxAPIResponse<FiatsAPIModel> {
        let api = FiatsAPI()
        return fire(router: .helper(.getFiats(api)))
    }
    
    //MARK: - GET /Fee/BTC
    func getBTCFee() -> RxAPIResponse<GetBTCFeeAPIModel> {
        let api = GetBTCFeeAPI.init()
        return fire(router: .helper(.getBTCFee(api)))
    }
    
    //MARK: - GET /Fee/ETH
    func getETHFee() -> RxAPIResponse<GetETHFeeAPIModel> {
        let api = GetETHFeeAPI.init()
        return fire(router: .helper(.getETHFee(api)))
    }
    
    //MARK: - GET /Fee/CIC
    func getCICFee(mainCoinID: String) -> RxAPIResponse<GetCICFeeAPIModel> {
        let api = GetCICFeeAPI.init(mainCoinID: mainCoinID)
        return fire(router: .helper(.getCICFee(api)))
    }
    
    //MARK: - GET /Rate/LightningTransExchange
    func getLightningTransExchange(from: Coin, to: Coin) -> RxAPIResponse<GetLightningTransRateAPIModel> {
        let api = GetLightningTransRateAPI.init(fromCoin: from, toCoin: to)
        return fire(router: .helper(.getLightningTransRate(api)))
    }
    
    //MARK: - GET /Rate/CoinToUSD
    func getCoinToUSDRate(of coin: Coin) -> RxAPIResponse<GetCoinToUSDRateAPIModel> {
        let api = GetCoinToUSDRateAPI.init(coin: coin)
        return fire(router: .helper(.getCoinToUSDRate(api)))
    }
    
    //MARK: - GET /Rate/fiatTable
    func getFiatTable() -> RxAPIResponse<FiatRateTableAPIModel> {
        let api = FiatRateTableAPI()
        return fire(router: .helper(.getFiatRateTable(api)))
    }
    
    //MARK: - GET /Version
    func getVersion() -> RxAPIResponse<GetVersionAPIModel> {
        let api = GetVersionAPI.init()
        return fire(router: .helper(.getVersion(api)),
                    shouldEnsureVersionIsValid: false)
    }
}
 
// MARK: - Blockchain
extension Server {
    //MARK: - GET AssetAmt
    func getAssetAmt(ofAsset asset: Asset) -> RxAPIResponse<GetAssetAmtAPIModel> {
        let api = GetAssetAmtAPI.init(asset: asset)
        return fire(router: .blockchain(.getAssetAmt(api)))
    }
    
    //MARK: - POST /topChain/account
    func createAccount(defaultMnemonic: String?) -> RxAPIResponse<CreateAccountAPIModel> {
        let api = CreateAccountAPI.init(defaultMnemonic: defaultMnemonic)
        return fire(router: .blockchain(.createAccount(api)))
    }
    
    //MARK: - POST /topChain/keyToAddress
    func convertKeyToAddress(pKey: String) -> RxAPIResponse<KeyToAddressAPIModel> {
        let api = KeyToAddressAPI.init(pKey: pKey)
        return fire(router: .blockchain(.keyToAddress(api)))
    }
    
    //MARK: - GET https://blockexplorer.com/api/addr/{address}/utxo
    func getBTCUnspent(fromBTCAddress address: String, targetAmt: Decimal) -> RxAPIResponse<GetBTCUnspentAPIModel> {
        let api = GetBTCUnspentAPI.init(btcAddress: address, targetAmt: targetAmt)
        return fire(router: .blockchain(.getBTCUnspent(api)))
    }
    
    //MARK: - GET https://blockexplorer.com/api/status?q=getBlockCount
    func getBTCBlockHeight() -> RxAPIResponse<GetBTCCurrentBlockAPIModel> {
        let api = GetBTCCurrentBlockAPI.init()
        return fire(router: .blockchain(.getBTCurrentBlock(api)))
    }
    
    //MARK: - POST /topChain/newSignAll/{pKey}/{}
    func signBTCTx(pkey: String,
                   fromAddress: String,
                   toAddress: String,
                   tranferBTC: Decimal,
                   feeBTC: Decimal,
                   unspents: [Unspent]) -> RxAPIResponse<SignBTCTxAPIModel> {
        let api = SignBTCTxAPI.init(btcWalletPrivateKey: pkey,
                                    fromBTCAddress: fromAddress,
                                    toBTCAddress: toAddress,
                                    transferBTC: tranferBTC,
                                    feeBTC: feeBTC,
                                    unspents: unspents)
        return fire(router: .blockchain(.signBTCTx(api)))
    }
    
    //MARK: - POST https://blockexplorer.com/api/tx/send
    func broadcastBTCTx(withSignText signText: String, withComments comments:String) -> RxAPIResponse<BroadcastBTCTxAPIModel> {
        let api = BroadcastBTCTxAPI.init(signText: signText, comments: comments)
        return fire(router: .blockchain(.broadcastBTCTx(api)))
    }
    
    //MARK: - GET https://blockexplorer.com/api/addrs/[:addrs]/txs[?from=&to=]
    func getBTCRxRecords(ofAddress addr: String, from: Int, to: Int) -> RxAPIResponse<GetBTCTxRecordsAPIModel> {
        let api = GetBTCTxRecordsAPI.init(btcAddress: addr, from: from, to: to)
        return fire(router: .blockchain(.getBTCTxRecords(api)))
    }
    
    //MARK: - GET https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=YourApiKeyToken
    func getETHBlockHeight() -> RxAPIResponse<GetETHCurrentBlockAPIModel> {
        let api = GetETHCurrentBlockAPI.init()
        return fire(router: .blockchain(.getETHCurrentBlock(api)))
    }
    
    //MARK: - POST https://mainnet.infura.io
    func getETHNonce(ethAddress: String) -> RxAPIResponse<GetETHNonceAPIModel> {
        let api = GetETHNonceAPI.init(ethAddress: ethAddress)
        return fire(router: .blockchain(.getETHNonce(api)))
    }
    
    //MARK: POST /topChain/newSignAll/{pkey}/{params}
    func signETHTx(pkey: String,
                   nonce: Int,
                   gasPriceInWei: Decimal,
                   gasLimit: Int,
                   toETHAddress: String,
                   transferToken: Coin,
                   transferValueInTokenUnit: Decimal) -> RxAPIResponse<SignETHTxAPIModel> {
        let api = SignETHTxAPI.init(nonce: nonce,
                                    gasPriceInWei: gasPriceInWei,
                                    gasLimit: gasLimit,
                                    toETHAddress: toETHAddress,
                                    transferToken: transferToken,
                                    transferValueInToken: transferValueInTokenUnit,
                                    pKey: pkey)
        
        return fire(router: .blockchain(.signETHTx(api)))
    }
    
    //MARK: - POST /CustomComments -
    func fetchTransactionRemarks(for transactions:[String?]) -> RxAPIResponse<GetCustomCommentsAPIModel> {
        let api = GetCustomCommentsAPI.init(txIDs: transactions)
        return fire(router: .blockchain(.customComments(api)))
    }
    
    //MARK: - POST /CustomComments -
    func postCommentsForTransaction(for transactionId: String, comment: String?) -> RxAPIResponse<PostCustomCommentsAPIModel> {
        let api = PostCustomCommentsAPI.init(comment: comment, txID: transactionId)
        return fire(router: .blockchain(.postCustomComment(api)))
    }
    
    //MARK: - POST /topChain/HC_signInformationOut/{signText}
    func broadcastETH(signText: String, andComments comments: String) -> RxAPIResponse<BroadcastETHTxAPIModel> {
        let api = BroadcastETHTxAPI.init(signText: signText, comments: comments)
        return fire(router: .blockchain(.broadcastETHTx(api)))
    }
    
    //MARK: - GET https://api.etherscan.io/api?module=account&action=txlist&address=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae&startblock=0&endblock=99999999&sort=desc&apikey=YourApiKeyToken
    func getETHTxRecords(startBlock: Int,
                         endBlock: Int,
                         ethAddress: String) -> RxAPIResponse<GetETHTxRecordsAPIModel> {
        let api = GetETHTxRecordsAPI.init(startBlock: startBlock, endBlock: endBlock, ethAddress: ethAddress)
        return fire(router: .blockchain(.getETHTxRecords(api)))
    }
    
    
    //MARK: - GET https://api.etherscan.io/api?module=account&action=tokentx&contractaddress=0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2&address=0x4e83362442b8d1bec281594cea3050c8eb01311c&page=1&offset=100&sort=desc&apikey=YourApiKeyToken
    func getETHTokenTxRecords(startBlock: Int,
                              endBlock: Int,
                              ethAddress: String,
                              token: Coin?) -> RxAPIResponse<GetETHTokenTxRecordsAPIModel> {
        let api = GetETHTokenTxRecordsAPI.init(startBlock: startBlock, endBlock: endBlock, ethAddress: ethAddress, token: token)
        
        return fire(router: .blockchain(.getETHTokenTxRecords(api)))
    }
    
    //MARK: - 125.227.132.127:3206/topChain/newSignAll/54dee1a12baaccb5589e062aa59bf72b95f689d260665770073bc095cc7c7e7c/{}
    func lt_signBTCRelayTx(btcWalletPrivateKey: String,
                           fromBTCAddress: String,
                           toCICAddress: String,
                           unspents: [Unspent],
                           transferBTC: Decimal,
                           feeBTC: Decimal) -> RxAPIResponse<LTSignBTCRelayTxAPIModel> {
        let api = LTSignBTCRelayTxAPI.init(btcWalletPrivateKey: btcWalletPrivateKey,
                                           fromBTCAddress: fromBTCAddress,
                                           toCICAddress: toCICAddress,
                                           unspents: unspents,
                                           transferBTC: transferBTC,
                                           feeBTC: feeBTC)
        
        return fire(router: .blockchain(.lt_signBTCRelayTx(api)))
    }
    
    //MARK: - LT broadcast btc realy (same as btc braodcast)
    func lt_broadcastBTCRelayTx(withSignText signText: String, comments: String) -> RxAPIResponse<LTBroadcastBTCRelayTxAPIModel> {
        let api = LTBroadcastBTCRelayTxAPI.init(signText: signText,comments: comments)
        return fire(router: .blockchain(.lt_broadcastBTCRelayTx(api)))
    }
    
    //MARK: - GET CIC Nonce
    func getCICNonce(address: String, mainCoin: Coin) -> RxAPIResponse<GetCICNonceAPIModel> {
        let api = GetCICNonceAPI.init(address: address, mainCoin: mainCoin)
        return fire(router: .blockchain(.getCICNonce(api)))
    }
    
    //MARK: - http://125.227.132.127:3206/topChain/newSignAll/{cic private key}/{}
    func signCICTx(fromAsset: Asset,
                   transferAmt_smallestUnit: Decimal,
                   toAddress: String,
                   toAddressType: ChainType,
                   feeInCICSmallestUnit: Decimal,
                   nonce: Int) -> RxAPIResponse<SignCICTxAPIModel> {
        let api = SignCICTxAPI.init(fromAsset: fromAsset,
                                    transferAmt_smallestUnit: transferAmt_smallestUnit,
                                    toAddress: toAddress,
                                    toAddressType: toAddressType,
                                    feeInSmallestUnit: feeInCICSmallestUnit,
                                    nonce: nonce)
        
        return fire(router: .blockchain(.signCICTx(api)))
    }
    
    //MARK: - CIC Broadcast
    func broadcastCICTx(contentData: [String : Any], mainCoin: Coin) -> RxAPIResponse<BroadcastCICTxAPIModel> {
        let api = BroadcastCICTxAPI.init(contentData: contentData, mainCoin: mainCoin)
        return fire(router: .blockchain(.broadcastCICTx(api)))
    }
    
    //MARK: - Get CIC Tx
    func getCICTxRecords(ofAddress address: String, mainCoin: Coin) -> RxAPIResponse<GetCICTxRecordsAPIModel> {
        let api = GetCICTxRecordsAPI.init(address: address, mainCoin: mainCoin)
        return fire(router: .blockchain(.getCICTxRecords(api)))
    }
 }
 

 
