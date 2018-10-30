//
//  TxFetcher.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

struct TxFetcherElement<Tx> {
    let txs: [Tx]
    let reachEnd: Bool
}

protocol TxFetcher {
    associatedtype Tx
    func getTxs(address: String, page: Int, offset: Int) -> RxAPIResponse<TxFetcherElement<Tx>>
}


