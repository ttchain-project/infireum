//
//  CICTxFetcher.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class CICTxFetcher: TxFetcher {
    
    typealias Tx = CICTx
//    func getTxs(address: String) -> RxAPIResponse<TxFetcherElement<CICTx>> {
//        return getTxs(address: address)
//    }
    
    var mainCoin: Coin
    init(mainCoin: Coin) {
        self.mainCoin = mainCoin
    }
    
    func getTxs(address: String, page: Int = 0, offset: Int = 0) -> RxAPIResponse<TxFetcherElement<CICTx>> {
        return Server.instance.getCICTxRecords(ofAddress: address, mainCoin: mainCoin)
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    let element = TxFetcherElement(txs: model.txs,
                                                   reachEnd: true)
                    return RxAPIResponse.ElementType.success(
                        element
                    )
                }
        }
    }
}
