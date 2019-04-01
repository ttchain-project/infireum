//
//  FriendRequestInformationModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxDataSources



protocol FriendModel {
    var uid: String {get set}
    var nickName: String {get set}
    var avatarUrl: String? {get set}

}

class FriendRequestInformationModel: FriendModel,ChatListPage {
    
    var invitationID: Int = 0
    var uid: String = ""
    var nickName: String = ""
    var message: String = ""
    var avatarUrl: String?
    
    init(invitationID: Int = 0, uid: String = "", nickName: String = "", message: String = "",headShotImage :String? = nil) {
        self.invitationID = invitationID
        self.uid = uid
        self.nickName = nickName
        self.message = message
        self.avatarUrl = headShotImage

//        if headShotImage != nil {
//            guard let url = URL.init(string: headShotImage!) else {
//                return
//            }
//            KLRxImageDownloader.instance.download(source: url) {
//                result in
//                switch result {
//                case .failed: warning("Cannot download img from url \(headShotImage ?? " " )")
//                case .success(let img):
//                    self.avatar  = img
//                }
//            }
//        }
    }
    
    init(invitationID: Int = 0, imUser: IMUser) {
        self.invitationID = invitationID
        self.uid = imUser.uID
        self.nickName = imUser.nickName ?? String()
        self.message = String()
        self.avatarUrl = imUser.headImgUrl
    }
}


class FriendInfoModel: FriendModel,ChatListPage {
    var avatarUrl: String?
    
    var uid: String = ""
    var nickName: String = ""
    var roomId: String = ""

    init(uid: String = "", nickName: String = "", roomId: String = "", headhShotImgString: String = "") {
        self.uid = uid
        self.nickName = nickName
        self.roomId = roomId
        self.avatarUrl = headhShotImgString
    }
}
