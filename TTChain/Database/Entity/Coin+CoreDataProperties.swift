//
//  Coin+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/5.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension Coin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coin> {
        return NSFetchRequest<Coin>(entityName: "Coin")
    }

    @NSManaged public var chainName: String?
    @NSManaged public var contract: String?
    @NSManaged public var digit: Int16
    @NSManaged public var fullname: String?
    @NSManaged public var icon: NSData?
    @NSManaged public var identifier: String?
    @NSManaged public var inAppName: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var isDefault: Bool
    @NSManaged public var isDefaultSelected: Bool
    @NSManaged public var chainType: Int16
    @NSManaged public var walletMainCoinID: String?
    @NSManaged public var assets: NSOrderedSet?
    @NSManaged public var coinSelections: NSOrderedSet?
    @NSManaged public var coinToCoinRates: NSOrderedSet?
    @NSManaged public var coinToFiatRates: NSOrderedSet?
    @NSManaged public var lightningTransRecords: NSOrderedSet?
    @NSManaged public var transRecords: NSOrderedSet?
    @NSManaged public var asMainInWallets: NSOrderedSet?
    @NSManaged public var asMainInAddressbookUnits: NSOrderedSet?

}

// MARK: Generated accessors for assets
extension Coin {

    @objc(insertObject:inAssetsAtIndex:)
    @NSManaged public func insertIntoAssets(_ value: Asset, at idx: Int)

    @objc(removeObjectFromAssetsAtIndex:)
    @NSManaged public func removeFromAssets(at idx: Int)

    @objc(insertAssets:atIndexes:)
    @NSManaged public func insertIntoAssets(_ values: [Asset], at indexes: NSIndexSet)

    @objc(removeAssetsAtIndexes:)
    @NSManaged public func removeFromAssets(at indexes: NSIndexSet)

    @objc(replaceObjectInAssetsAtIndex:withObject:)
    @NSManaged public func replaceAssets(at idx: Int, with value: Asset)

    @objc(replaceAssetsAtIndexes:withAssets:)
    @NSManaged public func replaceAssets(at indexes: NSIndexSet, with values: [Asset])

    @objc(addAssetsObject:)
    @NSManaged public func addToAssets(_ value: Asset)

    @objc(removeAssetsObject:)
    @NSManaged public func removeFromAssets(_ value: Asset)

    @objc(addAssets:)
    @NSManaged public func addToAssets(_ values: NSOrderedSet)

    @objc(removeAssets:)
    @NSManaged public func removeFromAssets(_ values: NSOrderedSet)

}

// MARK: Generated accessors for coinSelections
extension Coin {

    @objc(insertObject:inCoinSelectionsAtIndex:)
    @NSManaged public func insertIntoCoinSelections(_ value: CoinSelection, at idx: Int)

    @objc(removeObjectFromCoinSelectionsAtIndex:)
    @NSManaged public func removeFromCoinSelections(at idx: Int)

    @objc(insertCoinSelections:atIndexes:)
    @NSManaged public func insertIntoCoinSelections(_ values: [CoinSelection], at indexes: NSIndexSet)

    @objc(removeCoinSelectionsAtIndexes:)
    @NSManaged public func removeFromCoinSelections(at indexes: NSIndexSet)

    @objc(replaceObjectInCoinSelectionsAtIndex:withObject:)
    @NSManaged public func replaceCoinSelections(at idx: Int, with value: CoinSelection)

    @objc(replaceCoinSelectionsAtIndexes:withCoinSelections:)
    @NSManaged public func replaceCoinSelections(at indexes: NSIndexSet, with values: [CoinSelection])

    @objc(addCoinSelectionsObject:)
    @NSManaged public func addToCoinSelections(_ value: CoinSelection)

    @objc(removeCoinSelectionsObject:)
    @NSManaged public func removeFromCoinSelections(_ value: CoinSelection)

    @objc(addCoinSelections:)
    @NSManaged public func addToCoinSelections(_ values: NSOrderedSet)

    @objc(removeCoinSelections:)
    @NSManaged public func removeFromCoinSelections(_ values: NSOrderedSet)

}

// MARK: Generated accessors for coinToCoinRates
extension Coin {

