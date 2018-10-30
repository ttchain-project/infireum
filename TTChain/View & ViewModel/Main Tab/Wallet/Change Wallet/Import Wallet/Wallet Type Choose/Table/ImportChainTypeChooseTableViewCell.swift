//
//  ImportChainTypeChooseTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class ImportChainTypeChooseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicator: UIImageView!
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
    
    public func config(mainCoin: Coin) {
        icon.image = icon(ofMainCoin: mainCoin)
        
        let dls = LM.dls
        let palette = TM.palette
        nameLabel.text = dls.importWallet_typeChoose_btn_generalWallet(mainCoin.inAppName!)
        
        nameLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        sepline.set(backgroundColor: palette.sepline)
    }
    
    private func icon(ofMainCoin coin: Coin) -> UIImage {
        switch coin.owChainType {
        case .eth:
            return #imageLiteral(resourceName: "iconListEtcNormal")
        case .btc:
            return #imageLiteral(resourceName: "iconListBtcNormal")
        case .cic:
            if coin.walletMainCoinID == Coin.cic_identifier {
                return #imageLiteral(resourceName: "iconListCicNormal")
            }else if coin.walletMainCoinID == Coin.guc_identifier {
                return #imageLiteral(resourceName: "iconListGuc")
            }else {
                return coin.iconImg ?? #imageLiteral(resourceName: "iconListNoimage")
            }
        }
    }
    
}
