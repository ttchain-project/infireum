//
//  TxHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import CoreData

protocol TxHandler: class {
    /**
     Record is for Local Store DB, Tx is for remote raw data on the blockchain.
     */
    associatedtype Record: NSManagedObject
    associatedtype Fetcher: TxFetcher
    associatedtype Filter: TxFilter where Filter.Tx == Fetcher.Tx
    
    var fetcher: Fetcher { get set }
    
//    init(asset: Asset, filter: Filter)
//    var asset: Asset { get set }
    var filter: Filter { get set }
    var address: String { get }
    var curPage: Int { get set }
    var offset: Int { get set }
    var didReachedSearchLine: Bool { get set }
    
    var records: BehaviorRelay<[Record]> { get set }
    
    func reset()
    func loadCurrentPage() -> RxAPIVoidResponse
    func moveToNextPage()
    
    func recordsMapping(withSourceTxs txs: [Fetcher.Tx]) -> [Record]?
    func refresh(withRecrods recs: [Record])
    func refresh(withSourceTxs txs: [Fetcher.Tx])
}

extension TxHandler where Self: AnyObject {
//    var address: String {
//        return asset.wallet!.address!
//    }
    
    func reset() {
        curPage = 0
        didReachedSearchLine = false
        records.accept([])
    }
    
//    func loadCurrentPage() -> RxAPIVoidResponse {
//        return fetcher.getTxs(address: address, page: curPage, offset: offset)
//            .map {
//                [unowned self]
//                result in
//                switch result {
//                case .failed(error: let err):
//                    return RxAPIVoidResponse.ElementType.failed(error: err)
//                case .success(let element):
//                    self.moveToNextPage()
//                    self.refresh(withSourceTxs: element.txs)
//                    self.didReachedSearchLine = element.reachEnd
//                    return RxAPIVoidResponse.ElementType.success(())
//                }
//            }
//    }
    
    func moveToNextPage() {
        curPage += 1
    }
    
    func refresh(withRecrods recs: [Record]) {
        self.records.accept(recs)
    }
    
    func refresh(withSourceTxs txs: [Fetcher.Tx]) {
        if let mappedNewRecords = recordsMapping(withSourceTxs: txs) {
            return refresh(withRecrods: mappedNewRecords)
        }else {
            return errorDebug(response: ())
        }
    }
    
}



extension TxHandler where Fetcher.Tx: ERC20Tx {
    
    /// Provide a more comprehensible function name
    ///
    /// - Returns:
    func loadAllRequiredTxs() -> RxAPIVoidResponse {
        return loadCurrentPage()
    }
    
    
}

