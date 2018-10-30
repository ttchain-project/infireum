//
//  CoinToFiatRate+CoreDataProperties.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//
//

import Foundation
import CoreData


extension CoinToFiatRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinToFiatRate> {
        return NSFetchRequest<CoinToFiatRate>(entityName: "CoinToFiatRate")
    }

    @NSManaged public var fromCoinID: String?
    @NSManaged public var rate: NSDecimalNumber?
    @NSManaged public var syncDate: NSDate?
    @NSManaged public var toFiatID: Int16
    @NSManaged public var coin: Coin?
    @NSManaged public var fiat: Fiat?

}
