//
//  ExportWalletSettingsTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class ExportWalletSettingsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.exportLabel.set(textColor: .cloudBurst, font: .owRegular(size: 14))
        self.walletExportLabel.set(textColor: .cloudBurst, font: .owRegular(size: 14))
        self.exportLabel.text = LM.dls.setting_export_key_title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var exportLabel: UILabel!
    @IBOutlet weak var walletExportLabel: UILabel!
    @IBOutlet weak var walletImageLabel: UIImageView!
    
    func config(setting:SettingType) {
        walletExportLabel.text = setting.title
        walletImageLabel.image = setting.image
    }
}
