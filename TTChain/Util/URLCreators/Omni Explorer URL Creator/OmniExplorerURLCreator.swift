//
//  OmniExplorerURLCreator.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/18.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
class OmniExplorerCreator {
    private static let base = "https://omniexplorer.info/tx/"
    static func url(ofTxID id: String) -> URL {
        return URL.init(string: base + id)!
    }
}
