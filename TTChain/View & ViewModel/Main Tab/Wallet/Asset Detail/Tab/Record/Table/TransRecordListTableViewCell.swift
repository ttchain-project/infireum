//
//  TransRecordListTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class TransRecordListTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
//    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var sepline: UIView!
//    @IBOutlet weak var commentsLabel: UILabel!
    
    //Will send the blockexplorer url.
    var onTapStatusBtn: ((URL) -> Void)?
    private var explorerURL: URL?
    
    private var transRecord: TransRecord!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
//        statusBtn.addTarget(self, action: #selector(statusBtnTapped), for: .touchUpInside)
        amtLabel.font = .owRegular(size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(address: String, chainType: ChainType, transRecord: TransRecord, statusURLHandle: @escaping (URL) -> Void) {
        self.transRecord = transRecord
        self.onTapStatusBtn = statusURLHandle
        //Style part
        let dls = LM.dls
        let palette = TM.palette
        
        addrLabel.set(textColor: palette.label_sub, font: .owRegular(size: 18))
        dateLabel.set(textColor: palette.specific(color: .owSilver), font: .owRegular(size: 12))
//        commentsLabel.set(textColor: palette.specific(color: .owSilver), font: .owRegular(size: 12))
        amtLabel.textColor = transRecord.getRecordColor(ofAddress: transRecord.fromAddress!)
        
//        let statusDesc: String
//        let underlineStyle: NSUnderlineStyle
//        let statusHidden: Bool
        
//        switch transRecord.owStatus {
//        case .failed:
//            statusDesc = dls.assetDetail_label_tx_failed
//            underlineStyle = .styleSingle
//            statusHidden = false
//        case .success:
//            statusDesc = dls.assetDetail_label_tx_go_check
//            underlineStyle = .styleSingle
//            //Has no explorer of cic, so hide when has cic success records
//            statusHidden = (chainType == .cic)
//        }
        
//        statusBtn.set(
//            attrText: NSAttributedString.init(
//                string: statusDesc,
//                attributes: [
//                    NSAttributedStringKey.foregroundColor : transRecord.getRecordColor(ofAddress: transRecord.fromAddress!),
//                    NSAttributedStringKey.font : UIFont.owRegular(size: 10),
//                    NSAttributedStringKey.underlineStyle : underlineStyle.rawValue
//                ]
//            )
//        )
        
//        statusBtn.isHidden = statusHidden
        
        sepline.backgroundColor = palette.sepline
        
        
        //Content part
        switch transRecord.inoutRoleOfAddress(address) {
        case .none: break
        case .some(let type):
            switch type {
            case .deposit:
                addrLabel.text = transRecord.fromAddress
                self.amtLabel.textColor = UIColor.green
            case .withdrawal:
                addrLabel.text = transRecord.toAddress
                self.amtLabel.textColor = UIColor.red
            }
        }
        
        dateLabel.text = DateFormatter.dateString(from:
            transRecord.date! as Date, withFormat: "MM/dd/yyyy HH:mm:ss"
        )
        
//        commentsLabel.text = transRecord.remarkComment
        
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
                switch transRecord.inoutRoleOfAddress(address) {
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
        
        amtLabel.text = amtStr
        
//        icon.image = icon(of: address, in: transRecord)
        
        if let txid = transRecord.txID {
            switch chainType {
            case .btc:
                explorerURL = BlockExplorerURLCreator.url(ofTxID: txid)
            case .eth:
                explorerURL = EtherscanURLCreator.url(ofTxID: txid)
            case .cic:
                explorerURL = nil
            }
        }
    }
    
    func config(asset: Asset, transRecord: TransRecord, statusURLHandle: @escaping (URL) -> Void) {
        config(address: asset.wallet!.address!,
               chainType: asset.wallet!.owChainType,
               transRecord: transRecord,
               statusURLHandle: statusURLHandle)
    }
    
    @objc private func statusBtnTapped() {
        guard let rec = transRecord else { return }
        guard let url = explorerURL else {
                return
        }

        onTapStatusBtn?(url)
    }
    
    private func icon(of address: String, in record: TransRecord) -> UIImage {
        switch record.owStatus {
        case .failed:
             return #imageLiteral(resourceName: "iconListFail")
        case .success:
            switch record.inoutRoleOfAddress(address) {
            case .none: return errorDebug(response: #imageLiteral(resourceName: "iconListFail"))
            case .some(let rec):
                switch rec {
                case .deposit:
                    return #imageLiteral(resourceName: "iconListInto")
                case .withdrawal:
                    return #imageLiteral(resourceName: "iconListTransferOut")
                }
            }
        }
    }
}
