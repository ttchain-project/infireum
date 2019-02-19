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
    
    func config(constructor: TransRecordDetailViewController.Input) {
        
        self.view.layoutIfNeeded()
        
        let transRecord = constructor.transRecord
        if transRecord.owStatus == .failed {
            self.transactionStatusLabel.text = LM.dls.trans_failed
        }else {
            self.transactionStatusLabel.text = LM.dls.trans_success
        }
        
        let format = "MM/dd/yyyy HH:mm:ss"
        self.transactionDateLabel.text = DateFormatter.dateString(from: (transRecord.date! as Date), withFormat: format)

        var amtStr: String
        if let amt = (transRecord.toAmt as Decimal?) {
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
            amtStr = amt.asString(digits: maxDigit).disguiseIfNeeded()
            if amt > 0 {
                switch transRecord.inoutRoleOfAddress(constructor.asset.wallet!.address!) {
                case .none: break
                case .some(let type):
                    switch type {
                    case .deposit:
                        amtStr = "+" + amtStr
                    case .withdrawal:
                        amtStr = "-" + amtStr
                    }
                }
            }
        }else {
            amtStr = "--"
        }
        
        self.amountValueLabel.text = amtStr
        
        self.paymentAddressValueLabel.text = transRecord.fromAddress
        self.recieptAddressValueLabel.text = transRecord.toAddress
       
        guard let feeCoin = Coin.getCoin(ofIdentifier: transRecord.feeCoinID!) else { return }
        let feeAmt = transRecord.totalFee! as Decimal
        let feeAmtStr = feeAmt.asString(digits: Int(feeCoin.digit))
        self.minorFeeValueLabel.text = feeAmtStr.disguiseIfNeeded() + feeCoin.inAppName!
        
        self.toLinkButton.rx.tap.asDriver().drive(onNext: { () in
            let marketTestDummy = MarketTestTabModel.init(title: "", content: "", url: constructor.url, img: "")
            let vc = ExploreDetailWebViewController.instance(from: ExploreDetailWebViewController.Config(model: marketTestDummy))
            self.navigationController?.pushViewController(vc,animated:true)
        }).disposed(by: bag)
        
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
    }
   
    struct Input {
        let transRecord:TransRecord
        let asset:Asset
        let url:String
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

}