    @objc(insertObject:inCoinToCoinRatesAtIndex:)
    @NSManaged public func insertIntoCoinToCoinRates(_ value: CoinRate, at idx: Int)

    @objc(removeObjectFromCoinToCoinRatesAtIndex:)
    @NSManaged public func removeFromCoinToCoinRates(at idx: Int)

    @objc(insertCoinToCoinRates:atIndexes:)
    @NSManaged public func insertIntoCoinToCoinRates(_ values: [CoinRate], at indexes: NSIndexSet)

    @objc(removeCoinToCoinRatesAtIndexes:)
    @NSManaged public func removeFromCoinToCoinRates(at indexes: NSIndexSet)

    @objc(replaceObjectInCoinToCoinRatesAtIndex:withObject:)
    @NSManaged public func replaceCoinToCoinRates(at idx: Int, with value: CoinRate)

    @objc(replaceCoinToCoinRatesAtIndexes:withCoinToCoinRates:)
    @NSManaged public func replaceCoinToCoinRates(at indexes: NSIndexSet, with values: [CoinRate])

    @objc(addCoinToCoinRatesObject:)
    @NSManaged public func addToCoinToCoinRates(_ value: CoinRate)

    @objc(removeCoinToCoinRatesObject:)
    @NSManaged public func removeFromCoinToCoinRates(_ value: CoinRate)

    @objc(addCoinToCoinRates:)
    @NSManaged public func addToCoinToCoinRates(_ values: NSOrderedSet)

    @objc(removeCoinToCoinRates:)
    @NSManaged public func removeFromCoinToCoinRates(_ values: NSOrderedSet)

}

// MARK: Generated accessors for coinToFiatRates
extension Coin {

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

// MARK: Generated accessors for lightningTransRecords
extension Coin {

    @objc(insertObject:inLightningTransRecordsAtIndex:)
    @NSManaged public func insertIntoLightningTransRecords(_ value: LightningTransRecord, at idx: Int)

    @objc(removeObjectFromLightningTransRecordsAtIndex:)
    @NSManaged public func removeFromLightningTransRecords(at idx: Int)

    @objc(insertLightningTransRecords:atIndexes:)
    @NSManaged public func insertIntoLightningTransRecords(_ values: [LightningTransRecord], at indexes: NSIndexSet)

    @objc(removeLightningTransRecordsAtIndexes:)
    @NSManaged public func removeFromLightningTransRecords(at indexes: NSIndexSet)

    @objc(replaceObjectInLightningTransRecordsAtIndex:withObject:)
    @NSManaged public func replaceLightningTransRecords(at idx: Int, with value: LightningTransRecord)

    @objc(replaceLightningTransRecordsAtIndexes:withLightningTransRecords:)
    @NSManaged public func replaceLightningTransRecords(at indexes: NSIndexSet, with values: [LightningTransRecord])

    @objc(addLightningTransRecordsObject:)
    @NSManaged public func addToLightningTransRecords(_ value: LightningTransRecord)

    @objc(removeLightningTransRecordsObject:)
    @NSManaged public func removeFromLightningTransRecords(_ value: LightningTransRecord)

    @objc(addLightningTransRecords:)
    @NSManaged public func addToLightningTransRecords(_ values: NSOrderedSet)

    @objc(removeLightningTransRecords:)
    @NSManaged public func removeFromLightningTransRecords(_ values: NSOrderedSet)

}

// MARK: Generated accessors for transRecords
extension Coin {

    @objc(insertObject:inTransRecordsAtIndex:)
    @NSManaged public func insertIntoTransRecords(_ value: TransRecord, at idx: Int)

    @objc(removeObjectFromTransRecordsAtIndex:)
    @NSManaged public func removeFromTransRecords(at idx: Int)

    @objc(insertTransRecords:atIndexes:)
    @NSManaged public func insertIntoTransRecords(_ values: [TransRecord], at indexes: NSIndexSet)

    @objc(removeTransRecordsAtIndexes:)
    @NSManaged public func removeFromTransRecords(at indexes: NSIndexSet)

    @objc(replaceObjectInTransRecordsAtIndex:withObject:)
    @NSManaged public func replaceTransRecords(at idx: Int, with value: TransRecord)

