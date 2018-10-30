//
//  WithdrawalConfirmChangeWalletTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class WithdrawalConfirmChangeWalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var assetAmtLAbel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
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
    
    func config(asset: Asset, isUsable: Bool, isSelected: Bool) {
        checkmark.isHidden = !(isUsable && isSelected)
        let dls = LM.dls
        let palette = TM.palette
        let mainColor = isUsable ? palette.label_main_1 : palette.label_main_1.withAlphaComponent(0.3)
        let subColor = isUsable ? palette.label_sub : palette.label_sub.withAlphaComponent(0.3)
        
        walletNameLabel.set(textColor: mainColor, font: .owMedium(size: 14.5))
        assetAmtLAbel.set(textColor: subColor, font: .owRegular(size: 12))
        
        walletNameLabel.text = asset.wallet!.name
        let amtStr = (asset.amount! as Decimal).asString(digits: 18)
        assetAmtLAbel.text = dls.withdrawalConfirm_changeWallet_label_assetAmt(amtStr, asset.coin!.inAppName!)
        
        sepline.backgroundColor = palette.sepline
    }
    
}
