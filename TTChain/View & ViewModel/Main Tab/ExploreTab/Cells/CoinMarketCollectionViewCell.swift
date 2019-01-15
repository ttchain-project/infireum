//
//  CoinMarketCollectionViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/15.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class CoinMarketCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setup(model:CoinMarketModel) {
        
        self.titleLabel.text = model.title
        self.priceLabel.text = model.price
        self.changeLabel.text = model.change
        if model.change.contains("-") {
            self.changeLabel.textColor = UIColor.red
        }else {
            self.changeLabel.textColor = UIColor.green
        }
    }
}
