//
//  LangManager.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias LangResponder = (Lang) -> Void

enum Lang: Int16 {
    case zh_cn = 0
    case zh_tw = 1
    case en_us = 2
    
    static var `default`: Lang { return .en_us }
    
    var localizedName: String {
        switch self {
        case .zh_cn: return LM.dls.lang_zh_cn
        case .zh_tw: return LM.dls.lang_zh_tw
        case .en_us: return LM.dls.lang_en_us
        }
    }
    
    var _db_name: String {
        switch self {
        case .en_us: return "en-us"
        case .zh_cn: return "zh-cn"
        case .zh_tw: return "zh-tw"
        }
    }
    
    var dls: DLS {
        switch self {
            //FIXME: There's no dls en use now
        case .en_us: return DLS_EN_US()
        case .zh_cn: return DLS_ZH_CN()
        case .zh_tw: return DLS_ZH_TW()
        }
    }
    
    static var supportLangs: [Lang] { return [.zh_cn,.zh_tw,.en_us] }
}

typealias LM = LangManager

class LangManager {
    static let instance: LangManager = LangManager.init()
    private let bag: DisposeBag = DisposeBag.init()
    
    lazy var lang: BehaviorRelay<Lang> = {
        guard let _dbLang = dbLang else {
            createLang(Lang.default)
            return BehaviorRelay.init(value: Lang.default)
        }
        
        let lang = Lang.init(rawValue: _dbLang.id) ?? Lang.default
        
        return BehaviorRelay.init(value: lang)
    }()
    
    private lazy var dbLang: Language? = {
        guard let langs = DB.instance.get(type: Language.self, predicate: nil, sorts: nil),
            let lang = langs.first else { return nil }
        
        return lang
    }()
    
    private func createLang(_ newLang: Lang) {
        let lang = DB.instance.create(type: Language.self, setup: { (language) in
            let lang = Lang.default
            language.id = Int16(lang.rawValue)
            language.name = lang._db_name
        })
        
        if let _lang = lang {
            dbLang = _lang
        }else {
            warning("Unable to store default language")
        }
    }
    
    init() {
        lang.asObservable().subscribe(onNext: {
            [unowned self]
            _lang in
            self.updateDBLangIfNeeded(newLang: _lang)
        })
        .disposed(by: bag)
        
        //Test timer
//        #if DEBUG
//        Observable<Int>.interval(3, scheduler: MainScheduler.asyncInstance)
//            .map { return $0 % 3 }
//            .map { Lang.init(rawValue: Int16($0))! }
//            .debug("Test auto lang update")
//            .bind(to: lang)
//            .disposed(by: bag)
//        #endif
    }
    
    private func updateDBLangIfNeeded(newLang _lang: Lang) {
        guard let _dbLang = self.dbLang else {
            self.createLang(_lang)
            return
        }
        
        if _lang.rawValue != _dbLang.id {
            _dbLang.id = _lang.rawValue
            _dbLang.name = _lang._db_name
            if !DB.instance.update() {
                warning("Failed to update Language")
            }
        }
    }
}

// MARK: - Helper
extension LangManager {
    static var dls: DLS {
        return instance.lang.value.dls
    }
}
