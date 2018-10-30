//
//  TransferRecordCoinOptionViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordCoinOptionViewModel: KLRxViewModel, TransferRecordsOptionsSingleCancellableSelectBase, RxTransReocrdCoinOptionsProvider {
    struct Input {
        let selectInput: Driver<Int>
        let defaultMainCoin: Coin
    }
    
    typealias Source = Coin
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransferRecordCoinOptionViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    var sourceManager: SingleCancellableSelectRxDataSourceManager<Coin>
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        let coins = Coin.getAllCoins(of: input.defaultMainCoin)
        self.sourceManager = SingleCancellableSelectRxDataSourceManager.init(defaultSources: coins)
        
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        input.selectInput.drive(onNext: {
            [unowned self]
            idx in
            self.sourceManager.select(sourceIdx: idx)
        })
        .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var coins: Observable<[Coin]> {
        return sourceManager.sources
    }
    
    public var selectedCoin: Observable<Coin?> {
        return sourceManager.selectedSource
    }
    
    public func switchMainCoin(_ coin: Coin) {
        let coins = Coin.getAllCoins(of: coin)
//        if type == .cic {
//            coins = coins.filter { $0.identifier != Coin.cic_identifier }
//        }
        
        sourceManager.refreshSource(sources: coins)
        sourceManager.deselect()
    }
    
    public func getCoin(ofIdx idx: Int) -> Coin {
        return sourceManager.getSources()[idx]
    }
    
    public func isCoinSelected(_ coin: Coin) -> Bool{
        return sourceManager.isSelected(source: coin)
    }
}

