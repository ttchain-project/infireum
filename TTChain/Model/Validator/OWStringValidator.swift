//
//  OWStringValidator.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/19.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWStringValidator {
    enum ValidationSourceType {
        case withdrawal(id: String?)
        case addressBook(id: String?)
        case mnemonic(id: String?)
        case privateKey(id: String?)
        case identityQRCode
        case userId
    }
    
    enum ValidationResultType {
        struct AddressInfo {
            let address: String
            let mainCoin: Coin
        }
        
        case address(String, chainType: ChainType, coin: Coin?, amt: Decimal?)
        case mnemonic(String)
        case privateKey(String, possibleAddresssesInfo: [AddressInfo])
        case identityQRCode(rawContent: String)
        case unsupported(String)
        case userId(String)
    }
    
    //    static let instance = OWStringValidator.init(
    //        sourceTypes: [.withdrawal(type: nil)]
    //    )
    
    public var pKeyConvertStopper: Observable<Void> {
        return _pKeyConvertStopper.asObservable()
    }
    
    private lazy var _pKeyConvertStopper: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    var sourceTypes: [ValidationSourceType]
    init(sourceTypes: [ValidationSourceType]) {
        self.sourceTypes = sourceTypes
    }
    
    func validate(source: String) -> Single<ValidationResultType> {
        guard !sourceTypes.isEmpty else {
            return Single.just(.unsupported(source))
        }
        
        var _sourceTypes = sourceTypes
        
        print("prepare to validate sources: \(_sourceTypes)")
        //Loop the sources and return as the first match found.
        var result: Single<ValidationResultType> = validate(
            source: source, sourceType: _sourceTypes.removeFirst()
        )
        
        //In-order flatMap all the validate source sequence into one sequence, and pass the first valid result.
        for _sourceType in _sourceTypes {
            result = result.flatMap {
                [unowned self]
                res -> Single<ValidationResultType>  in
                switch res {
                case .unsupported: return self.validate(source: source, sourceType: _sourceType)
                default: return Single.just(res)
                }
            }
        }
        
        return result
    }
    
    private func validate(source: String, sourceType: ValidationSourceType) -> Single<ValidationResultType> {
        let result: Single<ValidationResultType>
        switch sourceType {
        case .withdrawal(id: let id):
            result = attemptMatchingAddressResultType(from: source, mainCoinID: id)
        case .addressBook(id: let id):
            result = attemptMatchingAddressResultType(from: source, mainCoinID: id)
        case .mnemonic:
            result = attemptMatchingMnemonicResultType(from: source)
        case .privateKey:
            result = attemptMatchingPrivateKeyType(from: source)
        case .identityQRCode:
            result = attemptMatchingIdentityQRCodeType(from: source)
        case .userId:
            result = attemptMatchingUserIdQRCodeType(from: source)
        }
        
        return result
    }
}

// MARK: - General
extension OWStringValidator {
    fileprivate func isMatchRegex(source: String, regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression.init(pattern: regex, options: .caseInsensitive)
            let matches = regex.matches(in: source, options: [], range: NSRange(source.startIndex..., in: source))
            return matches.count == 1
        }catch {
            return false
        }
    }
    
    fileprivate func attemptMatchingAddressResultType(
        from source: String, mainCoinID: String?
        ) -> Single<ValidationResultType> {
        if let _mainCoinID = mainCoinID,
            let coin = Coin.getCoin(ofIdentifier: _mainCoinID) {
            let _chainType = coin.owChainType
            switch _chainType {
            case .btc:
                return isSourceBTCAddress(source)
                    .map {
                        result in
                        if result {
                            return .address(source, chainType: .btc, coin: Coin.btc, amt: nil)
                        }else {
                            return .unsupported(source)
                        }
                }
            case .eth:
                return isSourceETHAddress(source)
                    .map {
                        result in
                        if result {
                            return .address(source, chainType: .eth, coin: Coin.eth, amt: nil)
                        }else {
                            return .unsupported(source)
                        }
                }
            case .cic:
                let _regex = regex(forMainCoinID: _mainCoinID)
                let mainCoin = Coin.getCoin(ofIdentifier: _mainCoinID)
                return isSourceCICChainTypeAddress(source, regex: _regex, mainCoin: mainCoin)
                    .map {
                        resultCoin in
                        if let coin = resultCoin {
                            return .address(source, chainType: .cic, coin: coin, amt: nil)
                        }else {
                            return .unsupported(source)
                        }
                }
            }
        }else {
            //Non-specific type detection
            let btcCheck: Single<ValidationResultType> = isSourceBTCAddress(source).map {
                $0 ? .address(source, chainType: .btc, coin: Coin.btc, amt: nil) : .unsupported(source)
            }
            
            let ethCheck: Single<ValidationResultType> = isSourceETHAddress(source).map {
                $0 ? .address(source, chainType: .eth, coin: Coin.eth, amt: nil) : .unsupported(source)
            }
            
            let cicCheck: Single<ValidationResultType> = isSourceAnyCICChainTypeAddress(source).map {
                resultCoin in
                if let _coin = resultCoin {
                    return .address(source, chainType: .cic, coin: _coin, amt: nil)
                }else {
                    return .unsupported(source)
                }
            }
            
            return btcCheck
                .flatMap {
                    result -> Single<ValidationResultType> in
                    switch result {
                    case .unsupported: return ethCheck
                    default: return Single.just(result)
                    }
                }
                .flatMap {
                    result -> Single<ValidationResultType> in
                    switch result {
                    case .unsupported: return cicCheck
                    default: return Single.just(result)
                    }
            }
        }
    }
    
    fileprivate func attemptMatchingMnemonicResultType(from source: String) -> Single<ValidationResultType> {
        return isSourceMnemonic(source).map { $0 ? .mnemonic(source) : .unsupported(source) }
    }
    
    fileprivate func attemptMatchingPrivateKeyType(from source: String) -> Single<ValidationResultType> {
        return isSourcePrivateKey(source)
    }
    
    fileprivate func attemptMatchingIdentityQRCodeType(from source: String) -> Single<ValidationResultType> {
        if IdentityQRCodeContent
            .isSourceHasValidIdentityQRCodeFormat(source) {
            return .just(.identityQRCode(rawContent: source))
        }else {
            return .just(.unsupported(source))
        }
    }
    
    fileprivate func attemptMatchingUserIdQRCodeType(from source: String) -> Single<ValidationResultType> {
        return Single.just(ValidationResultType.userId(source))
    }
}

