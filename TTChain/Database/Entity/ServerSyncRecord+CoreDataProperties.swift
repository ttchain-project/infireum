//
//  ServerSyncRecord+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension ServerSyncRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServerSyncRecord> {
        return NSFetchRequest<ServerSyncRecord>(entityName: "ServerSyncRecord")
    }

    @NSManaged public var syncDate: NSDate?
    @NSManaged public var syncIdentityName: String?

}
