//
//  KeyboardFunctionCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/18.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class KeyboardFunctionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .yellowGreen
    }

}
