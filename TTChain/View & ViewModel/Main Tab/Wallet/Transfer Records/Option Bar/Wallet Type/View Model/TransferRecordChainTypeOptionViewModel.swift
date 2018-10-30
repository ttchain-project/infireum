//
//  TransferRecordChainTypeOptionViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordChainTypeOptionViewModel: KLRxViewModel, TransferRecordsOptionsSingleSelectBase, RxTransReocrdChainTypeOptionsProvider {
    typealias Source = Coin
    var sourceManager: SingleSelectRxDataSourceManager<Coin>
    
    struct Input {
        let selectInput: Driver<Int>
        let defaultMainCoin: Coin
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        sourceManager = SingleSelectRxDataSourceManager<Coin>.init(defaultSources: MainCoinTypStorage.supportMainCoins)
        sourceManager.select(source: input.defaultMainCoin)
        
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        input.selectInput.map {
            [unowned self] in self.sourceManager.getSources()[$0]
        }
        .filter {
            [unowned self]
            coin in
            if Wallet.getWalletsCount(ofMainCoinID: coin.walletMainCoinID!) > 0 {
                return true
            }else {
                self._onFoundNoWalletsOfSelectedMainCoin.accept(())
                return false
            }
        }
        .drive(onNext: {
            [unowned self] in self.sourceManager.select(source: $0)
        })
        .disposed(by: bag)
    }
    
    func concatOutput() {
    
    }
    
    
    public var onFoundNoWalletsOfSelectedMainCoin: Observable<Void> {
        return _onFoundNoWalletsOfSelectedMainCoin.asObservable()
    }
    
    public var selectedMainCoin: Observable<Coin> {
        return sourceManager.selectedSource.filter { $0 != nil }.map { $0! }
    }
    
    public var mainCoins: Observable<[Coin]> {
        return sourceManager.sources
    }
    
    public func getMainCoin(ofIdx idx: Int) -> Coin {
        return sourceManager.getSources()[idx]
    }
    
    public func isMainCoinSelected(_ type: Coin) -> Bool {
        return sourceManager.isSelected(source: type)
    }
    
    //MARK: - Private
    private var _onFoundNoWalletsOfSelectedMainCoin: PublishRelay<Void> = PublishRelay.init()
}
