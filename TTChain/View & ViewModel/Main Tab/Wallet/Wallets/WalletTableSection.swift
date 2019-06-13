//
//  WalletTableSection.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/13.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfTable : AnimatableSectionModelType{
    
    var identity: String {
        return self.header.identifier!
    }
    
    typealias Identity = String
    
    init(original: SectionOfTable, items: [Asset]) {
        self = original
        self.items = items
        self.isShowing = false
    }
    
    init(header:Coin) {
        self.header = header
        self.items = []
        self.isShowing = false
    }
    
    typealias Item = Asset
    let header: Coin
    var items: [Item]
    var isShowing:Bool = false
}

extension Asset:IdentifiableType {
    public var identity: Int {
        return (self.coinID! + (self.walletEPKey ?? "")).hashValue
    }
    public typealias Identity = Int
}
