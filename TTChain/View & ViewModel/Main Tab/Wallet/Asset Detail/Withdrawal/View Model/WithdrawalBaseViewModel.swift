//
//  WithdrawalBaseViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalInfoValidator {
    enum Error {
        //This will be used when fee coin and transfer coin is same
        //Extra Fee cost is to determined if this error is caused by insiffcient transfer amt or extra fee. This will change the localization source
        case insufficientAsset(tranferAmt: Decimal, extraFeeCost: Decimal?, asset: Asset)
        case sameWalletAddresses
        //This will be used when fee coin and transfer coin is different
        case insuffientFee(minFee: Decimal, feeAsset: Asset)
        //Suggestion must be in unit amount. (e.g. gwei, sat/b, cic/b)
        case feeRateTooLow(suggestion: Decimal, feeCoin: Coin)
        //In case that any lost case happended
        case unknown(systemMsg: String)
        
        var localizedFailedDesciption: String {
            let dls = LM.dls
            switch self {
                
            case .sameWalletAddresses:
                return dls.withdrawal_error_same_address_content
            case .insufficientAsset(tranferAmt: let tAmt, extraFeeCost: let feeCost, asset: let asset):
                let assetAmt = asset.amount! as Decimal
                if tAmt > assetAmt {
                    return dls.withdrawal_error_asset_insuffient_content(
                        assetAmt.asString(digits: 8),
                        asset.coin!.inAppName!,
                        tAmt.asString(digits: 8),
                        asset.coin!.inAppName!
                    )
                    
                }else if let fee = feeCost, assetAmt < fee + tAmt {
                    let feeAmtStr = fee.asString(digits: 4)
                    let transAmtStr = tAmt.asString(digits: 4)
                    let assetAmtStr = assetAmt.asString(digits: 4)
                    let totalCostStr = (fee + tAmt).asString(digits: 4)
                    let coinName = asset.coin!.inAppName!
                    return dls
                        .withdrawal_error_asset_insuffient_for_same_asset_fee_content(
                            assetAmtStr,
                            asset.coin!.inAppName!,
                            transAmtStr,
                            feeAmtStr,
                            totalCostStr,
                            coinName
                        )
                }else {
                    return errorDebug(response: "")
                }
            case .insuffientFee(minFee: let fee, feeAsset: let asset):
                let assetAmt = asset.amount! as Decimal
                let coin = asset.coin!
                let digit = Int(coin.digit)
                return dls.withdrawal_error_fee_insufficient(
                    coin.inAppName!,
                    fee.asString(digits: digit),
                    coin.inAppName!,
                    assetAmt.asString(digits: digit),
                    coin.inAppName!
                )
                
            case .feeRateTooLow(suggestion: let feeRateSuggestion, feeCoin: let feeCoin):
                let feeRateName: String
                let feeUnitName: String
                switch feeCoin.identifier! {
                case Coin.cic_identifier:
                    feeRateName = dls.fee_cic_per_byte
                    feeUnitName = dls.fee_cic_per_byte
                case Coin.eth_identifier:
                    feeRateName = dls.fee_eth_gas_price
                    feeUnitName = dls.fee_eth_gwei
                case Coin.btc_identifier:
                    feeRateName = dls.fee_sat_per_byte
                    feeUnitName = dls.fee_sat_per_byte
                default:
                    //This should not happened
                    feeRateName = errorDebug(response: "手续费")
                    feeUnitName = errorDebug(response: "")
                }
                
                return dls.withdrawal_error_fee_rate_too_low(
                    feeRateName,
                    feeRateSuggestion.asString(digits: 0),
                    feeUnitName
                )
            case .unknown(let msg):
                return dls.withdrawal_error_unknown(msg)
            }
        }
    }
    
    enum Result {
        case success(WithdrawalInfo)
        case failed(WithdrawalInfoValidator.Error)
    }
    
    func validate(info: WithdrawalInfo) -> Result {
        return validate(
            asset: info.asset,
            transferAmt: info.withdrawalAmt,
            toAddress: info.address,
            note: info.note,
            feeInfo: (rate: info.feeRate,
                      amt: info.feeAmt,
                      coin: info.feeCoin,
                      option: info.feeOption)
        )
    }
    
    func validate(
        asset: Asset,
        transferAmt: Decimal,
        toAddress: String,
        note: String?,
        feeInfo: WithdrawalFeeInfoProvider.FeeInfo
        ) -> Result {
    
        let assetAmt = asset.amount! as Decimal
        let feeAmt = feeInfo.rate * feeInfo.amt
        let fromAddress = asset.wallet!.address!
        guard fromAddress != toAddress else {
            return .failed(.sameWalletAddresses)
        }
        
        guard assetAmt >= transferAmt else {
            return .failed(
                .insufficientAsset(
                    tranferAmt: transferAmt, extraFeeCost: feeAmt, asset: asset
                )
            )
        }
        
        //Diversed with asset coin to fee coin is same or not
        if feeInfo.coin.identifier! == asset.coinID! {
            guard assetAmt >= transferAmt + feeAmt else {
                return .failed(
                    .insufficientAsset(
                        tranferAmt: transferAmt, extraFeeCost: feeAmt, asset: asset
                    )
                )
            }
        }else {
            guard let assets = asset.wallet!.assets?.array as? [Asset] else {
                return .failed(.unknown(systemMsg: "No Assets in Wallet"))
            }
    
            guard let feeIdx = assets.index(where: { (asset) -> Bool in
                return asset.coinID! == feeInfo.coin.identifier!
            }) else {
                return .failed(.unknown(systemMsg: "No Matched Asset in Wallet"))
            }
            
            let feeAsset = assets[feeIdx]
            let feeAssetAmt = feeAsset.amount! as Decimal
            guard feeAssetAmt >= feeAmt else {
                return .failed(.insuffientFee(minFee: feeAmt, feeAsset: feeAsset))
            }
        }
        
        
        let feeUnitRate: Decimal
        let minFeeRate: Decimal
        switch feeInfo.coin.identifier! {
        case Coin.btc_identifier:
            feeUnitRate = feeInfo.rate.btcToSatoshi
            minFeeRate = FeeManager.getValue(fromOption: .btc(.regular))
        case Coin.eth_identifier:
            feeUnitRate = feeInfo.rate.etherToGWei
            minFeeRate = FeeManager.getValue(fromOption: .eth(.gasPrice(.systemMin)))
        default:
            let mainCoin = feeInfo.coin
            let digit = Int(mainCoin.digit)
            
            feeUnitRate = feeInfo.rate.power(digit)
            minFeeRate = FeeManager.getValue(fromOption: .cic(.gasPrice(.systemMin(mainCoinID: mainCoin.identifier!))))
        }
        
        guard feeUnitRate >= minFeeRate else {
            return .failed(
                .feeRateTooLow(suggestion: minFeeRate, feeCoin: feeInfo.coin)
            )
        }
        
        let info = WithdrawalInfo.init(
            asset: asset,
            withdrawalAmt: transferAmt,
            address: toAddress,
            feeRate: feeInfo.rate, feeAmt: feeInfo.amt,
            feeCoin: feeInfo.coin,
            feeOption: feeInfo.option,
            note: note
        )
        
        return .success(info)
    }
}

