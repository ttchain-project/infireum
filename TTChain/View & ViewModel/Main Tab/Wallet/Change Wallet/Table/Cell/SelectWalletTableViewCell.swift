//
//  SelectWalletTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/20.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class SelectWalletTableViewCell: UITableViewCell {

    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var walletSelectedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(walletName:String, coinName:String, walletAmount:String, isSelected:Bool) {
        self.walletNameLabel.text = walletName
        self.walletAmountLabel.text = LM.dls.withdrawalConfirm_changeWallet_label_assetAmt(walletAmount,coinName)
        self.walletSelectedImage.isHidden = !isSelected
    }
    
    func setupUI() {
        let palette = Theme.default.palette
        
        self.walletSelectedImage.isHidden = true
        walletNameLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
        
        self.walletNameLabel.set(textColor: palette.input_text, font: .owRegular(size: 14))

    }
}
