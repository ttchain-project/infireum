//
//  MessageModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
enum MessageType:String {
    case general = "general"
    case file = "file"
}
class MessageModel {
    
    var messageId: String
    var roomId: String
    var msg: String
    var senderId: String
    var senderName: String
    var timestamp:Date
    var userName:String?
    var msgType:MessageType
    init(messageId: String,
    roomId: String,
    msg: String,
    senderId: String,
    senderName: String,
    timestamp:Date,
    messageType:MessageType,
    userName:String? = nil) {
     
        self.messageId = messageId
        self.roomId = roomId
        self.msg = msg
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
        self.userName = userName
        self.msgType = messageType
    }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

