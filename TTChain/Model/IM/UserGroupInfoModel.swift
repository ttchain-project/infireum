//
//  UserGroupInfoModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources

class UserGroupInfoModel:ChatListPage {
    var groupID: String = ""
    var groupOwnerUID: String = ""
    var ownerName: String = ""
    var status: Int = 0
    var groupName: String = ""
    var isPrivate: Bool = false
    var introduction: String = ""
    var headImg: String = ""
    var imGroupId: String = ""
    var isPostMsg: Bool = false
    var groupIcon: UIImage? = nil
    var membersArray: [GroupMemberModel]?
    var invitedMembersArray: [GroupMemberModel]?
    
    init(groupID: String = "",
    groupOwnerUID: String = "",
    ownerName: String = "",
    status: Int = 0,
    groupName: String = "",
    isPrivate: Bool = false,
    introduction: String = "",
    headImg: String = "",
    imGroupId: String = "",
    isPostMsg: Bool = false,
    membersArray:[GroupMemberModel]? = nil,
    invitedMembersArray: [GroupMemberModel]? = nil) {

        self.groupID = groupID
        self.groupOwnerUID = groupOwnerUID
        self.ownerName = ownerName
        self.status = status
        self.groupName = groupName
        self.isPrivate = isPrivate
        self.introduction = introduction
        self.headImg = headImg
        self.imGroupId = imGroupId
        self.isPostMsg = isPostMsg
        if let url = URL.init(string: headImg)  {
            KLRxImageDownloader.instance.download(source: url) {
                result in
                switch result {
                case .failed: warning("Cannot download img from url \(headImg )")
                case .success(let img):
                    self.groupIcon  = img
                }
            }
        }
        
        if membersArray != nil {
            self.membersArray = membersArray
        }
        if invitedMembersArray != nil {
            self.invitedMembersArray = invitedMembersArray
        }
    }
}



