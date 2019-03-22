//
//  MessageModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum MessageType {
    case general
    case file
    case voiceMessage
    case receipt(messageDict : [String:String])
    case audioCall (messageDetails : CallMessageModel)
    var messageDict:[String:String] {
        switch  self {
        case .receipt(messageDict: let dict):
            return dict
        default:
           return [:]
        }
    }
    var callMessage:CallMessageModel? {
        switch self {
        case .audioCall(messageDetails:let model):
            return model
        default:
            return nil
        }
    }
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
    var messageImage: UIImage? = nil
    
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
    
    convenience init(messageResponse: JSON) {
        
        let msgID = messageResponse["_id"].string ?? ""
        let roomId = messageResponse["rid"].string ?? ""
        var rawMessage = messageResponse["msg"].string ?? ""
        
        let timestampDict = messageResponse["ts"]
        let timeStampString = timestampDict["$date"].string ?? ""
        
        let userDict = messageResponse["u"]
        let userId = userDict["_id"].string ?? ""
        let senderUserName = userDict["name"].string ?? ""
        let userName = userDict["username"].string ?? ""
        let msgType = messageResponse["msgType"].string ?? "general"
        let messageType : MessageType = {
            switch msgType {
            case "file":
                if let url = messageResponse["msg"].string  {
                    if let data = url.data(using: .utf8) {
                        let dict :[String:Any]? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if dict != nil, dict!["fileUrl"] != nil {
                            rawMessage = dict!["fileUrl"] as! String
                        }
                    }
                }
                guard let url = URL.init(string: rawMessage) else {
                    return .file
                }
                if url.pathExtension == "3gp" || url.pathExtension == "3gpp" {
                    return .voiceMessage
                }
                return .file
            case "audio","video":
                if let url = messageResponse["msg"].string  {
                    if let data = url.data(using: .utf8) {
                        let dict :[String:Any]? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        guard let audioMessageModel = CallMessageModel.init(json: dict!) else {
                            return .general
                        }
                        rawMessage = audioMessageModel.message
                        return MessageType.audioCall(messageDetails: audioMessageModel)
                    }
                }
                fallthrough
            default:
                rawMessage = messageResponse["msg"].string ?? ""
                if rawMessage.contains("address"),rawMessage.contains("amount"),rawMessage.contains("coinID") {
                    if let url = messageResponse["msg"].string  {
                        if let data = url.data(using: .utf8) {
                            let dict :[String:Any]? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            if dict != nil, dict!["address"] != nil,dict!["amount"] != nil,dict!["coinID"] != nil {
                                return .receipt(messageDict: dict as! [String : String])
                            }
                        }
                    }
                }
                return .general
            }
        }()
        
        let date = DateFormatter.date(from: timeStampString, withFormat: C.IMDateFormat.dateFormatForIM)
        
        self.init(messageId: msgID,
                  roomId: roomId,
                  msg: rawMessage,
                  senderId: userId,
                  senderName: senderUserName,
                  timestamp: date ?? Date.init(timeIntervalSinceNow: 0),
                  messageType: messageType,
                  userName: userName)
    }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension MessageModel {
    func isUserSender() -> Bool {
        guard (RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId) != nil else {
            return false
        }
        return self.senderId == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId
    }
}


struct CallMessageModel: Codable {
    let uid: String
    let roomId: String
    let streamId:String
    let message:String
    let type:CallType
    let isConnect:Bool
    

    init?(json: [String: Any]) {
        do {
            self = try JSONDecoder().decode(CallMessageModel.self, from: json.jsonData()!)
        } catch {
            DLogError("Call Message Cannot be decoded")
            return nil
        }
    }
}


enum RedEnvelopeType: Int, Codable {
    case normal = 0, group, lucky
}

enum RedEnvelopeStatus: Int, Codable {
    case waitReceive = 1, waitSend, done
}
