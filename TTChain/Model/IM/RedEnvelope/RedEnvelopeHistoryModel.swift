//
//  ReceiveRedEnvelopeHistoryModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/28.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

struct ReceiveRedEnvelopeHistoryModel: Decodable {
    let redEnvelopeId: String
    let senderName: String
    let displayName: String
    let receiveAddress: String
    let receiveAmount: Double
    let createTime: String
    let receiveTime: String
    let paidTime: String?
    let isDone: Bool
}

struct SendRedEnvelopeHistoryModel:Decodable {
    let redEnvelopeId: String
    let displayName: String
    let totalCount: Int
    let totalAmount: Double
    let isOpen: Bool
    let status: RedEnvelopeStatus
    let createTime: String
}
