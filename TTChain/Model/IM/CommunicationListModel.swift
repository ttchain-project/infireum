//
//  CommunicationListModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/6.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

enum RoomType : String {
    typealias RawValue = String
    
    case group = "Group", pvtChat = "PrivateMessage", channel = "Channel"
    
    var rawValue: String {
        switch self {
        case .group :
            return "Group"
        case .pvtChat:
            return "PrivateMessage"
        case .channel:
            return "Channel"
        }
    }
}

class CommunicationListModel {
    var roomId:String
    var displayName:String
    var img: String
    lazy var avatar : UIImage = {
        guard self.img.count > 0 else {
            return #imageLiteral(resourceName: "userPresetS")
        }
        var image : UIImage?
        if let url = URL.init(string: self.img),  let data = try? Data.init(contentsOf: url) {
            image = UIImage.init(data: data)
        }
        return image ?? #imageLiteral(resourceName: "userPresetS")
        
    }()
    
    var lastMessage : String
    var roomType: RoomType
    var updateTime: String
    var privateMessageTargetUid: String?
    
    init(roomId:String, displayName:String, img: String,lastMessage : String,roomType: String,updateTime: String, privateMessageTargetUid: String?) {
        self.roomId = roomId
        self.displayName = displayName
        self.img = img
        self.lastMessage = lastMessage
        self.roomType = RoomType.init(rawValue: roomType) ?? .pvtChat
        self.updateTime = updateTime
        self.privateMessageTargetUid = privateMessageTargetUid
    }
}
