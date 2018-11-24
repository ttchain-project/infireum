//
//  MemberPersonalChatAndGroupsModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxDataSources

class MemberPersonalChatAndGroupsModel { 
    var title: String = ""
    var invitationList = [FriendRequestInformationModel]()
    var friendList = [FriendInfoModel]()
    
    convenience init() {
        self.init(title: "", invitationList: [], friendList: [])
    }
    
    convenience init(invitationList: [FriendRequestInformationModel], friendList: [FriendInfoModel]) {
        self.init(title: "", invitationList: invitationList, friendList: friendList)
    }
    
    init(title: String, invitationList: [FriendRequestInformationModel], friendList: [FriendInfoModel]) {
        self.title = title
        self.invitationList = invitationList
        self.friendList = friendList
    }
}
