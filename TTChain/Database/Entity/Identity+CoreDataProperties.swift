//
//  Identity+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/27.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension Identity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Identity> {
        return NSFetchRequest<Identity>(entityName: "Identity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var prefFiatID: Int16
    @NSManaged public var prefLangID: Int16
    @NSManaged public var ePwd: String?
    @NSManaged public var pwdHint: String?
    @NSManaged public var addressbookUnits: NSOrderedSet?
    @NSManaged public var fiat: Fiat?
    @NSManaged public var language: Language?
    @NSManaged public var wallets: NSOrderedSet?

}

// MARK: Generated accessors for addressbookUnits
extension Identity {

    @objc(insertObject:inAddressbookUnitsAtIndex:)
    @NSManaged public func insertIntoAddressbookUnits(_ value: AddressBookUnit, at idx: Int)

    @objc(removeObjectFromAddressbookUnitsAtIndex:)
    @NSManaged public func removeFromAddressbookUnits(at idx: Int)

    @objc(insertAddressbookUnits:atIndexes:)
    @NSManaged public func insertIntoAddressbookUnits(_ values: [AddressBookUnit], at indexes: NSIndexSet)

    @objc(removeAddressbookUnitsAtIndexes:)
    @NSManaged public func removeFromAddressbookUnits(at indexes: NSIndexSet)

    @objc(replaceObjectInAddressbookUnitsAtIndex:withObject:)
    @NSManaged public func replaceAddressbookUnits(at idx: Int, with value: AddressBookUnit)

    @objc(replaceAddressbookUnitsAtIndexes:withAddressbookUnits:)
    @NSManaged public func replaceAddressbookUnits(at indexes: NSIndexSet, with values: [AddressBookUnit])

    @objc(addAddressbookUnitsObject:)
    @NSManaged public func addToAddressbookUnits(_ value: AddressBookUnit)

    @objc(removeAddressbookUnitsObject:)
    @NSManaged public func removeFromAddressbookUnits(_ value: AddressBookUnit)

    @objc(addAddressbookUnits:)
    @NSManaged public func addToAddressbookUnits(_ values: NSOrderedSet)

    @objc(removeAddressbookUnits:)
    @NSManaged public func removeFromAddressbookUnits(_ values: NSOrderedSet)

}

// MARK: Generated accessors for wallets
extension Identity {

    @objc(insertObject:inWalletsAtIndex:)
    @NSManaged public func insertIntoWallets(_ value: Wallet, at idx: Int)

    @objc(removeObjectFromWalletsAtIndex:)
    @NSManaged public func removeFromWallets(at idx: Int)

    @objc(insertWallets:atIndexes:)
    @NSManaged public func insertIntoWallets(_ values: [Wallet], at indexes: NSIndexSet)

    @objc(removeWalletsAtIndexes:)
    @NSManaged public func removeFromWallets(at indexes: NSIndexSet)

    @objc(replaceObjectInWalletsAtIndex:withObject:)
    @NSManaged public func replaceWallets(at idx: Int, with value: Wallet)

    @objc(replaceWalletsAtIndexes:withWallets:)
    @NSManaged public func replaceWallets(at indexes: NSIndexSet, with values: [Wallet])

    @objc(addWalletsObject:)
    @NSManaged public func addToWallets(_ value: Wallet)

    @objc(removeWalletsObject:)
    @NSManaged public func removeFromWallets(_ value: Wallet)

    @objc(addWallets:)
    @NSManaged public func addToWallets(_ values: NSOrderedSet)

    @objc(removeWallets:)
    @NSManaged public func removeFromWallets(_ values: NSOrderedSet)

}
