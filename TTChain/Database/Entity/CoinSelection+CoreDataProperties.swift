//
//  CoinSelection+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension CoinSelection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinSelection> {
        return NSFetchRequest<CoinSelection>(entityName: "CoinSelection")
    }

    @NSManaged public var walletEPKey: String?
    @NSManaged public var coinIdentifier: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var coin: Coin?
    @NSManaged public var wallet: Wallet?

}
