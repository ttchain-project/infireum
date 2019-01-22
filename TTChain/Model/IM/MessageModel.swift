//
//  MessageModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
class MessageModel {
    
    var messageId: String
    var roomId: String
    var msg: String
    var senderId: String
    var senderName: String
    var timestamp:Date
    var userName:String?
    
    init(messageId: String,
    roomId: String,
    msg: String,
    senderId: String,
    senderName: String,
    timestamp:Date,
    userName:String? = nil) {
     
        self.messageId = messageId
        self.roomId = roomId
        self.msg = msg
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
        self.userName = userName
    }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

