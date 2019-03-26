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
import RxDataSources

struct GroupMemberCollectionViewCellModel: ViewModel {
    var input: Input
    var output: Output
    
    struct Input {
        let groupMemberModel: GroupMemberModel?
    }
    
    struct Output {
        let text: String
        let avatarImage: String?
        let closeButtonIsHidden = BehaviorRelay<Bool>(value: false)
    }
    
    init(text: String, avatarImge: String?) {
        input = Input.init(groupMemberModel: nil)
        output = Output.init(text: text, avatarImage: avatarImge)
    }
    
    init(groupMemberModel: GroupMemberModel? = nil) {
        input = Input.init(groupMemberModel: groupMemberModel)
        output = Output.init(text: groupMemberModel?.nickName ?? LM.dls.group_member_new, avatarImage: groupMemberModel?.avatarUrl)
    }
    
    init(friendInfoModel: FriendInfoModel) {
        let groupMemberModel = GroupMemberModel.init(uid: friendInfoModel.uid, nickName: friendInfoModel.nickName, headImg: friendInfoModel.avatarUrl ?? String(), status: 0)
        input = Input.init(groupMemberModel: groupMemberModel)
        output = Output.init(text: groupMemberModel.nickName, avatarImage: friendInfoModel.avatarUrl)
    }
}

extension GroupMemberCollectionViewCellModel: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return input.groupMemberModel?.uid ?? output.text }
}

extension GroupMemberCollectionViewCellModel: Equatable {
    static func == (lhs: GroupMemberCollectionViewCellModel, rhs: GroupMemberCollectionViewCellModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

struct AddGroupMemberCollectinoViewCellModel: ViewModel {
    var input: Input
    var output: Output
    
    struct Input {
        let friendInfoModel: FriendInfoModel
    }
    
    struct Output {
        let avatarImage: String?
    }
    
    init(friendInfoModel: FriendInfoModel) {
        input = Input.init(friendInfoModel: friendInfoModel)
        output = Output.init(avatarImage: friendInfoModel.avatarUrl)
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
        let avatarImage: String?
        let isSelected = BehaviorRelay<Bool>(value: false)
    }
    
    init(friendInfoModel: FriendInfoModel) {
        input = Input.init(friendInfoModel: friendInfoModel)
        output = Output.init(nickname: friendInfoModel.nickName, avatarImage: friendInfoModel.avatarUrl)
    }
}
