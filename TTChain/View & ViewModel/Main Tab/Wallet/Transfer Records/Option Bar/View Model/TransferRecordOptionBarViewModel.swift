//
//  TransferRecordOptionBarViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordOptionBarViewModel: KLRxViewModel, RxTransRecordSortingOptionsProvider {
    
    struct Input {
        let mainCoinProvider: RxTransReocrdChainTypeOptionsProvider
        let walletProvioder: RxTransReocrdWalletOptionsProvider
        let coinProvider: RxTransReocrdCoinOptionsProvider
        let statusProvider: RxTransReocrdStatusOptionsProvider
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: TransferRecordOptionBarViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    var selectedCoin: Observable<Coin?> {
        return input.coinProvider.selectedCoin
    }
    
    var selectedStatus: Observable<TransRecordListsStatusOptions?> {
        return input.statusProvider.selectedStatus
    }
    
    var selectedWallet: Observable<Wallet> {
        return input.walletProvioder.selectedWallet
    }
    
    var selectedMainCoin: Observable<Coin> {
        return input.mainCoinProvider.selectedMainCoin
    }
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
}
