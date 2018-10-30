//
//  SelectFiatTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class SelectFiatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fiatNameLabel: UILabel!
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
    
    public func config(fiat: Fiat, isSelected: Bool) {
        let palette = TM.palette
        fiatNameLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        sepline.backgroundColor = palette.sepline
        checkmark.isHidden = !isSelected
        
        fiatNameLabel.text = fiat.name
    }
}
