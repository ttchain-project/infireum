//
//  CoinMarketTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/27.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class CoinMarketTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        srNoLabel.set(textColor: .cloudBurst, font: .owRegular(size: 12))
        coinNameLabel.set(textColor: .cloudBurst, font: .owRegular(size: 12))
        amountLabel.set(textColor: .cloudBurst, font: .owRegular(size: 12))
        percentageLabel.set(textColor: .white, font: .owRegular(size: 12))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var srNoLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var percentageView: UIView!
 
    func config(model:CoinMarketModel) {
        self.coinNameLabel.text = model.title
        self.amountLabel.text = model.price
        self.percentageLabel.text = model.change
        if model.change.contains("-") {
            self.amountLabel.textColor = UIColor.bittersweet
            self.percentageView.backgroundColor = .bittersweet
        }else {
            self.amountLabel.textColor = UIColor.owCoolGreen
            self.percentageView.backgroundColor = .owCoolGreen
        }
    }
}
