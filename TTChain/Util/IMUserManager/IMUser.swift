//
//  IMUser.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

protocol IMUserMappable {
    var uID: String {get set}
    var nickName:String? {get set}
    var introduction: String? {get set}
    var headImg: UIImage? {get set}
}

class IMUser:IMUserMappable {
    var uID: String
    var nickName:String?
    var introduction: String?
    var headImg: UIImage?
    
    init(uID:String, nickName: String, introduction: String, headImg: String?) {
        self.uID = uID
        self.nickName = nickName
        self.introduction = introduction
        var image : UIImage?
        if headImg != nil, let url = URL.init(string: headImg!), let data = try? Data.init(contentsOf: url) {
            image = UIImage.init(data: data)
        }
        self.headImg = image
    }
}

