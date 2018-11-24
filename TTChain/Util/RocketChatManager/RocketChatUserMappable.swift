//
//  RocketChatUserMappable.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation

protocol RocketChatUserAuthenticationMappable {
    var rocketChatUserId: String {get set}
    var authToken: String {get set}

}

class RocketChatUser : RocketChatUserAuthenticationMappable {
    
    var rocketChatUserId: String
    var authToken: String
    var name: String
    init(rocketChatUserId: String, authToken: String, name: String) {
        self.rocketChatUserId = rocketChatUserId
        self.authToken = authToken
        self.name = name
    }
}
