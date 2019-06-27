//
//  SettingMenuHeaderCollectionReusableView.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/9.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class SettingMenuHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setup(title:String,subTitle:String) {
        self.titleLabel.text = title
        self.subTitle.text = subTitle
    }
}
