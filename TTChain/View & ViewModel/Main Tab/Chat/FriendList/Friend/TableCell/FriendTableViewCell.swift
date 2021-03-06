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
            guard let friendModel = friendModel else {
                return
            }
            self.descriptionLabel.text = friendModel.nickName

            self.avatarImageView.setProfileImage(image: friendModel.avatarUrl, tempName: friendModel.nickName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.cornerRadius = 15.0
        avatarImageView.clipsToBounds = true
        let palette = TM.palette
        self.separatorView.backgroundColor = palette.sepline
        self.descriptionLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        self.backgroundColor = .clear
//        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config( title: String, image:String?) {
        self.descriptionLabel.text = title
        self.avatarImageView.setProfileImage(image: image, tempName: title)
    }
}
