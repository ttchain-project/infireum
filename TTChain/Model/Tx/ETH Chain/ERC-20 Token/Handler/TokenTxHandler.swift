//
//  TokenTxHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class TokenTxHandler: TxHandler {
    typealias Record = TransRecord
    
    typealias Fetcher = TokenTxFetcher
    typealias Filter = TokenTxFilter
    
    var fetcher: TokenTxFetcher
    var filter: TokenTxFilter
    
    required init(wallet: Wallet, specificAsset asset: Asset?, filter: Filter) {
        self.wallet = wallet
        self.asset = asset
        self.filter = filter
        self.fetcher = TokenTxFetcher.init()
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
                    let startBlock: Int
                    if let asset = self.asset,
                        let blockCache = asset.latestBlockHeightCache {
                        startBlock = blockCache
                    }else {
                        startBlock = calculatedStartBlock
                    }
                    
                    guard startBlock <= block else {
                        
                        return RxAPIResponse.just(.success(TxFetcherElement(txs: [], reachEnd: true)))
                    }
                    
                    return self.getTxs(startBlock: startBlock,
                                       endBlock: block)
                    
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
                    if let assets = self.wallet.assets?.array as? [Asset] {
                        for asset in assets {
                            asset.setBlockHeight(currentBlock)
                        }
                    }else {
                        self.asset?.setBlockHeight(currentBlock)
                    }
                    
                    
                    self.refresh(withSourceTxs: element.txs)
                    self.didReachedSearchLine = true
                    return RxAPIVoidResponse.ElementType.success(())
                }
        }
    }
    
    
    private lazy var ethTxFetcher: ETHTxFetcher = {
        return ETHTxFetcher()
    }()
    
    private func getTxs(startBlock: Int,
                        endBlock: Int) -> RxAPIResponse<TxFetcherElement<TokenTx>> {
        let tokenResponse = self.fetcher.getTxs(address: self.address,
                                                startBlock: startBlock,
                                                endBlock: endBlock,
                                                coin: nil)
        let txResponse = ethTxFetcher.getTxs(address: address,
                                             startBlock: startBlock,
                                             endBlock: endBlock)
        
        return Observable.combineLatest(tokenResponse.asObservable(),
                                        txResponse.asObservable())
            .map {
                [unowned self]
                tokenResult, txResult -> APIResult<TxFetcherElement<TokenTx>>  in
                switch (tokenResult, txResult) {
                case (.failed(let err), _),
                     (_, .failed(let err)) :
                    
                    return .failed(error: err)
                    
                case (.success(let tokenModel), .success(let txModel)):
                    let filteredTokenTxs = self.filter.filter(source: tokenModel.txs,
                                                              condition: self.asset?.coin)
                    let filteredETHTxs = ETHTxFilter.init().filter(source: txModel.txs,
                                                                   condition: ())
                    
                    //Merge the valid token tx with the unused (ERC-20 failed) tx of eth.
                    let sameTokenTxs = filteredTokenTxs.valid
                    let diffTokenTxs = filteredTokenTxs.unused
                    
                    let ethTxs = filteredETHTxs.valid
                    let erc20FailedTxs = filteredETHTxs.unused
                    var erc20FailedTxs_sameToken: [ETHTx] = []
                    var erc20FailedTxs_diffToken: [ETHTx] = []
                    
                    for erc20FailedTx in erc20FailedTxs {
                        if let erc20FailedTxCoin = Coin.getCoin(ofContractAddress: erc20FailedTx.contract) {
                            if erc20FailedTxCoin.identifier == self.asset?.coinID {
                                erc20FailedTxs_sameToken.append(erc20FailedTx)
                            }else {
                                erc20FailedTxs_diffToken.append(erc20FailedTx)
                            }
                        }else {
                            //Cannot find local coin, skip
                            continue
                        }
                    }
                    
                    //Merge all the diff token TokenTx
                    let mergedDiffTokenTxs = diffTokenTxs.merge(
                        withEthErrorTxs: erc20FailedTxs_diffToken, onlyMergeSpecificCoin: nil
                    )
                    
                    //Save the diff token TokenTx to DB
                    self.preSaveUnusedTokenTxs(unusedTxs: mergedDiffTokenTxs)
                    //Mark the block height for all other tokens and ETH. This will prevent same loading results.
                    self
                        .markTokenTxsLatestRetrievedBlockIfPossible(
                            mergedDiffTokenTxs, height: endBlock
                        )
                    self.markETHLatestRetrievedBlock(height: endBlock)
                    
                    //Save the eth success tx to DB
                    self.preSaveUnusedETHTxs(unusedTxs: ethTxs)
                    
                    
                    //Merge the same token
                    let mergedSameTokenTxs = sameTokenTxs.merge(
                        withEthErrorTxs: erc20FailedTxs_sameToken, onlyMergeSpecificCoin: self.asset?.coin
                    )
                    
                    let eitherReachEnd = tokenModel.reachEnd || txModel.reachEnd
                    return .success(
                        TxFetcherElement.init(txs: mergedSameTokenTxs,
                                              reachEnd: eitherReachEnd)
                    )
                default:
                    //In theory should not enter here.
                    return errorDebug(response: .failed(error: GTServerAPIError.noData))
                }
            }
            .asSingle()
    }
    
    private func markETHLatestRetrievedBlock(height: Int) {
        guard let assetsOfWallet = wallet.assets?.array as? [Asset] else { return }
        guard let ethIdx = assetsOfWallet.index (where: { (asset) -> Bool in
            asset.coinID == Coin.eth_identifier
        }) else { return }
        
        let eth = assetsOfWallet[ethIdx]
        eth.setBlockHeight(height)
    }
    
    private func markTokenTxsLatestRetrievedBlockIfPossible(_ txs: [TokenTx], height: Int) {
        guard let assetsOfWallet = wallet.assets?.array as? [Asset] else { return }
        var assets: Set<Asset> = Set.init()
        for tx in txs where assetsOfWallet.contains(where: { $0.coinID == tx.coin.identifier }) {
            let idx = assetsOfWallet.index(where: {$0.coinID == tx.coin.identifier })!
            let asset = assetsOfWallet[idx]
            assets.insert(asset)
        }
        
        assets.forEach { (asset) in
            asset.setBlockHeight(height)
        }
    }
    
    private func preSaveUnusedTokenTxs(unusedTxs txs: [TokenTx]) {
        let tokenTxsContructors = txs.map {
            $0.transformToSyncConcstructor()
        }
        
        TransRecord.syncEntities(constructors: tokenTxsContructors)
    }
    
    private func preSaveUnusedETHTxs(unusedTxs txs: [ETHTx]) {
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
