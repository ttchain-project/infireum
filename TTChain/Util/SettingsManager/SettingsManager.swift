//
//  SettingsManager.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/7.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

enum SettingKeyEnum:String {
    case SettingA = "setting_a"
    case SettingB = "setting_b"
    case SettingC = "setting_c"
    case SettingD = "setting_d"
}

class SettingTabHandler {
    
    static var shared:SettingTabHandler = SettingTabHandler.init()
    
    var settingsArray: BehaviorRelay<[SettingsSectionModel]> = {
    return BehaviorRelay.init(value: [])
    }()
    
    func syncSettingsTabData(json: JSON) {
       
        
        var settingsCategoryArray: [SettingsSectionModel] = []
        
        guard let datas = json.array else {
           return
        }
        for data in datas {
//            guard let keyName = data["key"].string, let key = SettingKeyEnum.init(rawValue:keyName) else {
//                continue
//            }
            let title: String = "Setting"
            let settingArray: [SettingsTabModel] = data.array!.compactMap { (settingJSON) -> SettingsTabModel? in
                guard let title = settingJSON["title"].string,
                    let content = settingJSON["content"].string,
                    let url = settingJSON["url"].string,
                    let img = settingJSON["img"].string else {
                    return nil
                }
                let model = SettingsTabModel.init(title: title, content: content, url: url, img: img)
                return model
            }
            let settingCategory = SettingsSectionModel.init(title: title, items: settingArray)
            settingsCategoryArray.append(settingCategory)
        }
        
        SettingTabHandler.shared.settingsArray.accept(settingsCategoryArray)
    }
    init() {
        
    }
}
