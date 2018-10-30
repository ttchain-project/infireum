//
//  BTCTxFetcher.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class BTCTxFetcher: TxFetcher {
    
    typealias Tx = BTCTx
    
    
    func getTxs(address: String, page: Int, offset: Int) -> RxAPIResponse<TxFetcherElement<BTCTx>> {
        let start = page * offset
        let end = start * offset
        return getTxs(address: address, start: start, end: end)
    }
    
    func getTxs(address: String, start: Int, end: Int) -> RxAPIResponse<TxFetcherElement<BTCTx>> {
        return Server.instance.getBTCRxRecords(ofAddress: address, from: start, to: end)
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    var isEnd = false
                    if model.to < end {
                        isEnd = true
                    }else if model.txs.isEmpty {
                        isEnd = true
                    }
                    else if let latestDate = model.txs.last?.date {
                        let isLastDateGreaterThanMaxTracingDays = Date().timeIntervalSince(latestDate) > Double(C.BlockchainAPI.maxTracingTxRecordDays * 86400)
                        isEnd = isLastDateGreaterThanMaxTracingDays
                    }
                    
                    let element = TxFetcherElement(txs: model.txs, reachEnd: isEnd)
                    return RxAPIResponse.ElementType.success(
                        element
                    )
                }
        }
    }
}
