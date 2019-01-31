//
//  USDTTxHandler.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/31.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class USDTTxHandler: TxHandler {
    
    typealias Record = TransRecord
    typealias Fetcher = USDTTxFetcher
    typealias Filter = USDTTXFilter
    var fetcher: USDTTxFetcher = USDTTxFetcher.init()
    var filter: Filter

    var curPage: Int = 1
    var offset: Int = 20

    var asset: Asset
    var address: String { return asset.wallet!.address! }
    
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
        return fetcher.getTxs(address: address, start: curPage, end: curPage)
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let element):
                    if !element.txs.isEmpty {
                        self.updateOffSetsFromTx(element: element)
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
        curPage += 1
    }
    
    func reset() {
        start = 1
        end = offset
        didReachedSearchLine = false
    }
    
    func updateOffSetsFromTx(element: TxFetcherElement<USDTTx>) {
        if element.reachEnd {
            return
        }else {
            self.moveToNextPage()
        }
    }
    
    func recordsMapping(withSourceTxs txs: [Fetcher.Tx]) -> [TransRecord]? {
        let _ = txs.mapToTransRecords(fromAddress: address)
        return TransRecord.getAllRecords(ofAsset: asset)?.sorted(by: { ($0.date! as Date) > ($1.date! as Date) })
    }
}
