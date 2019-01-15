//
//  SettingsTabModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/7.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

protocol MarketTest {
    var title: String {get}
    var url: URL? {get}
    var img : String {get}
}

class MarketTestTabModel: MarketTest {
    var url: URL?
    var title: String
    var content:String
    var isExternalLink: Bool {
        return self.url?.scheme != "app"
    }
    var img : String
    
    init(title:String, content:String, url:String, img:String) {
        self.title = title
        self.content = content
        self.url = URL.init(string: url)
        self.img = img
    }
}

class GroupShortcutModel:MarketTest {
    var url: URL?
    var title: String
    var content: String
    var img: String
    
    init(title:String, content:String, url:String, img:String) {
        self.title = title
        self.content = content
        self.url = URL.init(string: url)
        self.img = img
    }
}

class CoinMarketModel: MarketTest {
    var url: URL?
    var title: String
    var img: String
    var price: String
    var change: String
    
    init(title:String, price:String,change:String, url:String, img:String) {
        self.title = title
        self.url = URL.init(string: url)
        self.img = img
        self.price = price
        self.change = change
        
    }
}
