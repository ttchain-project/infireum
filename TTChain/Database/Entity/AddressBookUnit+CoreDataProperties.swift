//
//  AddressBookUnit+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/5.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension AddressBookUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddressBookUnit> {
        return NSFetchRequest<AddressBookUnit>(entityName: "AddressBookUnit")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var identityID: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var chainType: Int16
    @NSManaged public var mainCoinID: String?
    @NSManaged public var identity: Identity?
    @NSManaged public var mainCoin: Coin?

}
