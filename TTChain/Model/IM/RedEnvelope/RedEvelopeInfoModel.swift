//
//  ReceiveRedEnvelopeModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/26.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

struct ImageString: Codable {
    let original: String?
    let small: String?
    let medium: String?
}

class RedEvelopeInfoModel:Decodable {
    
    struct Info: Decodable {
        let uid: String
        let senderName: String
        let headImg: ImageString
        let message: String
        let isExpired: Bool
        let totalCount: Int
        let receiveCount: Int
        let totalAmount: Double
        let identifier: String
        let type: RedEnvelopeType
        let waitPaidAmount: Double
        let displayName: String
        let createTime: String
        let status: RedEnvelopeStatus
        let senderAddress: String
        let expiredTime: String?
        let paidAmount: Double
    }
    
    struct Member: FriendModel,Decodable {
        var uid: String
        var nickName: String
        var avatarUrl: String?
        let imageString: ImageString?
        let receiveAmount: Double
        let receiveTime: String
        let receiveAddress: String
        let isDone: Bool
        let paidTime: String?
        
        enum CodingKeys: String, CodingKey {
            case imageString = "headImg"
            case uid,nickName,receiveAmount, receiveTime, isDone, receiveAddress, paidTime
        }
    }
    let members: [Member]
    let info: Info
}
