//
//  Fiat+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension Fiat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fiat> {
        return NSFetchRequest<Fiat>(entityName: "Fiat")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var symbol: String?
    @NSManaged public var coinToFiatRates: NSOrderedSet?
    @NSManaged public var fiatToFiatRates: NSOrderedSet?
    @NSManaged public var identity: Identity?

}

// MARK: Generated accessors for coinToFiatRates
extension Fiat {

    @objc(insertObject:inCoinToFiatRatesAtIndex:)
    @NSManaged public func insertIntoCoinToFiatRates(_ value: CoinToFiatRate, at idx: Int)

    @objc(removeObjectFromCoinToFiatRatesAtIndex:)
    @NSManaged public func removeFromCoinToFiatRates(at idx: Int)

    @objc(insertCoinToFiatRates:atIndexes:)
    @NSManaged public func insertIntoCoinToFiatRates(_ values: [CoinToFiatRate], at indexes: NSIndexSet)

    @objc(removeCoinToFiatRatesAtIndexes:)
    @NSManaged public func removeFromCoinToFiatRates(at indexes: NSIndexSet)

    @objc(replaceObjectInCoinToFiatRatesAtIndex:withObject:)
    @NSManaged public func replaceCoinToFiatRates(at idx: Int, with value: CoinToFiatRate)

    @objc(replaceCoinToFiatRatesAtIndexes:withCoinToFiatRates:)
    @NSManaged public func replaceCoinToFiatRates(at indexes: NSIndexSet, with values: [CoinToFiatRate])

    @objc(addCoinToFiatRatesObject:)
    @NSManaged public func addToCoinToFiatRates(_ value: CoinToFiatRate)

    @objc(removeCoinToFiatRatesObject:)
    @NSManaged public func removeFromCoinToFiatRates(_ value: CoinToFiatRate)

    @objc(addCoinToFiatRates:)
    @NSManaged public func addToCoinToFiatRates(_ values: NSOrderedSet)

    @objc(removeCoinToFiatRates:)
    @NSManaged public func removeFromCoinToFiatRates(_ values: NSOrderedSet)

}

// MARK: Generated accessors for fiatToFiatRates
extension Fiat {

    @objc(insertObject:inFiatToFiatRatesAtIndex:)
    @NSManaged public func insertIntoFiatToFiatRates(_ value: FiatToFiatRate, at idx: Int)

    @objc(removeObjectFromFiatToFiatRatesAtIndex:)
    @NSManaged public func removeFromFiatToFiatRates(at idx: Int)

    @objc(insertFiatToFiatRates:atIndexes:)
    @NSManaged public func insertIntoFiatToFiatRates(_ values: [FiatToFiatRate], at indexes: NSIndexSet)

    @objc(removeFiatToFiatRatesAtIndexes:)
    @NSManaged public func removeFromFiatToFiatRates(at indexes: NSIndexSet)

    @objc(replaceObjectInFiatToFiatRatesAtIndex:withObject:)
    @NSManaged public func replaceFiatToFiatRates(at idx: Int, with value: FiatToFiatRate)

    @objc(replaceFiatToFiatRatesAtIndexes:withFiatToFiatRates:)
    @NSManaged public func replaceFiatToFiatRates(at indexes: NSIndexSet, with values: [FiatToFiatRate])

    @objc(addFiatToFiatRatesObject:)
    @NSManaged public func addToFiatToFiatRates(_ value: FiatToFiatRate)

    @objc(removeFiatToFiatRatesObject:)
    @NSManaged public func removeFromFiatToFiatRates(_ value: FiatToFiatRate)

    @objc(addFiatToFiatRates:)
    @NSManaged public func addToFiatToFiatRates(_ values: NSOrderedSet)

    @objc(removeFiatToFiatRates:)
    @NSManaged public func removeFromFiatToFiatRates(_ values: NSOrderedSet)

}
