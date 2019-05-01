//
//  AddressbookTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class AddressbookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chainTypeIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sepline: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func config(unit: AddressBookUnit, isSelectable: Bool) {
        let mainCoin = unit.mainCoin!
        nameLabel.text = unit.name!
        addressLabel.text = "\(mainCoin.inAppName!): \(unit.address!)"
        
        let palette = TM.palette
        nameLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        addressLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 12))
        sepline.backgroundColor = palette.sepline
        
        chainTypeIcon.image = img(ofMainCoinID: unit.mainCoinID!)
        
        contentView.alpha = isSelectable ? 1 : 0.4
    }
    
    private func img(ofMainCoinID mainCoinID: String) -> UIImage {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        switch coin.owChainType {
        case .btc: return #imageLiteral(resourceName: "iconListWalletBtc")
        case .eth: return #imageLiteral(resourceName: "iconContentEth")
        case .cic:
            if coin.walletMainCoinID == Coin.cic_identifier {
                return #imageLiteral(resourceName: "iconFundsCic")
            }else if coin.walletMainCoinID == Coin.guc_identifier {
                return #imageLiteral(resourceName: "bgContent4Guclogo")
            }else {
                return coin.iconImg ?? #imageLiteral(resourceName: "iconListNoimage")
            }
        case .ttn:
            return #imageLiteral(resourceName: "ttn_icon")
        }
    }
}

