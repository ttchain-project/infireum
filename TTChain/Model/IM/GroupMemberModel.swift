//
//  GroupMemberModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/13.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

class GroupMemberModel:FriendModel {

    var uid : String
    var nickName :String
    var status: Int
    var avatar: UIImage?
    var isFriend:Bool? = false
    var isBlocked:Bool? = false

    init(uid: String, nickName: String, headImg:String, status:Int,isFriend:Bool? = false,isBlocked:Bool? = false) {
        self.uid = uid
        self.nickName = nickName
        self.status = status
        avatar = headImg.imageFromBase64EncodedString ?? ImageUntil.drawAvatar(text: nickName)
        self.isFriend = isFriend ?? false
        self.isBlocked = isBlocked ?? false
    }
}
