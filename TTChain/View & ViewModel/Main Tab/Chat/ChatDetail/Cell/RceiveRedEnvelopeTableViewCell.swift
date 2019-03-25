//
//  RceiveRedEnvelopeTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/25.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class RceiveRedEnvelopeTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var receiveRedEnvelopeStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.set(textColor: .black, font: .owMedium(size: 14))
        
        self.receiveRedEnvelopeStatusLabel.set(textColor: .black, font: .owMedium(size: 16))
        self.backgroundColor = .clear
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func config(message:MessageModel) {
        self.dateLabel.text = message.timestamp.string()
        self.receiveRedEnvelopeStatusLabel.text = message.msg
    }
}
