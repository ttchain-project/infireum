//
//  OWMnemonicWordCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class OWMnemonicWordCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var wordLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.borderColor = TM.palette.btn_borderFill_border_1st
        wordLabel.set(textColor: TM.palette.mnemonic_item_text, font: UIFont.owRegular(size: 12.7))
        baseView.set(backgroundColor: TM.palette.mnemonic_item_bg, borderInfo: (color: TM.palette.mnemonic_item_border, width: 1))
    }
    
    func config(word: String) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        wordLabel.text = word
    }
    
    func sizeNeeded(ofWord word: String) -> CGSize {
        config(word: word)
        let minSize = systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return minSize
    }

}
