//
//  CommunicationListModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/6.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

protocol ChatListPage {
    
}

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

class CommunicationListModel:ChatListPage {
    var roomId:String
    var displayName:String
    var img: String?
    var lastMessage : String
    lazy var customLastMessage :String? = {
        if self.lastMessage.contains(".3gp")  {
            return LM.dls.voice_message_string
        } else if self.lastMessage.contains(".jpeg") ||  self.lastMessage.contains(".jpg") || self.lastMessage.contains(".png") {
            return LM.dls.image_message_string
        }else if self.lastMessage.contains("音频通话") {
            return LM.dls.call_message_string
        }

        return nil
    }()
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
