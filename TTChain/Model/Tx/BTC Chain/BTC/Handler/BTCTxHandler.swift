//
//  BTCTxHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/31.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class BTCTxHandler: TxHandler {
    typealias Record = TransRecord
    typealias Fetcher = BTCTxFetcher
    typealias Filter = BTCTxFilter
    var fetcher: BTCTxFetcher = BTCTxFetcher.init()
    var filter: Filter
    
    //Will not used curPage and offset now.
    var curPage: Int = 0
    var offset: Int = 20
    
    var asset: Asset
    var address: String { return asset.wallet?.address ?? "" }
    
    var start: Int = 0
    var end: Int = 20
    
    var didReachedSearchLine: Bool = false
    
    internal lazy var records: BehaviorRelay<[TransRecord]> = {
        let records = TransRecord.getAllRecords(ofAsset: asset) ?? []
        return BehaviorRelay.init(value: records)
    }()
    
    required init(asset: Asset, filter: Filter) {
        self.asset = asset
        self.filter = filter
        configRecords()
    }
    
    private func configRecords() {
        if let localRecords = TransRecord.getAllRecords(ofAsset: asset) {
            records.accept(localRecords)
        }
    }
    
    func loadCurrentPage() -> RxAPIVoidResponse {
        guard !didReachedSearchLine else { return RxAPIResponse.just(.success(())) }
        return fetcher.getTxs(address: address, start: start, end: end)
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let element):
                    if !element.txs.isEmpty {
                        self.adjustInputVarFromRecordUpdateIfNeeded(start: self.start,
                                                                    end: self.end,
                                                                    txs: element.txs)
                    }
                    
                    self.refresh(withSourceTxs: element.txs)
                    self.didReachedSearchLine = element.reachEnd
                    
                    return RxAPIVoidResponse.ElementType.success(())
                }
        }
    }
    
    func moveToNextPage() {
        start += offset
        end += offset
    }
    
    func reset() {
        start = 0
        end = offset
        didReachedSearchLine = false
    }
    
    private func adjustInputVarFromRecordUpdateIfNeeded(start: Int,
                                                        end: Int,
                                                        txs: [Fetcher.Tx]) {
        defer {
            print(#function)
            print("result:\nstart: \(self.start), end:\(self.end)")
        }
        
        let recordBeforeUpdate = records.value
        guard !txs.isEmpty else {
            return
        }
        
        //Local is empty while there are records in remote, just move to page.
        guard !recordBeforeUpdate.isEmpty else {
            moveToNextPage()
            return
        }
        
        
        let bottomTx = txs.last!
        let bottomBlock_tx = bottomTx.blockHeight
        
//        let topTx = txs[0]
//        let topBlock_tx = topTx.blockHeight
        
        let bottomLocalRecord = recordBeforeUpdate.last!
        let bottomBlock_local = Int(bottomLocalRecord.block)
        
        let topLocalRecord = recordBeforeUpdate[0]
        let topBlock_local = Int(topLocalRecord.block)
        
        
        if bottomBlock_tx > topBlock_local {
            //Case 1: Has not reached the local block range
            moveToNextPage()
            return
//        }
        }else if bottomBlock_tx < bottomBlock_local {
            //The tx has cover the whole local range, move start to the union txid set count + 1
            
            //The number of distinct txids in union set of txs and local records
            let txids = txs.map { $0.txid } + recordBeforeUpdate.filter { $0.txID != nil }.map { $0.txID! }
            
            let numberOfDistinctTxIDs = Set.init(txids).count
            
            self.start = numberOfDistinctTxIDs + 1
            self.end = numberOfDistinctTxIDs + offset
            return
        }else {
            //bottomBlock_tx > bottomBlock_tx
            //The tx has not reach the bottom of local range, keep paging to avoid some data loss between the gap.
            moveToNextPage()
            return
        }
        
    }
    
    func recordsMapping(withSourceTxs txs: [Fetcher.Tx]) -> [TransRecord]? {
        let _ = txs.mapToTransRecords(fromAddress: address)
        return TransRecord.getAllRecords(ofAsset: asset)?.sorted(by: { ($0.date! as Date) > ($1.date! as Date) })
    }
}
