//
//  FiatToFiatRate+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension FiatToFiatRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FiatToFiatRate> {
        return NSFetchRequest<FiatToFiatRate>(entityName: "FiatToFiatRate")
    }

    @NSManaged public var fromFiatID: Int16
    @NSManaged public var rate: NSDecimalNumber?
    @NSManaged public var syncDate: NSDate?
    @NSManaged public var toFiatID: Int16
    @NSManaged public var fiats: NSOrderedSet?

}

// MARK: Generated accessors for fiats
extension FiatToFiatRate {

    @objc(insertObject:inFiatsAtIndex:)
    @NSManaged public func insertIntoFiats(_ value: Fiat, at idx: Int)

    @objc(removeObjectFromFiatsAtIndex:)
    @NSManaged public func removeFromFiats(at idx: Int)

    @objc(insertFiats:atIndexes:)
    @NSManaged public func insertIntoFiats(_ values: [Fiat], at indexes: NSIndexSet)

    @objc(removeFiatsAtIndexes:)
    @NSManaged public func removeFromFiats(at indexes: NSIndexSet)

    @objc(replaceObjectInFiatsAtIndex:withObject:)
    @NSManaged public func replaceFiats(at idx: Int, with value: Fiat)

    @objc(replaceFiatsAtIndexes:withFiats:)
    @NSManaged public func replaceFiats(at indexes: NSIndexSet, with values: [Fiat])

    @objc(addFiatsObject:)
    @NSManaged public func addToFiats(_ value: Fiat)

    @objc(removeFiatsObject:)
    @NSManaged public func removeFromFiats(_ value: Fiat)

    @objc(addFiats:)
    @NSManaged public func addToFiats(_ values: NSOrderedSet)

    @objc(removeFiats:)
    @NSManaged public func removeFromFiats(_ values: NSOrderedSet)

}
