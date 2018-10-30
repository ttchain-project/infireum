//
//  TransRecordStatus.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
enum TransRecordStatus: Int16 {
    case success = 0
    case failed = 99
    
    static var allCases: [TransRecordStatus] {
        return [.success, .failed]
    }
}

typealias LightningTransRecordStatus = TransRecordStatus

