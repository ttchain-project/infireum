//
//  TransferRecordsOptionsSelectBase.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
protocol TransferRecordsOptionsSingleSelectBase {
    associatedtype Source: Equatable
    var sourceManager: SingleSelectRxDataSourceManager<Source> { get set }
}

protocol TransferRecordsOptionsSingleCancellableSelectBase {
    associatedtype Source: Equatable
    var sourceManager: SingleCancellableSelectRxDataSourceManager<Source> { get set }
}

protocol TransferRecordsOptionsMultiSelectBase {
    associatedtype Source: Equatable
    var sourceManager: MultiSelectRxDataSourceManager<Source> { get set }
}


enum TransRecordListsStatusOptions {
    case deposit
    case withdrawal
    case failed
    
    var name: String {
        let dls = LM.dls
        switch self {
        case .deposit:
            return dls.txRecord_btn_deposit
        case .withdrawal:
            return dls.txRecord_btn_withdrawal
        case.failed:
            return dls.txRecord_btn_fail
        }
    }
}

protocol RxTransReocrdChainTypeOptionsProvider {
    var selectedMainCoin: Observable<Coin> { get }
}

protocol RxTransReocrdWalletOptionsProvider {
    var selectedWallet: Observable<Wallet> { get }
}

protocol RxTransReocrdCoinOptionsProvider {
    var selectedCoin: Observable<Coin?> { get }
}

protocol RxTransReocrdStatusOptionsProvider {
    var selectedStatus: Observable<TransRecordListsStatusOptions?> { get }
}

typealias RxTransRecordSortingOptionsProvider = RxTransReocrdChainTypeOptionsProvider & RxTransReocrdWalletOptionsProvider & RxTransReocrdCoinOptionsProvider & RxTransReocrdStatusOptionsProvider
