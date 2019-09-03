//
//  ImportedWalletsTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/8/28.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class ImportedWalletsTableViewCell: UITableViewCell {

    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        walletName.set(textColor: TM.palette.label_main_1, font: UIFont.owRegular(size:16))
        walletAddress.set(textColor: TM.palette.label_main_1, font: UIFont.owRegular(size:12))

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
