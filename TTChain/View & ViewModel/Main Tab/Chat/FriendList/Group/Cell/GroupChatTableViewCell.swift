//
//  GroupChatTableViewCell.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class GroupChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var groupModel: UserGroupInfoModel = UserGroupInfoModel() {
        didSet {
            self.titleLabel.text = groupModel.groupName
            self.avatarImageView.setProfileImage(image: groupModel.headImg, tempName: groupModel.groupName)
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.cornerRadius = 15.0
        avatarImageView.clipsToBounds = true
        let palette = TM.palette
        self.titleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        self.separatorView.backgroundColor = palette.sepline
        self.backgroundColor = .clear
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
