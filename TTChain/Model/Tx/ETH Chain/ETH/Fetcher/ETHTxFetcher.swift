//
//  ETHTxFetcher.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/2.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class ETHTxFetcher: TxFetcher {
    typealias Tx = ETHTx
    
    func getTxs(address: String, page: Int, offset: Int) -> PrimitiveSequence<SingleTrait, APIResult<TxFetcherElement<ETHTx>>> {
        fatalError("Pleas use getTxs(address: String, startBlock: Int, endBlock: Int)")
//        return Server.instance.getETHTxRecords(page: page, offset: offset, ethAddress: address)
//            .map {
//                result in
//                switch result {
//                case .failed(error: let err): return RxAPIResponse.ElementType.failed(error: err)
//                case .success(let model):
//                    return RxAPIResponse.ElementType.success(TxFetcherElement(txs: model.ethTxs, reachEnd: model.originTxsCount < offset))
//                }
//        }
    }
    
    func getTxs(address: String, startBlock: Int, endBlock: Int) -> PrimitiveSequence<SingleTrait, APIResult<TxFetcherElement<ETHTx>>> {
        return Server.instance.getETHTxRecords(startBlock: startBlock, endBlock: endBlock, ethAddress: address)
            .map {
                result in
                switch result {
                case .failed(error: let err): return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    let reachEnd: Bool
                    if let lastTxs = model.ethTxs.last {
                        let txMomenet = moment(lastTxs.date)
                        let currentMomnet = moment()
                        reachEnd = Int(currentMomnet.intervalSince(txMomenet).days) >= C.BlockchainAPI.maxTracingTxRecordDays
                    }else {
                        reachEnd = true
                    }
                    
//                    let filteredTx = self.filter.filter(source: model.ethTxs)
                    return RxAPIResponse.ElementType.success(TxFetcherElement(txs: model.ethTxs, reachEnd: reachEnd))
                }
            }
    }
    
}
