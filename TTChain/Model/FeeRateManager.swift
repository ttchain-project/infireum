//
//  FeeRateManager.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FeeFinalOption {
    var localKey: String { get }
    var value: Decimal { get }
    func update(value: Decimal)
}

extension FeeFinalOption {
    var value: Decimal {
        return UserDefaults.standard.double(forKey: localKey).decimalValue
    }
    
    func update(value: Decimal) {
        let doubleValue = value.doubleValue
        UserDefaults.standard.setValue(doubleValue, forKey: localKey)
    }
}

class FeeManager {
    enum Option: FeeFinalOption {
        var localKey: String {
            switch self {
            case .btc(let option): return option.localKey
            case .eth(let option): return option.localKey
            case .cic(let option): return option.localKey + "_" + option.mainCoinID
                
            case .ttn(let option):
                return option.localKey
            }
        }
        
        enum BTCOption: FeeFinalOption {
            var localKey: String {
                switch self {
                case .regular: return FeeManager.key_btc_regular
                case .priority: return FeeManager.key_btc_priority
                }
            }
            
            case regular
            case priority
        }
        
        enum CICOption: FeeFinalOption {
            enum GasPriceOption: FeeFinalOption {
                var localKey: String {
                    switch self {
                    case .suggest: return FeeManager.key_cic_suggest_gasPrice
                    case .systemMax: return FeeManager.key_cic_systemMax_gasPrice
                    case .systemMin: return FeeManager.key_cic_systemMin_gasPrice
                    }
                }
                
                
                var mainCoinID: String {
                    switch self {
                        case .suggest(mainCoinID: let id),
                             .systemMax(mainCoinID: let id),
                             .systemMin(mainCoinID: let id):
                        return id
                    }
                }
                
                case suggest(mainCoinID: String)
                case systemMax(mainCoinID: String)
                case systemMin(mainCoinID: String)
            }
            
            case gasPrice(GasPriceOption)
            case gas(mainCoinID: String)
            
            var mainCoinID: String {
                switch self {
                case .gas(mainCoinID: let id): return id
                case .gasPrice(let option): return option.mainCoinID
                }
            }
            
            var localKey: String {
                switch self {
                case .gasPrice(let option): return option.localKey
                case .gas: return FeeManager.key_cic_suggest_gas
                }
            }
        }
        
        enum ETHOption: FeeFinalOption {
            enum GasPriceOption: FeeFinalOption {
                var localKey: String {
                    switch self {
                    case .suggest: return FeeManager.key_eth_suggest_gasPrice
                    case .systemMax: return FeeManager.key_eth_systemMax_gasPrice
                    case .systemMin: return FeeManager.key_eth_systemMin_gasPrice
                    }
                }
                
                case suggest
                case systemMax
                case systemMin
            }
            
            case gasPrice(GasPriceOption)
            case gas
            
            var localKey: String {
                switch self {
                case .gasPrice(let option): return option.localKey
                case .gas: return FeeManager.key_eth_suggest_gas
                }
            }
        }
        
        enum TTNOption:FeeFinalOption {
            var localKey: String {
                switch self {
                case .systemDefault: return FeeManager.key_ttn_system_fee
                case .btcnWithdrawal: return FeeManager.key_ttn_btcn_withdrawal_fee
                }
            }
            
            case systemDefault
            case btcnWithdrawal
        }
        case btc(BTCOption)
        case cic(CICOption)
        case eth(ETHOption)
        case ttn(TTNOption)
    }
    

    private static let key_fee_config_flag: String = "key_fee_config_flag"
    
    private static let key_btc_regular: String = "key_btc_regular"
    private static let key_btc_priority: String = "key_btc_priority"
    
    private static let key_cic_suggest_gasPrice: String = "key_cic_suggest_gasPrice"
    private static let key_cic_systemMax_gasPrice: String = "key_cic_systemMax_gasPrice"
    private static let key_cic_systemMin_gasPrice: String = "key_cic_systemMin_gasPrice"
    private static let key_cic_suggest_gas: String = "key_cic_suggest_gas"
    
