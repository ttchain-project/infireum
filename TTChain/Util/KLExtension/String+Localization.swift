//
//  String+Localization.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/11/7.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

class StringResourceUtility {
    static func Localizer(tableName: String?) -> (_ key: String, _ params: CVaListPointer) -> String {
        return { (key: String, params: CVaListPointer) in
            let content = NSLocalizedString(key, tableName: tableName, comment: "")
            return NSString(format: content, arguments: params) as String
        }
    }
}

extension String {
    func format(with params: CVarArg...) -> String {
        let t = StringResourceUtility.Localizer(tableName: nil)
        return withVaList(params) { t(self, $0) }
    }
}
