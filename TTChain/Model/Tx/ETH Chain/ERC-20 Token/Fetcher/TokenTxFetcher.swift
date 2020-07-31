//
//  TokenTxFetcher.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class TokenTxFetcher: TxFetcher {
    
    
    func getTxs(address: String, page: Int, offset: Int) -> PrimitiveSequence<SingleTrait, APIResult<TxFetcherElement<TokenTx>>> {
        fatalError()
    }
    
    private lazy var ethTxFetcher = { ETHTxFetcher.init() }()
    
    typealias Tx = TokenTx
    
    typealias Filter = TokenTxFilter
    
    func getTxs(address: String, startBlock: Int, endBlock: Int, coin: Coin?) -> PrimitiveSequence<SingleTrait, APIResult<TxFetcherElement<TokenTx>>> {
        let tokenResponse: RxAPIResponse<TxFetcherElement<TokenTx>> = Server.instance
            .getETHTokenTxRecords(startBlock: startBlock,
                                  endBlock: endBlock,
                                  ethAddress: address,
                                  token: coin)
            .map {
                result in
                switch result {
                case .failed(error: let err): return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    let reachEnd: Bool
                    let txsAscending = model.tokenTxs.sorted { $0.nonce < $1.nonce }
                    if let lastTxs = txsAscending.last {
                        let txMomenet = moment(lastTxs.date)
                        let currentMomnet = moment()
                        reachEnd =  Int(currentMomnet.intervalSince(txMomenet).days) >= C.BlockchainAPI.maxTracingTxRecordDays
                    }else {
                        reachEnd = true
                    }

//                    let filteredTx = self.filter.filter(source: model.tokenTxs)
                    
                    return RxAPIResponse.ElementType.success(TxFetcherElement(txs: txsAscending, reachEnd: reachEnd))
                }
            }
        
        return tokenResponse
        
        
    }
    
}

extension Array where Element == TokenTx {
    func merge(withEthErrorTxs ethTxs: [ETHTx],
               onlyMergeSpecificCoin coin: Coin?) -> Array<Element> {
//        guard !isEmpty else { return self }
//        let coin = first!.coin
        let contractAddress = coin?.contract!
        let desiredErrorOutTxs = ethTxs.filter { (tx) -> Bool in
            if let _ca = contractAddress {
                guard tx.contract == _ca else { return false }
            }
            
            return tx.isError
        }
        
        guard !desiredErrorOutTxs.isEmpty else { return self }
        
        var mutableSelfCopy = Array.init(self)
        let mapToTokenTx: (ETHTx) -> Element? = {
            tx in
            //Need to ensure the tx.toAddress (which is contract address when it's a erc-20 token tx) is same as the coin of self.
            guard let txCoin = Coin.getCoin(ofContractAddress: tx.contract) else { return nil }
            if let targetContract = contractAddress {
                guard targetContract == txCoin.contract else { return nil }
            }
            
            return Element(txid: tx.txid,
                           blockHeight: tx.blockHeight,
                           confirmations: tx.confirmations,
                           fromAddress: tx.fromAddress,
                           toAddress: tx.toAddress,
                           gasLimit: tx.gasLimit,
                           gasUsed: tx.gasUsed,
                           gasPriceInWei: tx.gasPriceInWei,
                           nonce: tx.nonce,
                           token: txCoin,
                           valueInCoinUnit: 0,
                           timestamp: tx.timestamp,
                           isError: tx.isError,
                           input: tx.input)
        }
        
        mutableSelfCopy += desiredErrorOutTxs.compactMap { mapToTokenTx($0) }
        
        mutableSelfCopy.sort {
            $0.timestamp >= $1.timestamp
        }
        
        return mutableSelfCopy
    }
}
