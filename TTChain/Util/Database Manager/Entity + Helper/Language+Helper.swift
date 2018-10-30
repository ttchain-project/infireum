//
//  Language+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

extension Language {
    @discardableResult static func markIdToIdentity(langId: Int16, identity: Identity)  -> Bool {
        let pred = Language.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(id), value: identity.prefLangID))
        guard let lang = DB.instance.get(type: Language.self, predicate: pred, sorts: nil)?.first else {
            return errorDebug(response: false)
        }
        
        lang.identity = identity
        identity.language = lang
        identity.prefLangID = langId
        
        return DB.instance.update()
    }
}