// MARK: - BTC Checker
extension OWStringValidator {
    func isSourceBTCAddress(_ source: String) -> Single<Bool> {
        let btcRegex = "^[1-9A-HJ-NP-Za-km-z]{26,}$"
        return Single.just(isMatchRegex(source: source, regex: btcRegex))
    }
}

// MARK: - ETH Checker
extension OWStringValidator {
    func isSourceETHAddress(_ source: String) -> Single<Bool> {
        let basicETHRegex = "^0x[a-fA-F0-9]{40}$"
        return Single.just(isMatchRegex(source: source, regex: basicETHRegex))
    }
}

// MARK: - CIC Checker
extension OWStringValidator {
    func regex(forMainCoinID id: String) -> String {
        //This is a temporary solution as in future the regex should be from API to make it dynamic.
        if id == Coin.cic_identifier {
            return "^cx[a-fA-F0-9]{40}$"
        }else if id == Coin.guc_identifier {
            return "^gx[a-fA-F0-9]{40}$"
        }
//        else if id == Coin.bnn_identifier {
//            return "^bnn[a-fA-F0-9]{40}$"
//        }else if id == Coin.cfp_identifier {
//            return "^cf[a-fA-F0-9]{40}$"
//        }
        else {
            //If system cannot tell the main coin, use this regex as default format.
            return "^[a-zA-Z0-9]{40,}$"
        }
    }
    
    func isSourceAnyCICChainTypeAddress(_ source: String) -> Single<Coin?> {
        var mainCoins = MainCoinTypStorage.supportMainCoins
        guard !mainCoins.isEmpty else { return .just(nil) }
        let firstCoin = mainCoins.removeFirst()
        let firstRegex = regex(forMainCoinID: firstCoin.identifier!)
        
        var match = isSourceCICChainTypeAddress(
            source, regex: firstRegex, mainCoin: firstCoin
        )
        
        for restMainCoin in mainCoins {
            match = match.flatMap {
                [unowned self]
                coin in
                if let c = coin {
                    return .just(c)
                }else {
                    let _regex = self.regex(forMainCoinID: restMainCoin.identifier!)
                    return self.isSourceCICChainTypeAddress(source, regex: _regex, mainCoin: restMainCoin)
                }
            }
        }
        
        return match
    }
    
    //return element is mainCoin
    func isSourceCICChainTypeAddress(_ source: String, regex: String, mainCoin: Coin?) -> Single<Coin?> {
        let _isMatchRegex = isMatchRegex(source: source, regex: regex)
        let resultCoin = _isMatchRegex ? mainCoin : nil
        return Single.just(resultCoin)
    }
}


// MARK: - Mnemonic Checker
extension OWStringValidator {
    func isSourceMnemonic(_ source: String) -> Single<Bool> {
        switch source.ow_isValidMnemonic {
        case .incorrectFormat: return Single.just(false)
        case .valid: return Single.just(true)
        }
    }
}

// MARK: - PrivateKey Checker
extension OWStringValidator {
    func isSourcePrivateKey(_ source: String) -> Single<ValidationResultType> {
        return Server.instance.convertKeyToAddress(pKey: source,encrypted: true)
            .map {
                result in
                switch result {
                case .failed: return .unsupported(source)
                case .success(let model):
                    let infos: [ValidationResultType.AddressInfo] =
                        model.addressMap.compactMap {
                            (k, v) in
                            guard let c = Coin.getCoin(ofIdentifier: k) else {
                                return nil
                            }
                            
                            return .init(address: v, mainCoin: c)
                    }
                    
                    guard !infos.isEmpty else { return .unsupported(source) }
                    return ValidationResultType.privateKey(
                        source,
                        possibleAddresssesInfo: infos
                    )
                }
        }
    }
}
