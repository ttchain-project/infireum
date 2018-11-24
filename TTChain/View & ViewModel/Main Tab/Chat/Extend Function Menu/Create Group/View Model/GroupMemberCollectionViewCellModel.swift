//
//  GroupMemberCollectionViewCellModel.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct GroupMemberCollectionViewCellModel: ViewModel {
    var input: Input
    var output: Output
    
    struct Input {
        let groupMemberModel: GroupMemberModel?
    }
    
    struct Output {
        let text: String
        let avatarImage: UIImage?
        let closeButtonIsHidden = BehaviorRelay<Bool>(value: false)
    }
    
    init(text: String, avatarImge: UIImage?) {
        input = Input.init(groupMemberModel: nil)
        output = Output.init(text: text, avatarImage: avatarImge)
    }
    
    init(groupMemberModel: GroupMemberModel? = nil) {
        input = Input.init(groupMemberModel: groupMemberModel)
        output = Output.init(text: groupMemberModel?.nickName ?? "新增", avatarImage: groupMemberModel?.avatar)
    }
    
    init(friendInfoModel: FriendInfoModel) {
        let groupMemberModel = GroupMemberModel.init(uid: friendInfoModel.uid, nickName: friendInfoModel.nickName, headImg: friendInfoModel.avatar?.base64EncodedString ?? String(), status: 0)
        input = Input.init(groupMemberModel: groupMemberModel)
        output = Output.init(text: groupMemberModel.nickName, avatarImage: friendInfoModel.avatar)
    }
}

struct AddGroupMemberCollectinoViewCellModel: ViewModel {
    var input: Input
    var output: Output
    
    struct Input {
        let friendInfoModel: FriendInfoModel
    }
    
    struct Output {
        let avatarImage: UIImage?
    }
    
    init(friendInfoModel: FriendInfoModel) {
        input = Input.init(friendInfoModel: friendInfoModel)
        output = Output.init(avatarImage: friendInfoModel.avatar)
    }
}

struct AddGroupMemeberTableViewCellModel: ViewModel {
    var input: Input
    var output: Output
    
    struct Input {
        let friendInfoModel: FriendInfoModel
    }
    
    struct Output {
        let nickname: String
        let avatarImage: UIImage?
        let isSelected = BehaviorRelay<Bool>(value: false)
    }
    
    init(friendInfoModel: FriendInfoModel) {
        input = Input.init(friendInfoModel: friendInfoModel)
        output = Output.init(nickname: friendInfoModel.nickName, avatarImage: friendInfoModel.avatar)
    }
}
