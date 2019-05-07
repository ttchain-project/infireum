//
//  BTCFeeCalculator.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class BTCFeeCalculator: NSObject {
    static func txSizeInByte(ofInfo info: WithdrawalInfo, unspents: [Unspent]) -> Int {
        //in*180 + out*34 + 10 plus or minus 'in'
        let ins = unspents.count
        let outs: Int = (info.withdrawalAmt < unspents.map{ $0.amount.decimalValue }.reduce(0, +)) ? 2 : 1
        return ins * 180 + outs * 34 + 10 + ins
    }
    
    static func txSizeInByte(ofLTInfo info: LightningTransRecordCreateSource, unspents: [Unspent]) -> Int {
        //in*180 + out*34 + 10 plus or minus 'in'
        let ins = unspents.count
        let outs: Int = (info.from.amt < unspents.map{ $0.amount.decimalValue }.reduce(0, +)) ? 2 : 1
        return ins * 180 + outs * 34 + 10 + ins
    }
}
