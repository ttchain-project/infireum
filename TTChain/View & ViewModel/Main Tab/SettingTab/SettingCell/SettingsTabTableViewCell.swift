//
//  SettingsTabTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class SettingsTabTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.set(textColor: .cloudBurst, font: .owRegular(size: 14))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    func config(setting:SettingType) {
        titleLabel.text = setting.title
        iconImage.image = setting.image
    }
}
