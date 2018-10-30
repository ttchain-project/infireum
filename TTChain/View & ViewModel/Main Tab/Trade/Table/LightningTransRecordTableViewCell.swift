//
//  LightningTransRecordTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LightningTransRecordTableViewCell: UITableViewCell, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var fromCoinLabel: UILabel!
    @IBOutlet weak var toCoinLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var sepline: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(withRecord record: LightningTransRecord, urlHandler: @escaping (URL) -> Void) {
        
        let palette = TM.palette
        fromCoinLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
        toCoinLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
        feeLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12))
        dateLabel.set(textColor: palette.input_placeholder, font: .owRegular(size: 12))
        noteLabel.set(textColor: palette.input_placeholder, font: .owRegular(size: 12))
        amtLabel.set(textColor: palette.specific(color: .owCoolGreen), font: .owRegular(size: 14))
        sepline.backgroundColor = palette.sepline
        
        guard let coins = record.coins?.array as? [Coin] else { return }
        guard let fromIdx = coins.index(where: { (c) -> Bool in
            return c.identifier == record.fromCoinID!
        }) else { return }
        
        guard let toIdx = coins.index(where: { (c) -> Bool in
            return c.identifier == record.toCoinID!
        }) else { return }
        
        guard let feeCoin = Coin.getCoin(ofIdentifier: record.feeCoinID!) else { return }
        
        let fromCoin: Coin = coins[fromIdx]
        let toCoin: Coin = coins[toIdx]
        
        let fromAmt = record.fromAmt! as Decimal
        let toAmt = record.toAmt! as Decimal
        
        let date = record.date! as Date
        let feeAmt = record.totalFee! as Decimal
        
        let status = record.owStatus
        
        let fromCoinStr = String.init(format: "%@ %@", fromAmt.asString(digits: Int(fromCoin.digit)).disguiseIfNeeded(), fromCoin.inAppName!
        )
        fromCoinLabel.text = fromCoinStr
        
        let toCoinStr = String.init(format: "%@ %@", toAmt.asString(digits: Int(toCoin.digit)).disguiseIfNeeded(), toCoin.inAppName!
        )
        
        toCoinLabel.text = toCoinStr
        let feeAmtStr = feeAmt.asString(digits: Int(feeCoin.digit))
        feeLabel.text =
            LM.dls.lightningTx_label_txRecord_miner_fee(
                feeAmtStr.disguiseIfNeeded(),
                feeCoin.inAppName!
            )
        
        let format = "MM/dd/yyyy HH:mm:ss"
        dateLabel.text = DateFormatter.dateString(from: date, withFormat: format)
        
        amtLabel.text = toAmt.asString(digits: Int(toCoin.digit)).disguiseIfNeeded()
        
        noteLabel.text = record.note ?? ""
        
        setupStatusBtn(withStatus: status)
        
        //Temp solution, because right now CIC has no Explorer, only show source if btc part. (hide all the success-cic records.)
        statusBtn.isHidden = (
            (record.fromCoinID != Coin.btc_identifier) &&
            record.owStatus == .success
        )
        
        //Action
        bag = DisposeBag.init()
        statusBtn.rx.tap.asDriver()
            .drive(onNext: {
                if let id = record.txID {
                    urlHandler(BlockExplorerURLCreator.url(ofTxID: id))
                }
            })
            .disposed(by: bag)
    }
    
    func setupStatusBtn(withStatus status: TransRecordStatus) {
        let statusDesc: String
        let underlineStyle: NSUnderlineStyle
        let color: UIColor
        let palette = TM.palette
        switch status {
        case .failed:
            statusDesc = LM.dls.lightningTx_label_txRecord_failed
            underlineStyle = .styleNone
            color = palette.recordStatus_failed
        case .success:
            statusDesc = LM.dls.lightningTx_label_txRecord_go_check
            underlineStyle = .styleSingle
            color = palette.application_main
        }
        
        statusBtn.set(
            attrText: NSAttributedString.init(
                string: statusDesc,
                attributes: [
                    NSAttributedStringKey.foregroundColor : color,
                    NSAttributedStringKey.font : UIFont.owRegular(size: 10),
                    NSAttributedStringKey.underlineStyle : underlineStyle.rawValue
                ]
            )
        )
    }
}
