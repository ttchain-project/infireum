//
//  WithdrawalETFFeeInfoModeBase.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WithdrawalETFFeeInfoModeBase {
    var gasInfo: Observable<(gasPrice: Decimal?, gas: Decimal?)> { get }
    func updateGas(_ gas: Decimal?)
    func updateGasPrice(_ gasPrice: Decimal?)
}
