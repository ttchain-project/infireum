//
//  Wallet+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/5.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension Wallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }

    @NSManaged public var address: String?
    @NSManaged public var eMnemonic: String?
    @NSManaged public var encryptedPKey: String?
    @NSManaged public var ePwd: String?
    @NSManaged public var identityID: String?
    @NSManaged public var isFromSystem: Bool
    @NSManaged public var name: String?
    @NSManaged public var pwdHint: String?
    @NSManaged public var chainType: Int16
    @NSManaged public var walletMainCoinID: String?
    @NSManaged public var assets: NSOrderedSet?
    @NSManaged public var coinSelections: NSOrderedSet?
    @NSManaged public var identity: Identity?
    @NSManaged public var subAddresses: NSOrderedSet?
    @NSManaged public var mainCoin: Coin?

}

// MARK: Generated accessors for assets
extension Wallet {

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
extension Wallet {

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

// MARK: Generated accessors for subAddresses
extension Wallet {

    @objc(insertObject:inSubAddressesAtIndex:)
    @NSManaged public func insertIntoSubAddresses(_ value: SubAddress, at idx: Int)

    @objc(removeObjectFromSubAddressesAtIndex:)
    @NSManaged public func removeFromSubAddresses(at idx: Int)

    @objc(insertSubAddresses:atIndexes:)
    @NSManaged public func insertIntoSubAddresses(_ values: [SubAddress], at indexes: NSIndexSet)

    @objc(removeSubAddressesAtIndexes:)
    @NSManaged public func removeFromSubAddresses(at indexes: NSIndexSet)

    @objc(replaceObjectInSubAddressesAtIndex:withObject:)
    @NSManaged public func replaceSubAddresses(at idx: Int, with value: SubAddress)

    @objc(replaceSubAddressesAtIndexes:withSubAddresses:)
    @NSManaged public func replaceSubAddresses(at indexes: NSIndexSet, with values: [SubAddress])

    @objc(addSubAddressesObject:)
    @NSManaged public func addToSubAddresses(_ value: SubAddress)

    @objc(removeSubAddressesObject:)
    @NSManaged public func removeFromSubAddresses(_ value: SubAddress)

    @objc(addSubAddresses:)
    @NSManaged public func addToSubAddresses(_ values: NSOrderedSet)

    @objc(removeSubAddresses:)
    @NSManaged public func removeFromSubAddresses(_ values: NSOrderedSet)

}
