//
//  CICTxHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class CICTxHandler: TxHandler {
    typealias Record = TransRecord
    
    typealias Fetcher = CICTxFetcher
    typealias Filter = CICTxFilter
    
    var fetcher: CICTxFetcher
    var filter: CICTxFilter
    
    required init(wallet: Wallet, specificAsset asset: Asset?, filter: Filter) {
        self.wallet = wallet
        self.asset = asset
        self.filter = filter
        self.fetcher = CICTxFetcher.init(mainCoin: wallet.mainCoin!)
    }
    
    convenience init(specificAsset asset: Asset, filter: Filter) {
        self.init(wallet: asset.wallet!,
                  specificAsset: asset,
                  filter: filter)
    }
    
    var wallet: Wallet
    var asset: Asset?
    var address: String {
        return wallet.address!
    }
    
    var curPage: Int = 0
    
    var offset: Int = 20
    
    var didReachedSearchLine: Bool = false
    
    internal lazy var records: BehaviorRelay<[TransRecord]> = {
        let records: [TransRecord]
        if let asset = asset {
            records = TransRecord.getAllRecords(ofAsset: asset) ?? []
        }else {
            records = TransRecord.getAllRecords(ofWallet: wallet) ?? []
        }
        
        return BehaviorRelay.init(value: records)
    }()
    
    func loadCurrentPage() -> RxAPIVoidResponse {
        guard !didReachedSearchLine else { return RxAPIResponse.just(.success(()))}
        return fetcher.getTxs(address: address)
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let element):
                    //Once the search is finished, assume it is all finished
                    let validTxs: [Fetcher.Tx]
                    if let coin = self.asset?.coin {
                        let filteredTxsTuple = self.filter.filter(source: element.txs,
                                                                  condition: coin)
                        validTxs = filteredTxsTuple.valid
                        self.preSaveUnusedTxs(unusedTxs: filteredTxsTuple.unused)
                    }else {
                        validTxs = element.txs
                    }
                    
                    //Save the error ERC-20 token tx
                    self.refresh(withSourceTxs: validTxs)
                    self.didReachedSearchLine = true
                    return RxAPIVoidResponse.ElementType.success(())
                }
        }
    }
    
    
    private func preSaveUnusedTxs(unusedTxs txs: [Fetcher.Tx]) {
        let tokenTxsContructors = txs.map {
            $0.transformToSyncConcstructor()
        }
        
        TransRecord.syncEntities(constructors: tokenTxsContructors)
    }
    
    func recordsMapping(withSourceTxs txs: [Fetcher.Tx]) -> [TransRecord]? {
        let _ = txs.mapToTransRecords()
        if let asset = asset {
            return TransRecord.getAllRecords(ofAsset: asset)?.sorted(by: { ($0.date! as Date) > ($1.date! as Date) })
        }else {
            return TransRecord.getAllRecords(ofWallet: wallet)?.sorted(by: { ($0.date! as Date) > ($1.date! as Date) })
        }
    }
}