    private static let key_eth_suggest_gasPrice: String = "key_eth_suggest_gasPrice"
    private static let key_eth_systemMax_gasPrice: String = "key_eth_systemMax_gasPrice"
    private static let key_eth_systemMin_gasPrice: String = "key_eth_systemMin_gasPrice"
    private static let key_eth_suggest_gas: String = "key_eth_suggest_gas"
    
    private static let key_ttn_system_fee:String = "key_ttn_system_fee"
    private static let key_ttn_btcn_withdrawal_fee:String = "key_ttn_btcn_withdrawal_fee"

    static func getValue(fromOption option: Option) -> Decimal {
        return option.value
    }
    
    //Will check if the value has been set or not, if so, skip, otherwise, set the value.
    static func setValueIfHasNotSetBefore(_ value: Decimal, forOption option: Option) {
        let currentValue = getValue(fromOption: option)
        if currentValue.isNaN || currentValue == 0 {
            option.update(value: value)
        }
    }
    
    static func setValue(_ value: Decimal, forOption option: Option) {
        option.update(value: value)
    }
    
    static func configIfNeeded() {
        
        //Sat/b

        setValueIfHasNotSetBefore(C.BTCFee.regular, forOption: .btc(.regular))
        setValueIfHasNotSetBefore(C.BTCFee.priority, forOption: .btc(.priority))
        
        
        //GWei
        setValueIfHasNotSetBefore(25, forOption: .eth(.gasPrice(.suggest)))
        setValueIfHasNotSetBefore(10, forOption: .eth(.gasPrice(.systemMin)))
        setValueIfHasNotSetBefore(100, forOption: .eth(.gasPrice(.systemMax)))
        setValueIfHasNotSetBefore(120000, forOption: .eth(.gas))
        
        setValueIfHasNotSetBefore(0.001, forOption: .ttn(.systemDefault))
        setValueIfHasNotSetBefore(0.00020546, forOption: .ttn(.btcnWithdrawal))
        //TODO: Rate need to be determined
        //CIC Unit
        
        let setupDefaultCICChangeCoin:
            (Decimal, Decimal, Decimal, Decimal, String) -> Void = {
                suggest, min, max, gas, mainCoinID in
                setValueIfHasNotSetBefore(suggest, forOption: .cic(.gasPrice(.suggest(mainCoinID: mainCoinID)))
                )
                
                setValueIfHasNotSetBefore(min, forOption: .cic(.gasPrice(.systemMin(mainCoinID: mainCoinID))))
                
                setValueIfHasNotSetBefore(max, forOption: .cic(.gasPrice(.systemMax(mainCoinID: mainCoinID))))
                
                setValueIfHasNotSetBefore(gas, forOption: .cic(.gas(mainCoinID: mainCoinID)))
        }
        
        
        let cicID = Coin.cic_identifier
        setupDefaultCICChangeCoin(0, 0, 0, 100000, cicID)
        let gucID = Coin.guc_identifier
        setupDefaultCICChangeCoin(0, 0, 0, 100000, gucID)
        //            UserDefaults.standard.set(true, forKey: key_fee_config_flag)

        UserDefaults.standard.synchronize()
//        print(UserDefaults.standard.dictionaryRepresentation())
    }
    
    //MARK: - API Request (Server)
    static func updateBTCFeeRates() -> RxAPIVoidResponse {
        return RxAPIVoidResponse.create { (event) -> Disposable in
            
            self.setValue(C.BTCFee.regular, forOption: .btc(.regular))
            self.setValue(C.BTCFee.priority, forOption: .btc(.priority))
            event(.success(APIResult.success(())))
            return Disposables.create()
        }
//        return Server.instance.getBTCFee()
//            .map {
//                result in
//                switch result {
//                case .failed(error: let err):
//                    return RxAPIVoidResponse.ElementType.failed(error: err)
//                case .success(let model):
//                    self.setValue(model.regularFee.btcToSatoshi, forOption: .btc(.regular))
//                    self.setValue(model.priorityFee.btcToSatoshi, forOption: .btc(.priority))
//                    return RxAPIVoidResponse.ElementType.success(())
//                }
//        }
        
//        let mockResponse: (Decimal, Decimal) = (35, 45)
//        return Observable.just(mockResponse).map {
//            res -> RxAPIVoidResponse.E in
//            self.setValue(res.0, forOption: .btc(.regular))
//            self.setValue(res.1, forOption: .btc(.priority))
//            return RxAPIVoidResponse.E.success(())
//        }.asSingle()
    }
    
