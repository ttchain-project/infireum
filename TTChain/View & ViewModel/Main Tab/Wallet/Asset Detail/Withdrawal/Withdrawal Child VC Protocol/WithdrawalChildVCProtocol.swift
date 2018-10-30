//
//  WithdrawalChildVC.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift

protocol WithdrawalChildVC {
    var preferedHeight: CGFloat { get }
    var isAllFieldsHaveValue: Observable<Bool> { get }
}
