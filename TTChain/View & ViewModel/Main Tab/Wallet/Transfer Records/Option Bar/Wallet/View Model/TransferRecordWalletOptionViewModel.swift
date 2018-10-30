//
//  TransferRecordWalletOptionViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordWalletOptionViewModel: KLRxViewModel, TransferRecordsOptionsSingleSelectBase, RxTransReocrdWalletOptionsProvider {
    
    struct Input {
        let selectInput: Driver<Int>
        let defaultWallet: Wallet
    }
    
    typealias Source = Wallet
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransferRecordWalletOptionViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    var sourceManager: SingleSelectRxDataSourceManager<Wallet>
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        let wallets = Wallet.getWallets(ofMainCoinID: input.defaultWallet.walletMainCoinID!)
        self.sourceManager = SingleSelectRxDataSourceManager.init(defaultSources: wallets)
        self.sourceManager.select(source: input.defaultWallet)
        
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
    public var wallets: Observable<[Wallet]> {
        return sourceManager.sources
    }
    
    public var selectedWallet: Observable<Wallet> {
        return sourceManager.selectedSource.filter { $0 != nil }.map { $0! }
    }
    
    public func switchMainCoin(_ mainCoin: Coin) {
        let newWallets = Wallet.getWallets(ofMainCoinID: mainCoin.walletMainCoinID!)
        sourceManager.refreshSource(sources: newWallets)
        
        if let firstWallet = newWallets.first {
            sourceManager.select(source: firstWallet)
        }
    }
    
    public func getWallet(ofIdx idx: Int) -> Wallet {
        return sourceManager.getSources()[idx]
    }
    
    public func isWalletSelected(_ wallet: Wallet) -> Bool{
        return sourceManager.isSelected(source: wallet)
    }
}
