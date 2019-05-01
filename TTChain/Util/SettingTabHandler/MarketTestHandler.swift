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
    case DApp = "dapp"
    case Explorer = "explorer"
    case Discovery = "discovery"
    case FinanceNews = "finnews"
    case ChatGroup = "group"
    case MarketTool = "markettool"
    case CoinMarket = "coinmarket"
    case Banner = "banner"
    case MarketMsg = "marketmsg"
    
}

class MarketTestHandler {
    
    let bag = DisposeBag.init()
    static var shared:MarketTestHandler = MarketTestHandler.init()
    
    var settingsArray: BehaviorRelay<[MarketTestSectionModel]> = {
    return BehaviorRelay.init(value: [])
    }()
    
    var bannerArray: BehaviorRelay<[MarketTestSectionModel]> = {
    return BehaviorRelay.init(value: [])
    }()
    
    var discoveryArray: BehaviorRelay<[MarketTestSectionModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    lazy var exploreOptionsObservable: Observable<[MarketTestSectionModel]> = {
        
        Observable.combineLatest(
            self.chatGroupArray.asObservable(), self.finNewsArray.asObservable(),self.dappArray.asObservable(),self.explorerArray.asObservable()
            )
            .map {
                 chatGroupArray,finNewsArray,dappArray,explorerArray -> [MarketTestSectionModel] in
                return
                    [MarketTestSectionModel.init(title: "", items: chatGroupArray),
                     MarketTestSectionModel.init(title: "", items: finNewsArray),
                     MarketTestSectionModel.init(title: "", items: dappArray),
                     MarketTestSectionModel.init(title: "", items: explorerArray)]
        }

    }()
    
    var chatGroupArray: BehaviorRelay<[GroupShortcutModel]> = {
        return BehaviorRelay.init(value: [])
    }()

    var dappArray: BehaviorRelay<[MarketTestTabModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var marketMsgArray: BehaviorRelay<[MarketTestTabModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var explorerArray: BehaviorRelay<[MarketTestTabModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var finNewsArray: BehaviorRelay<[MarketTestTabModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var marketToolArray: BehaviorRelay<[MarketTestTabModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var coinMarketArray: BehaviorRelay<[MarketTestSectionModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    func manageMarketTestData(json:JSON) {
        self.syncSettingTabData(json: json)
        self.syncDappArray(json: json[SettingKeyEnum.DApp.rawValue])
        self.syncBannerData(json: json[SettingKeyEnum.Banner.rawValue])
        self.syncFinNewsArray(json: json[SettingKeyEnum.FinanceNews.rawValue])
        self.syncExplorerArray(json: json[SettingKeyEnum.Explorer.rawValue])
        self.syncChatGroupArray(json: json[SettingKeyEnum.ChatGroup.rawValue])
        self.syncDiscoveryArray(json: json[SettingKeyEnum.Discovery.rawValue])
        self.syncMarketToolArray(json: json[SettingKeyEnum.MarketTool.rawValue])
        self.syncMarketMsgArray(json: json[SettingKeyEnum.MarketMsg.rawValue])

    }
    
    func managetQuotesTestData(json:JSON) {
        MarketTestHandler.shared.coinMarketArray.accept(
            [MarketTestSectionModel.init(title: "", items: self.parseCoinMarketJSON(json: json[SettingKeyEnum.CoinMarket.rawValue]))])
        
    }
    
    func syncBannerData(json: JSON) {
        MarketTestHandler.shared.bannerArray.accept(
            [MarketTestSectionModel.init(title: SettingKeyEnum.Banner.rawValue,items: (self.parseData(json:json)
                 ))])
    }
    
    func syncSettingTabData(json: JSON) {
        
        let categoryArray: [MarketTestSectionModel] =
            [MarketTestSectionModel.init(title: SettingKeyEnum.SettingA.rawValue, items: (self.parseData(json:json[SettingKeyEnum.SettingA.rawValue]))),
             MarketTestSectionModel.init(title: SettingKeyEnum.SettingB.rawValue, items: (self.parseData(json:json[SettingKeyEnum.SettingB.rawValue]))),
             MarketTestSectionModel.init(title: SettingKeyEnum.SettingC.rawValue, items: (self.parseData(json:json[SettingKeyEnum.SettingC.rawValue]))),
             MarketTestSectionModel.init(title: SettingKeyEnum.SettingD.rawValue, items: (self.parseData(json:json[SettingKeyEnum.SettingD.rawValue])))]
        
        MarketTestHandler.shared.settingsArray.accept(categoryArray)
    }
    
    func syncDiscoveryArray(json:JSON) {
        MarketTestHandler.shared.discoveryArray.accept(
            [MarketTestSectionModel.init(title: SettingKeyEnum.Discovery.rawValue,items: (self.parseData(json:json)
            ))])
    }
    
    func syncChatGroupArray(json:JSON) {
        MarketTestHandler.shared.chatGroupArray.accept(self.parseGroupJSON(json: json))
    }
    
    func syncDappArray(json:JSON) {
        MarketTestHandler.shared.dappArray.accept(self.parseData(json:json))
    }
    
    func syncExplorerArray(json:JSON) {
        MarketTestHandler.shared.explorerArray.accept(self.parseData(json:json))
    }
    
    func syncFinNewsArray(json:JSON) {
        MarketTestHandler.shared.finNewsArray.accept(self.parseData(json:json))
    }
    
    func syncMarketToolArray(json:JSON) {
        MarketTestHandler.shared.marketToolArray.accept(self.parseData(json:json))
    }
    func syncMarketMsgArray(json:JSON) {
        MarketTestHandler.shared.marketMsgArray.accept(self.parseData(json: json))
    }
    
    func parseData(json: JSON) -> [MarketTestTabModel] {
        guard let datas = json.array else {
            return []
        }
        let tabArray: [MarketTestTabModel] = datas.compactMap { (settingJSON) -> MarketTestTabModel? in
            guard let title = settingJSON["title"].string,
                let content = settingJSON["content"].string,
                let url = settingJSON["url"].string,
                let img = settingJSON["img"].string else {
                    return nil
            }
            let model = MarketTestTabModel.init(title: title, content: content, url: url, img: img)
            return model
        }
        return tabArray
    }
    
    func parseGroupJSON(json: JSON) -> [GroupShortcutModel] {
        guard let datas = json.array else {
            return []
        }
        let tabArray: [GroupShortcutModel] = datas.compactMap { (settingJSON) -> GroupShortcutModel? in
            guard let title = settingJSON["title"].string,
                let content = settingJSON["content"].string,
                let url = settingJSON["url"].string,
                let img = settingJSON["img"].string else {
                    return nil
            }
            let model = GroupShortcutModel.init(title: title, content: content, url: url, img: img)
            return model
        }
        return tabArray
    }
    func parseCoinMarketJSON(json:JSON) -> [CoinMarketModel] {
        guard let datas = json.array else {
            return []
        }
        let tabArray: [CoinMarketModel] = datas.compactMap { (settingJSON) -> CoinMarketModel? in
            guard let title = settingJSON["title"].string,
                let price = settingJSON["price"].string,
                let change = settingJSON["change"].string,
                let url = settingJSON["url"].string,
                let img = settingJSON["img"].string else {
                    return nil
            }
            let model = CoinMarketModel.init(title: title, price: price, change: change, url: url, img: img)
            return model
        }
        return tabArray
    }
    
    init() {
        
    }
    
    lazy var timer : Observable<NSInteger> = { return Observable<NSInteger>.interval(10, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()

    var timerSub: Disposable?

    func launch() {
        Server.instance.getMarketTest().subscribe().disposed(by: bag)
        
//        self.timerSub = timer.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
//
//            guard let `self` = self else {
//                return
//            }
//            Server.instance.getQuotesTest().subscribe().disposed(by: self.bag)
//        })
    }
}
