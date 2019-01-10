//
//  SettingMenuCollectionViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class SettingMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func setupCell(model:SettingsTabModel) {
        imageView.af_setImage(withURL: URL.init(string: model.img)!)
        self.titleLabel.text = model.title
    }
}
