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
    var avatar: UIImage? {get set}
}

class FriendRequestInformationModel: FriendModel,ChatListPage {
    var invitationID: Int = 0
    var uid: String = ""
    var nickName: String = ""
    var message: String = ""
    var avatar: UIImage?
    var avatarUrl: URL?
    
    init(invitationID: Int = 0, uid: String = "", nickName: String = "", message: String = "",headShotImage :String? = nil) {
        self.invitationID = invitationID
        self.uid = uid
        self.nickName = nickName
        self.message = message
        if headShotImage != nil {
            guard let url = URL.init(string: headShotImage!) else {
                return
            }
            self.avatarUrl = url
            KLRxImageDownloader.instance.download(source: url) {
                result in
                switch result {
                case .failed: warning("Cannot download img from url \(headShotImage ?? " " )")
                case .success(let img):
                    self.avatar  = img
                }
            }
        }
    }
    
    init(invitationID: Int = 0, imUser: IMUser) {
        self.invitationID = invitationID
        self.uid = imUser.uID
        self.nickName = imUser.nickName ?? String()
        self.message = String()
        self.avatar = imUser.headImg
    }
}

class FriendInfoModel: FriendModel,ChatListPage {
    var avatar: UIImage?
    
    var uid: String = ""
    var nickName: String = ""
    var roomId: String = ""
    var avatarUrl: URL?

    init(uid: String = "", nickName: String = "", roomId: String = "", headhShotImgString: String = "") {
        self.uid = uid
        self.nickName = nickName
        self.roomId = roomId
        
            guard let url = URL.init(string: headhShotImgString) else {
                return
            }
            self.avatarUrl = url
            KLRxImageDownloader.instance.download(source: url) {
                result in
                switch result {
                case .failed: warning("Cannot download img from url \(headhShotImgString)")
                case .success(let img):
                    self.avatar  = img
                }
            }
        }
}


