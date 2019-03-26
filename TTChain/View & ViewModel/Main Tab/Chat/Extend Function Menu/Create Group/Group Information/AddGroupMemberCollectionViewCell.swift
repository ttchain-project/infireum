//
//  AddGroupMemberCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class AddGroupMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var viewModel: AddGroupMemberCollectinoViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            avatarImageView.setProfileImage(image: viewModel.output.avatarImage,tempName:viewModel.input.friendInfoModel.nickName)

        }
    }
}