class WithdrawalInfo {
    var asset: Asset
    let withdrawalAmt: Decimal
    let address: String
    var wallet: Wallet {
        return asset.wallet!
    }
    var feeRate: Decimal
    var feeAmt: Decimal
    var feeCoin: Coin
    
    var totalFee: Decimal {
        return feeRate * feeAmt
    }
    
    var note:String?
    
    //Nil means fee is manually typed in.
    var feeOption: FeeManager.Option?
    
    init(
        asset: Asset,
        withdrawalAmt: Decimal,
        address: String,
        feeRate: Decimal,
        feeAmt: Decimal,
        feeCoin: Coin,
        feeOption: FeeManager.Option?,
        note: String?
        ) {
        self.asset = asset
        self.withdrawalAmt = withdrawalAmt
        self.address = address
        self.feeRate = feeRate
        self.feeAmt = feeAmt
        self.feeCoin = feeCoin
        self.feeOption = feeOption
        self.note = note
    }
}

class WithdrawalBaseViewModel: KLRxViewModel {
    struct Input {
        let asset: Asset
        let amtProvider: WithdrawalAssetInfoProvider
        let addressProvider: WithdrawalAddressInfoProvider
        let feeProvider: WithdrawalFeeInfoProvider
        let getWithdrawalResultInput: Driver<Void>
        let note : WithdrawalRemarkInfoProvider
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: WithdrawalBaseViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var isAbleToStartTransfer: Observable<Bool> {
        let hasAmtInfo = input.amtProvider.hasAmt
        let hasAddressInfo = input.addressProvider.hasValidInfo
        let hasFeeInfo = input.feeProvider.isFeeInfoCompleted
        return Observable.combineLatest(hasAmtInfo, hasAddressInfo, hasFeeInfo).map { $0 && $1 && $2 }
    }
    
    public var onStartConfirmWithdrawal: Driver<WithdrawalInfo> {
        return onStartValidate
            .filter {
                result -> Bool in
                switch result {
                case .success: return true
                default: return false
                }
            }
            .map {
                result in
                switch result {
                case .success(let info): return info
                case .failed: fatalError()
                }
            }
    }
    
    public var onFindingUnableToTransferResult: Driver<WithdrawalInfoValidator.Error> {
        return onStartValidate
            .filter {
                result -> Bool in
                switch result {
                case .success: return false
                case .failed: return true
                }
            }
            .map {
                result in
                switch result {
                case .success: fatalError()
                case .failed(let err): return err
                }
            }
    }
    
    //MARK: - Private
    //TODO: Shuold add an check logic, create a checker, and return invlalid result if so
    
    private lazy var onStartValidate: Driver<WithdrawalInfoValidator.Result> = {
        return input.getWithdrawalResultInput.map { [unowned self] in self.validateInfo() }
    }()
    
    private func validateInfo() -> WithdrawalInfoValidator.Result {
        //When calling this function, fee rate
        let asset = input.addressProvider.getFromAsset()
        let note = input.note.getRemarkNote()
        guard let amt = input.amtProvider.getTransferAmt(),
            let address = input.addressProvider.getToAddress(),
            let feeInfo = input.feeProvider.getFeeInfo() else {
                fatalError()
//                return nil
        }
        
        return WithdrawalInfoValidator().validate(
            asset: asset,
            transferAmt: amt,
            toAddress: address,
            note: note,
            feeInfo: feeInfo
        )
    }
}
