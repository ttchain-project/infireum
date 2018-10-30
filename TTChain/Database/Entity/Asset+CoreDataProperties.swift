//
//  Asset+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension Asset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Asset> {
        return NSFetchRequest<Asset>(entityName: "Asset")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var coinID: String?
    @NSManaged public var walletEPKey: String?
    @NSManaged public var wallet: Wallet?
    @NSManaged public var coin: Coin?

}
