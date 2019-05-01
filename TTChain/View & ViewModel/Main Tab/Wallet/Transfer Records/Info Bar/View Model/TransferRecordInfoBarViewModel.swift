//
//  TransferRecordInfoBarViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordInfoBarViewModel: KLRxViewModel {
    struct Input {
        let wallet: Wallet
        let switchToOptionBarsInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransferRecordInfoBarViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _wallet.map {
            [unowned self] in self.createOptions(fromWallet: $0)
        }
        .bind(to: _options)
        .disposed(by: bag)
    }
    
    //MARK: - Public
    public var options: Observable<[String]> {
        return _options.asObservable()
    }
    
    public var onSwitchToOptionBars: Driver<Void> {
        return input.switchToOptionBarsInput
    }
    
    public var wallet: Observable<Wallet> {
        return _wallet.asObservable()
    }
    
    public func switchWallet(_ wallet: Wallet) {
        self._wallet.accept(wallet)
    }
    
    public func getOptions() -> [String] {
        return _options.value
    }
    
    //MARK: - Private
    private lazy var _options: BehaviorRelay<[String]> = {
        return BehaviorRelay.init(value: createOptions(fromWallet: input.wallet))
    }()
    
    private lazy var _wallet: BehaviorRelay<Wallet> = {
        return BehaviorRelay.init(value: input.wallet)
    }()
    
    private func createOptions(fromWallet wallet: Wallet) -> [String] {
        let typeName: String
        let chainType = ChainType.init(rawValue: wallet.chainType)!
        switch chainType {
        case .btc:
            typeName = "BTC"
        case .eth:
            typeName = "ETH"
        case .cic:
            typeName = "CIC"
        case .ttn :
            typeName = "TTN"
        }
        
        return [typeName, input.wallet.name!]
    }
}

extension TransferRecordInfoBarViewModel: RxTransRecordSortingOptionsProvider {
    var selectedMainCoin: Observable<Coin> {
        return selectedCoin.filterNil()
    }
    
    var selectedCoin: Observable<Coin?> {
        return Observable.just(nil).concat(Observable.never())
    }
    
    var selectedStatus: Observable<TransRecordListsStatusOptions?> {
        return Observable.just(nil).concat(Observable.never())
    }
    
    var selectedWallet: Observable<Wallet> {
        return wallet
    }
    
    var selectedChainType: Observable<ChainType> {
        return wallet.map { $0.owChainType }
    }
}
