//
//  WithdrawalFeenfoProvider.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
enum WithdrawalFeeInfoValidity {
    case emptyFee
    case valid
}

protocol WithdrawalFeeInfoProvider {
    typealias FeeInfo = (rate: Decimal, amt: Decimal, coin: Coin, option: FeeManager.Option?)
    var isFeeInfoCompleted: Observable<Bool> { get }
    func getFeeInfo() -> FeeInfo?
    func checkValidity() -> WithdrawalFeeInfoValidity
}