    @objc(replaceTransRecordsAtIndexes:withTransRecords:)
    @NSManaged public func replaceTransRecords(at indexes: NSIndexSet, with values: [TransRecord])

    @objc(addTransRecordsObject:)
    @NSManaged public func addToTransRecords(_ value: TransRecord)

    @objc(removeTransRecordsObject:)
    @NSManaged public func removeFromTransRecords(_ value: TransRecord)

    @objc(addTransRecords:)
    @NSManaged public func addToTransRecords(_ values: NSOrderedSet)

    @objc(removeTransRecords:)
    @NSManaged public func removeFromTransRecords(_ values: NSOrderedSet)

}

// MARK: Generated accessors for asMainInWallets
extension Coin {

    @objc(insertObject:inAsMainInWalletsAtIndex:)
    @NSManaged public func insertIntoAsMainInWallets(_ value: Wallet, at idx: Int)

    @objc(removeObjectFromAsMainInWalletsAtIndex:)
    @NSManaged public func removeFromAsMainInWallets(at idx: Int)

    @objc(insertAsMainInWallets:atIndexes:)
    @NSManaged public func insertIntoAsMainInWallets(_ values: [Wallet], at indexes: NSIndexSet)

    @objc(removeAsMainInWalletsAtIndexes:)
    @NSManaged public func removeFromAsMainInWallets(at indexes: NSIndexSet)

    @objc(replaceObjectInAsMainInWalletsAtIndex:withObject:)
    @NSManaged public func replaceAsMainInWallets(at idx: Int, with value: Wallet)

    @objc(replaceAsMainInWalletsAtIndexes:withAsMainInWallets:)
    @NSManaged public func replaceAsMainInWallets(at indexes: NSIndexSet, with values: [Wallet])

    @objc(addAsMainInWalletsObject:)
    @NSManaged public func addToAsMainInWallets(_ value: Wallet)

    @objc(removeAsMainInWalletsObject:)
    @NSManaged public func removeFromAsMainInWallets(_ value: Wallet)

    @objc(addAsMainInWallets:)
    @NSManaged public func addToAsMainInWallets(_ values: NSOrderedSet)

    @objc(removeAsMainInWallets:)
    @NSManaged public func removeFromAsMainInWallets(_ values: NSOrderedSet)

}

// MARK: Generated accessors for asMainInAddressbookUnits
extension Coin {

    @objc(insertObject:inAsMainInAddressbookUnitsAtIndex:)
    @NSManaged public func insertIntoAsMainInAddressbookUnits(_ value: AddressBookUnit, at idx: Int)

    @objc(removeObjectFromAsMainInAddressbookUnitsAtIndex:)
    @NSManaged public func removeFromAsMainInAddressbookUnits(at idx: Int)

    @objc(insertAsMainInAddressbookUnits:atIndexes:)
    @NSManaged public func insertIntoAsMainInAddressbookUnits(_ values: [AddressBookUnit], at indexes: NSIndexSet)

    @objc(removeAsMainInAddressbookUnitsAtIndexes:)
    @NSManaged public func removeFromAsMainInAddressbookUnits(at indexes: NSIndexSet)

    @objc(replaceObjectInAsMainInAddressbookUnitsAtIndex:withObject:)
    @NSManaged public func replaceAsMainInAddressbookUnits(at idx: Int, with value: AddressBookUnit)

    @objc(replaceAsMainInAddressbookUnitsAtIndexes:withAsMainInAddressbookUnits:)
    @NSManaged public func replaceAsMainInAddressbookUnits(at indexes: NSIndexSet, with values: [AddressBookUnit])

    @objc(addAsMainInAddressbookUnitsObject:)
    @NSManaged public func addToAsMainInAddressbookUnits(_ value: AddressBookUnit)

    @objc(removeAsMainInAddressbookUnitsObject:)
    @NSManaged public func removeFromAsMainInAddressbookUnits(_ value: AddressBookUnit)

    @objc(addAsMainInAddressbookUnits:)
    @NSManaged public func addToAsMainInAddressbookUnits(_ values: NSOrderedSet)

    @objc(removeAsMainInAddressbookUnits:)
    @NSManaged public func removeFromAsMainInAddressbookUnits(_ values: NSOrderedSet)

}
