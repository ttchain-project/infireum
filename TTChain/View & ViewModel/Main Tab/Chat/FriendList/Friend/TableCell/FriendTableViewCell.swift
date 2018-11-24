//
//  FriendTableViewCell.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var friendModel: FriendInfoModel? {
        didSet {
            
            if friendModel?.avatar == nil {
                self.avatarImageView.image = ImageUntil.drawAvatar(text: friendModel?.nickName ?? "A")
            }else {
                self.avatarImageView.image = friendModel?.avatar
            }
            self.descriptionLabel.text = friendModel?.nickName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.cornerRadius = 15.0
        avatarImageView.clipsToBounds = true
        let palette = TM.palette
        self.separatorView.backgroundColor = palette.sepline
        self.descriptionLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 21))
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
