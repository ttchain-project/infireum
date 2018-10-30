//
//  CoinRate+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension CoinRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinRate> {
        return NSFetchRequest<CoinRate>(entityName: "CoinRate")
    }

    @NSManaged public var fromCoinID: String?
    @NSManaged public var rate: NSDecimalNumber?
    @NSManaged public var syncDate: NSDate?
    @NSManaged public var toCoinID: String?
    @NSManaged public var coins: NSOrderedSet?

}

// MARK: Generated accessors for coins
extension CoinRate {

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
