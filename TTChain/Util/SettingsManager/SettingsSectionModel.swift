//
//  SettingsCategory.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxDataSources

struct SettingsSectionModel: SectionModelType{
  
    var items: [SettingsTabModel]
    
    init(original: SettingsSectionModel, items: [Item]) {
        self = original
        self.categoryTitle = ""
        self.items = items
    }
    
    typealias Item = SettingsTabModel
    
    var categoryTitle:String
    
    init(title: String, items: [Item]) {
        self.categoryTitle = title
        self.items = items
    }
    
}
