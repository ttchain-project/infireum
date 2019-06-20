//
//  SettingsCategory.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxDataSources

struct MarketTestSectionModel: SectionModelType{
  
    var items: [MarketTest]
    
    init(original: MarketTestSectionModel, items: [Item]) {
        self = original
        self.categoryTitle = ""
        self.items = items
    }
    
    typealias Item = MarketTest
    
    var categoryTitle:String
    
    init(title: String, items: [Item]) {
        self.categoryTitle = title
        self.items = items
    }
    
}
