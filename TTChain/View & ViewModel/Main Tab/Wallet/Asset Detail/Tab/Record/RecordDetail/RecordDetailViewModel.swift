//
//  RecordDetailViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/20.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class RecordDetailViewModel:KLRxViewModel {
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag()
    struct Input {
        let record:TransRecord
        let asset:Asset
    }
    
    private let asset : Asset
    private let record: TransRecord
    
    var input: RecordDetailViewModel.Input
    var output: Void
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.record = input.record
        self.asset = input.asset
        
    }
    
    func concatInput() {}
    func concatOutput() {}
    
    var txStatusImage : UIImage {
        let image:UIImage = {
            switch input.record.owStatus {
            case .failed:
                return #imageLiteral(resourceName: "wallet_receipt_failure")
            case .success:
                return #imageLiteral(resourceName: "wallet_receipt_success")
            }
        }()
        return image
    }
    
    var txStatusStr:String {
        let str:String = {
            switch input.record.owStatus {
            case .failed:
                return LM.dls.trans_failed
            case .success:
                return LM.dls.trans_success
            }
        }()
        return str
    }
    
    lazy var txDate:String = {
        let format = "MM/dd/yyyy HH:mm:ss"
        return DateFormatter.dateString(from: (self.input.record.date! as Date), withFormat: format)
    }()
    
    lazy var amtString : String = {
       
        var amtStr: String = ""
        var transAmount = record.toAmt
        
        switch record.inoutRoleOfAddress(asset.wallet!.address!) {
        case .none: break
        case .some(let type):
            switch type {
            case .deposit:
                amtStr = "+"
            case .withdrawal:
                amtStr = "-"
                if asset.wallet?.walletMainCoinID == Coin.btc_identifier {
                    if record.block > 0 {
                        transAmount = transAmount?.subtracting(record.totalFee ?? NSDecimalNumber.init(value:0.0))
                    }
                }
            }
        }
        
        if let amt = (transAmount as Decimal?) {
            let maxDigit: Int
            switch record.owStatus {
            case .failed: maxDigit = 4
            case .success:
                if let coinDigit =
                    Coin.getCoin(ofIdentifier: record.fromCoinID!)?.digit {
                    maxDigit = Int(coinDigit)
                }else {
                    maxDigit = 18
                }
            }
            if amt > 0 {
                amtStr = amtStr + amt.asString(digits: maxDigit).disguiseIfNeeded()
            }else {
                amtStr = amt.asString(digits: maxDigit).disguiseIfNeeded()
            }
        }else {
            amtStr = "--"
        }
        return amtStr
    }()
    
    lazy var fromAddress:String = {
        var address = self.record.fromAddress
        return address!
    }()
    lazy var toAddress: String = {
        var address = self.record.toAddress
        return address!
    }()
    
    lazy var feeString :String = {
       
        guard let feeCoin = Coin.getCoin(ofIdentifier: record.feeCoinID!) else { return ""}
        
        let feeAmt = record.totalFee! as Decimal
        var feeAmtStr = feeAmt.asString(digits: Int(feeCoin.digit))
        
        var coinName = feeCoin.identifier == Coin.usdt_identifier ? "BTC" :  feeCoin.inAppName!
        
        if ( record.fromCoinID == Coin.ttn_identifier) {
            feeAmtStr = "0.1 TTN"
            coinName = ""
        } else if ( record.fromCoinID == Coin.btcn_identifier) {
            
        }
        
        switch record.fromCoinID! {
        case Coin.ttn_identifier:
            feeAmtStr = "0.1 TTN"
            coinName = ""
        case Coin.btcn_identifier,Coin.usdtn_identifier:
            if (record.fromAddress == C.TTNTx.officialTTNAddress) {  //deposit
                feeAmtStr = "請查看BTC錢包"
            } else if (record.toAddress == C.TTNTx.officialTTNAddress) { //withdraw
                feeAmtStr = "0.1 TTN, 0.00020546 BTC⚡"
            } else {
                feeAmtStr = "0.1 TTN"
            }
            coinName = ""
        default:
            break
        }
        
        return feeAmtStr.disguiseIfNeeded() + coinName
    }()
    
    lazy var noteMessage:String = {
       return record.note ?? "-"
    }()
    lazy var txId :String = {
        return record.txID ?? ""
    }()
    lazy var blockNumbers : String = {
        return "\(record.block)"
    }()
    
    func createTxURL() -> URL?{
        if let txid = record.txID {
            switch asset.wallet!.owChainType {
            case .btc:
                if asset.coinID == Coin.usdt_identifier {
                    return OmniExplorerCreator.url(ofTxID: txid)
                }else {
                    return BlockExplorerURLCreator.url(ofTxID: txid)
                }
            case .eth:
                return EtherscanURLCreator.url(ofTxID: txid)
            case .cic:
                return nil
            case .ttn:
                return TTNURLCreator.url(txid: txid)
            }
        }
        return nil
    }
}
