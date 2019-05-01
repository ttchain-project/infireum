 //
//  OWQRCodeParser.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

/// OWQRCodeParser:
/// Support system-defined qrCode content encode/decode logic
class OWQRCodeEncoder {
    enum EncodingSource {
        case deposit(asset: Asset)
    }
    
    func encodeContent(option: EncodingSource) -> String {
        switch option {
        case .deposit(asset: let asset):
//            let dictionary: [String : String] = [
//                "address" : asset.wallet!.address!,
//                "coinID" : asset.coinID!
//            ]
            var encodedString:String = ""
            switch asset.coin?.owChainType {
            case .btc? :
                encodedString = "bitcoin:" + asset.wallet!.address! + "?amount="
            case .eth?:
                encodedString = "ethereum:" + asset.wallet!.address! + "?"
                if asset.coin?.identifier != Coin.eth_identifier {
                    encodedString = encodedString + "contractAddress=" + (asset.coin!.contract!) + "&"
                }
                encodedString = encodedString +  "decimal=18&value=0"

            default:
                return asset.wallet?.address ?? ""
            }
            
            return encodedString
        }
    }
    
    
}


class OWQRCodeDecoder {
    var validator: OWStringValidator
    
    init(validator: OWStringValidator) {
        self.validator = validator
    }
    
    var currentValidatingTypes: [OWStringValidator.ValidationSourceType] {
        return validator.sourceTypes
    }
    
    func updateValidateTypes(_ types: [OWStringValidator.ValidationSourceType]) {
        validator.sourceTypes = types
    }
    
    typealias DecodingResult = OWStringValidator.ValidationResultType
    func decodeContent(raw: String) -> Single<DecodingResult> {
        var validateFlow: Single<OWStringValidator.ValidationResultType>
        
        if let data = raw.data(using: .utf8),
            let json = try? JSON.init(data: data),
            json.string != nil {
             if let address = json["address"].string {
                
                validateFlow = validator.validate(source: address)
                
                if let coinID = json["coinID"].string,
                    let coin = Coin.getCoin(ofIdentifier: coinID) {
                    validateFlow = validateFlow.map {
                        result in
                        switch result {
                        case .address(let addr, chainType: let type, coin: _, amt: let amt):
                            return .address(addr, chainType: type, coin: coin, amt: amt)
                        default: return result
                        }
                    }
                }
                
            }else {
                validateFlow = validator.validate(source: raw)
            }
        } else if raw.hasPrefix("bitcoin:") {
            guard let address = raw.slice(from: "bitcoin:", to: "?") else {
                return validator.validate(source: raw)
            }
            validateFlow = validator.validate(source: address)
            validateFlow = validateFlow.map {
                result in
                switch result {
                case .address(let addr, chainType: let type, coin: _, amt: let amt):
                    return .address(addr, chainType: type, coin: nil, amt: amt)
                default: return result
                }
            }
            
        }else if raw.hasPrefix("ethereum:") {
            guard let address = raw.slice(from: "ethereum:", to: "?") else {
                return validator.validate(source: raw)
            }
            validateFlow = validator.validate(source: address)
            validateFlow = validateFlow.map {
                result in
                switch result {
                case .address(let addr, chainType: let type, coin: _, amt: let amt):
                    return .address(addr, chainType: type, coin: nil, amt: amt)
                default: return result
                }
            }
        }
        else {
            validateFlow = validator.validate(source: raw)
        }
        
        return validateFlow
    }
    
//    func combineJSONsToSingleJSON(jsonString: [String]) -> [String:Any]? {
//
//        if let data = jsonString[0].data(using: .utf8),
//            let json = try? JSON.init(data: data),
//            json.dictionary != nil {
//            var updatedJson = json
//            jsonString.dropFirst().forEach { jsonRaw in
//                if let jsonData = jsonRaw.data(using: .utf8),
//                    let jsonFromData = try? JSON.init(data: jsonData),
//                    jsonFromData.dictionary != nil {
//                    if let walletsArray = jsonFromData.dictionary?["content"]?["system"]["wallets"], walletsArray.count > 0 {
//                        var existingWallets = updatedJson.dictionary
////                        existingWallets.append(walletsArray)
//                    }
//                }
//
//            }
//
//        }
//
//        return [:]
//    }
}

 
 extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
 }
