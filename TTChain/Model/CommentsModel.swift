//
//  CommentsModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/15.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation

class CommentsModel {
    var txID : String
    var comment: String
    init(txID: String, comment: String) {
        self.txID = txID
        self.comment = comment
    }
}
