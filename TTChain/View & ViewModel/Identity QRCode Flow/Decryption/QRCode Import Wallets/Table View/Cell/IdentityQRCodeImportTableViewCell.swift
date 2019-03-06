//
//  IdentityQRCodeImportTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class IdentityQRCodeImportTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isExistLabel: UILabel!
    @IBOutlet weak var sepline: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let palette = TM.palette
        let dls = LM.dls

        nameLabel.set(textColor: palette.label_main_1,
                      font: .owRegular(size: 14))
        
        isExistLabel.text = dls.exists
        isExistLabel.set(textColor: palette.specific(color: .owPinkRed),
                         font: .owRegular(size: 14))
        
        sepline.backgroundColor = palette.sepline
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(walletName: String, isExist: Bool) {
        nameLabel.text = walletName
        isExistLabel.isHidden = !isExist
    }
    
}
