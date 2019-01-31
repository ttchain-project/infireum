//
//  USDTTxFetcher.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/31.
//  Copyright © 2019 gib. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class USDTTxFetcher: TxFetcher {
    
    typealias Tx = USDTTx
    
    func getTxs(address: String, page: Int, offset: Int) -> RxAPIResponse<TxFetcherElement<USDTTx>> {
        let start = page
        let end = start
        return getTxs(address: address, start: start, end: end)
    }
    
    func getTxs(address: String, start: Int, end: Int) -> RxAPIResponse<TxFetcherElement<USDTTx>> {
        
        return Server.instance.getUSDTTxRecords(ofAddress: address, page: start).map {
            result in
            switch result {
            case .failed(error: let err):
                return RxAPIResponse.ElementType.failed(error: err)
            case .success(let model):
                var isEnd = false
                if model.currentPage < model.pages {
                    isEnd = false
                }else if model.transactions.isEmpty {
                    isEnd = true
                }
                else if let latestDate = model.transactions.last?.date {
                    let isLastDateGreaterThanMaxTracingDays = Date().timeIntervalSince(latestDate) > Double(C.BlockchainAPI.maxTracingTxRecordDays * 86400)
                    isEnd = isLastDateGreaterThanMaxTracingDays
                }
                
                let element = TxFetcherElement(txs: model.transactions, reachEnd: isEnd)
                return RxAPIResponse.ElementType.success(
                    element
                )
            }
        }
        
    }
}
