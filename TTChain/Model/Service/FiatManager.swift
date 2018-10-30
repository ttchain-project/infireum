//
//  FiatHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

/// Handle all fiat switch here, it will provide a relay to continuously update identitiy prefer fiat.
/// PLEASE REMEMBER: Always use this class to manage fiat update.
class FiatManager {
    static let instance: FiatManager = FiatManager.init()
    private(set) lazy var fiat: BehaviorRelay<Fiat> = {
        return BehaviorRelay.init(value: getIdentityFiat())
    }()
    
    func switchFiat(_ fiat: Fiat) {
        guard let identity = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil)?.first else {
            return
        }
        
        identity.prefFiatID = fiat.id
        DB.instance.update()
        updateFiat()
    }
    
    private func updateFiat() {
        fiat.accept(getIdentityFiat())
    }
    
    private func getIdentityFiat() -> Fiat {
        guard let preferFiat = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil)?.first?.fiat else {
            guard let _fiat = DB.instance.get(type: Fiat.self, predicate: nil, sorts: nil)?.first else {
                fatalError()
            }
            
            return errorDebug(response: _fiat)
        }
        
        return preferFiat
    }
}
