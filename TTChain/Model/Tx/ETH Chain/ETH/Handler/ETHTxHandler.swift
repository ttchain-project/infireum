//
//  ETHTxHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/2.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class ETHTxHandler: TxHandler {
    typealias Record = TransRecord
    
    typealias Fetcher = ETHTxFetcher
    typealias Filter = ETHTxFilter
    
    var fetcher: ETHTxFetcher
    var filter: ETHTxFilter
    
    required init(asset: Asset, filter: Filter) {
        self.asset = asset
        self.filter = filter
        self.fetcher = ETHTxFetcher.init()
    }
    
    
    var asset: Asset
    
    var address: String { return asset.wallet!.address! }
    
    var curPage: Int = 0
    
    var offset: Int = 20
    
    var didReachedSearchLine: Bool = false
    
    internal lazy var records: BehaviorRelay<[TransRecord]> = {
        let records = TransRecord.getAllRecords(ofAsset: asset) ?? []
        return BehaviorRelay.init(value: records)
    }()

    func loadCurrentPage() -> RxAPIVoidResponse {
        guard !didReachedSearchLine else { return RxAPIResponse.just(.success(()))}
        var currentBlock: Int = 0
        return Server.instance.getETHBlockHeight()
            .flatMap {
                [unowned self]
                result -> RxAPIResponse<TxFetcherElement<Fetcher.Tx>> in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.just(.failed(error: err))
                case .success(let model):
                    let block = model.blockHeight
                    currentBlock = block
                    
                    let goBackBlocksAmt = 86400 * C.BlockchainAPI.maxTracingTxRecordDays / C.BlockchainAPI.blockSpeed
                    let calculatedStartBlock = block - goBackBlocksAmt
                    let startBlock = self.asset.latestBlockHeightCache ?? calculatedStartBlock
                    guard startBlock <= block else {
                        
                        return RxAPIResponse.just(.success(TxFetcherElement(txs: [], reachEnd: true)))
                    }
                    
                    return self.fetcher.getTxs(address: self.address, startBlock: startBlock, endBlock: C.BlockchainAPI.Etherscan.maxBlock)
                }
            }
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIVoidResponse.ElementType.failed(error: err)
                case .success(let element):
                    //Once the search is finished, assume it is all finished
            
                    self.asset.setBlockHeight(currentBlock)
                    
                    
                    let filteredTxsTuple = self.filter.filter(source: element.txs)
                    //Save the error ERC-20 token tx
                    self.preSaveUnusedTxs(unusedTxs: filteredTxsTuple.unused)
                    self.refresh(withSourceTxs: filteredTxsTuple.valid)
                    self.didReachedSearchLine = true
                    return RxAPIVoidResponse.ElementType.success(())
                }
        }
    }
    
    
    private func preSaveUnusedTxs(unusedTxs txs: [Fetcher.Tx]) {
        let tokenTxsContructors = [TokenTx]().merge(withEthErrorTxs: txs, onlyMergeSpecificCoin: nil).map {
            $0.transformToSyncConcstructor()
        }
        
        TransRecord.syncEntities(constructors: tokenTxsContructors)
    }
    
    func recordsMapping(withSourceTxs txs: [Fetcher.Tx]) -> [TransRecord]? {
        let _ = txs.mapToTransRecords()
        return TransRecord.getAllRecords(ofAsset: asset)?.sorted(by: { ($0.date! as Date) > ($1.date! as Date) })
    }
}
