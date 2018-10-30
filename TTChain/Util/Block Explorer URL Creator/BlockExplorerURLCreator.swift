//
//  BlockExplorerURLCreator.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class BlockExplorerURLCreator {
    private static let base = "https://blockexplorer.com/tx/"
    static func url(ofTxID id: String) -> URL {
        return URL.init(string: base + id)!
    }
}
