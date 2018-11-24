//
//  Paramenter.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/16.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation

protocol Paramenter: Codable {
    func asDictionary() -> [String: Any]
}

extension Paramenter {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self), let dictionaryResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any], let dictionary = dictionaryResult else { fatalError() }
        return dictionary
    }
}
