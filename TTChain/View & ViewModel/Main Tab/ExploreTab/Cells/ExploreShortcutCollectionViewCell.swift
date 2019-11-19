//
//  ExploreShortcutCollectionViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/27.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class ExploreShortcutCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.set(textColor: .cloudBurst, font: .owRegular(size: 14))
        
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
}
