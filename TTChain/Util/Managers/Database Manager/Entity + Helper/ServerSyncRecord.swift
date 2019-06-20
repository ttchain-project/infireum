//
//  ServerSyncRecord.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
extension ServerSyncRecord {
    static func markEntitySyncRecord<E: NSManagedObject>(entityType: E.Type) {
        let current = Date()
        DB.instance.create(type: ServerSyncRecord.self, setup: {
            record in
            record.syncIdentityName = entityType.nameOfClass
            record.syncDate = current as NSDate
        })
    }
}
