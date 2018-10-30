//
//  LightningTransRecord+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/27.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension LightningTransRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LightningTransRecord> {
        return NSFetchRequest<LightningTransRecord>(entityName: "LightningTransRecord")
    }

    @NSManaged public var block: Int64
    @NSManaged public var date: NSDate?
    @NSManaged public var feeAmt: NSDecimalNumber?
    @NSManaged public var feeCoinID: String?
    @NSManaged public var feeRate: NSDecimalNumber?
    @NSManaged public var fromAddress: String?
    @NSManaged public var fromAmt: NSDecimalNumber?
    @NSManaged public var fromCoinID: String?
    @NSManaged public var note: String?
    @NSManaged public var status: Int16
    @NSManaged public var syncDate: NSDate?
    @NSManaged public var toAddress: String?
    @NSManaged public var toAmt: NSDecimalNumber?
    @NSManaged public var toCoinID: String?
    @NSManaged public var totalFee: NSDecimalNumber?
    @NSManaged public var txID: String?
    @NSManaged public var confirmations: Int64
    @NSManaged public var coins: NSOrderedSet?

}

// MARK: Generated accessors for coins
extension LightningTransRecord {

    @objc(insertObject:inCoinsAtIndex:)
    @NSManaged public func insertIntoCoins(_ value: Coin, at idx: Int)

    @objc(removeObjectFromCoinsAtIndex:)
    @NSManaged public func removeFromCoins(at idx: Int)

    @objc(insertCoins:atIndexes:)
    @NSManaged public func insertIntoCoins(_ values: [Coin], at indexes: NSIndexSet)

    @objc(removeCoinsAtIndexes:)
    @NSManaged public func removeFromCoins(at indexes: NSIndexSet)

    @objc(replaceObjectInCoinsAtIndex:withObject:)
    @NSManaged public func replaceCoins(at idx: Int, with value: Coin)

    @objc(replaceCoinsAtIndexes:withCoins:)
    @NSManaged public func replaceCoins(at indexes: NSIndexSet, with values: [Coin])

    @objc(addCoinsObject:)
    @NSManaged public func addToCoins(_ value: Coin)

    @objc(removeCoinsObject:)
    @NSManaged public func removeFromCoins(_ value: Coin)

    @objc(addCoins:)
    @NSManaged public func addToCoins(_ values: NSOrderedSet)

    @objc(removeCoins:)
    @NSManaged public func removeFromCoins(_ values: NSOrderedSet)

}
