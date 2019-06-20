//
//  TransRecordDetailViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/18.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransRecordDetailViewController: KLModuleViewController,KLInstanceSetupViewController {
    @IBOutlet weak var transactionStatusLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    @IBOutlet weak var toLinkButton: UIButton!
    
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    
    @IBOutlet weak var minerFeeView: UIView!
    @IBOutlet weak var minorFeeTitleLabel: UILabel!
    @IBOutlet weak var minorFeeValueLabel: UILabel!

    @IBOutlet weak var recieptAddressView: UIView!
    @IBOutlet weak var recieptAddressTitleLabel: UILabel!
    @IBOutlet weak var recieptAddressValueLabel: UILabel!

    @IBOutlet weak var paymentAddressView: UIView!
    @IBOutlet weak var paymentAddressTitleLabel: UILabel!
    @IBOutlet weak var paymentAddressValueLabel: UILabel!

    let bag: DisposeBag = DisposeBag.init()
    var transRecord:TransRecord!
    var asset:Asset!
    func config(constructor: TransRecordDetailViewController.Input) {
        
        self.view.layoutIfNeeded()
        
        self.transRecord = constructor.transRecord
        self.asset = constructor.asset
        self.setupUI()
        
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        

    }
   
    struct Input {
        let transRecord:TransRecord
        let asset:Asset
    }
    typealias Constructor = Input
    
    override func renderTheme(_ theme: Theme) {
        self.transactionStatusLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 24))
        self.transactionDateLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 20))
        
        [self.amountTitleLabel,self.amountValueLabel,
         self.minorFeeTitleLabel,minorFeeValueLabel,
         self.paymentAddressTitleLabel,paymentAddressValueLabel,
         recieptAddressTitleLabel,recieptAddressValueLabel].forEach
            { label in
                label?.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 15))
        }
        self.toLinkButton.set(textColor: theme.palette.btn_bgFill_enable_text, font: .owMedium(size: 15), backgroundColor: theme.palette.btn_bgFill_enable_bg)
    }
    
    override func renderLang(_ lang: Lang) {
        self.amountTitleLabel.text = lang.dls.assetDetail_tab_total
        self.minorFeeTitleLabel.text  = lang.dls.ltTx_label_minerFee
        self.paymentAddressTitleLabel.text = lang.dls.withdrawal_label_fromAddr
        self.recieptAddressTitleLabel.text = lang.dls.withdrawal_label_toAddr
        self.toLinkButton.setTitle(lang.dls.assetDetail_label_tx_go_check, for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
        if transRecord.owStatus == .failed {
            self.transactionStatusLabel.text = LM.dls.trans_failed
        }else {
            self.transactionStatusLabel.text = LM.dls.trans_success
        }
        
        let format = "MM/dd/yyyy HH:mm:ss"
        self.transactionDateLabel.text = DateFormatter.dateString(from: (transRecord.date! as Date), withFormat: format)
        
        var amtStr: String = ""
        var transAmount = transRecord.toAmt
        
        switch transRecord.inoutRoleOfAddress(asset.wallet!.address!) {
        case .none: break
        case .some(let type):
            switch type {
            case .deposit:
                amtStr = "+"
            case .withdrawal:
                amtStr = "-"
                if asset.wallet?.walletMainCoinID == Coin.btc_identifier {
                    if transRecord.block > 0 {
                        transAmount = transAmount?.subtracting(transRecord.totalFee ?? NSDecimalNumber.init(value:0.0))
                    }
                }
            }
        }
        
        if let amt = (transAmount as Decimal?) {
            let maxDigit: Int
            switch transRecord.owStatus {
            case .failed: maxDigit = 4
            case .success:
                if let coinDigit =
                    Coin.getCoin(ofIdentifier: transRecord.fromCoinID!)?.digit {
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
        
        self.amountValueLabel.text = amtStr
        
        self.paymentAddressValueLabel.text = transRecord.fromAddress
        self.recieptAddressValueLabel.text = transRecord.toAddress
        
        guard let feeCoin = Coin.getCoin(ofIdentifier: transRecord.feeCoinID!) else { return }
        
        let feeAmt = transRecord.totalFee! as Decimal
        var feeAmtStr = feeAmt.asString(digits: Int(feeCoin.digit))
        
        var coinName = feeCoin.identifier == Coin.usdt_identifier ? "BTC" :  feeCoin.inAppName!
        
        if ( transRecord.fromCoinID == Coin.ttn_identifier) {
            feeAmtStr = "0.1 TTN"
            coinName = ""
        } else if ( transRecord.fromCoinID == Coin.btcn_identifier) {
            
        }
        
        switch transRecord.fromCoinID! {
        case Coin.ttn_identifier:
            feeAmtStr = "0.1 TTN"
            coinName = ""
        case Coin.btcn_identifier,Coin.usdtn_identifier:
            if (transRecord.fromAddress == C.TTNTx.officialTTNAddress) {  //deposit
                feeAmtStr = "請查看BTC錢包"
            } else if (transRecord.toAddress == C.TTNTx.officialTTNAddress) { //withdraw
                feeAmtStr = "0.1 TTN, 0.00020546 BTC⚡"
            } else {
                feeAmtStr = "0.1 TTN"
            }
            coinName = ""
        default:
            break
        }
        
        self.minorFeeValueLabel.text = feeAmtStr.disguiseIfNeeded() + coinName
        guard let url = self.createTxURL() else {
            self.toLinkButton.isHidden = true
            return
        }
        self.toLinkButton.rx.tap.asDriver().drive(onNext: { () in
            let vc = ExploreDetailWebViewController.instance(from: ExploreDetailWebViewController.Config(model: nil,url:url))
            self.navigationController?.pushViewController(vc,animated:true)
        }).disposed(by: bag)
        
        
    }
    private func createTxURL() -> URL?{
        if let txid = self.transRecord.txID {
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
