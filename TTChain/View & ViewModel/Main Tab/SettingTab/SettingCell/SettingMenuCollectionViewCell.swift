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
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.sizeToFit()
        // Initialization code
    }
    
    func setupCell(model:MarketTest) {
        self.titleLabel.text = model.title
        guard let imageURL = URL.init(string: model.img) else {
            imageView.image = #imageLiteral(resourceName: "no_image")
            return
        }
        imageView.af_setImage(withURL: imageURL)
        let title = model.title.replacingOccurrences(of: "\n", with: " ")
        self.titleLabel.numberOfLines = title.components(separatedBy: " ").count == 1 ? 1 : 0
    }
}
