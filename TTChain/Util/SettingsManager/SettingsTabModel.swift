//
//  SettingsTabModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/7.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
class SettingsTabModel {
    var title: String
    var content:String
    var url: URL
    var isExternalLink: Bool {
        return self.url.scheme != "app"
    }
    var img : String
    
    init(title:String, content:String, url:String, img:String) {
        self.title = title
        self.content = content
        self.url = URL.init(string: url)!
        self.img = img
    }
}