    static func updateCICFeeRates(mainCoinID: String) -> RxAPIVoidResponse {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        let digit = Int(coin.digit)
        return Server.instance.getCICFee(mainCoinID: mainCoinID)
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let model):
                    self.setValue(
                        model.maxGasPrice.power(digit),
                        forOption: .cic(
                            .gasPrice(
                                .systemMax(
                                    mainCoinID: mainCoinID
                                )
                            )
                        )
                    )
                    
                    self.setValue(
                        model.minGasPrice.power(digit),
                        forOption: .cic(
                            .gasPrice(
                                .systemMin(
                                    mainCoinID: mainCoinID
                                )
                            )
                        )
                    )
                    self.setValue(
                        model.suggestGasPrice.power(digit),
                        forOption: .cic(
                            .gasPrice(
                                .suggest(
                                    mainCoinID: mainCoinID
                                )
                            )
                        )
                    )
                    
                    return RxAPIVoidResponse.ElementType.success(())
                }
        }
        
//        //TODO: Fire API
//        let mockResponse: (Decimal, Decimal) = (35, 45)
//        return Observable.just(mockResponse).map {
//            res -> RxAPIVoidResponse.E in
//            self.setValue(res.0, forOption: .cic(.regular))
//            self.setValue(res.1, forOption: .cic(.priority))
//            return RxAPIVoidResponse.E.success(())
//            }.asSingle()
    }
    
    static func updateETHFeeRates() -> RxAPIVoidResponse {
        return Server.instance.getETHFee()
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let model):
                    self.setValue(model.maxGasPrice, forOption: .eth(.gasPrice(.systemMax)))
                    self.setValue(model.minGasPrice, forOption: .eth(.gasPrice(.systemMin)))
                    self.setValue(model.suggestGasPrice, forOption: .eth(.gasPrice(.suggest)))
                    return RxAPIVoidResponse.ElementType.success(())
                }
            }
    }
    
    //TODO: Need to fixed this amt tp a calculation
    static var systemDefaultCICFeeAmt: Decimal { return 21000 }
    static var systemDefaultBTCFeeAmt: Decimal { return 21000 }
}

//MARK: Some helpful extension
extension Decimal {
    func power(_ exponent: Int) -> Decimal {
        if exponent >= 0 {
            return self * pow(10, exponent)
        }else {
            return self / pow(10, abs(exponent))
        }
    }
    
    var weiToEther: Decimal {
        return gweiToEther.gweiToEther
    }
    
    var etherToWei: Decimal {
        return etherToGWei.etherToGWei
    }
    
    var etherToGWei: Decimal {
        return power(9)
//        return self * pow(Double(10), 9).decimalValue
    }
    
    var gweiToEther: Decimal {
        return power(-9)
//        return self * pow(Double(10), -9).decimalValue
    }
    
    var cicToCICUnit: Decimal {
        return power(9)
//        return self * pow(Double(10), 9).decimalValue
    }
    
    var cicUnitToCIC: Decimal {
        return power(-9)
//        return self * pow(Double(10), -9).decimalValue
    }
    
    var btcToSatoshi: Decimal {
        return power(8)
//        return self * pow(Double(10), 8).decimalValue
    }
    
    var satoshiToBTC: Decimal {
        return power(-8)
//        return self * pow(Double(10), -8).decimalValue
    }
    var ttnUnitToTTn:Decimal {
        return power(-18)
    }
}

