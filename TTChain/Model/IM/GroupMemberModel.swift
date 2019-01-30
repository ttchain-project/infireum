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
        
        if let url = URL.init(string: headImg) {
            KLRxImageDownloader.instance.download(source: url) {
                result in
                switch result {
                case .failed: warning("Cannot download img from url \(headImg )")
                case .success(let img):
                    print("Image downloaded for %@",self.uid)
                    self.avatar  = img
                }
            }
        }else {
           self.avatar = ImageUntil.drawAvatar(text: nickName)
        }
        self.isFriend = isFriend ?? false
        self.isBlocked = isBlocked ?? false
    }
}
