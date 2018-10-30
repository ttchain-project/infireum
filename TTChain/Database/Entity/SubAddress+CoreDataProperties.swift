//
//  SubAddress+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension SubAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubAddress> {
        return NSFetchRequest<SubAddress>(entityName: "SubAddress")
    }

    @NSManaged public var mainAddress: String?
    @NSManaged public var subAddress: String?
    @NSManaged public var wallet: Wallet?

}
