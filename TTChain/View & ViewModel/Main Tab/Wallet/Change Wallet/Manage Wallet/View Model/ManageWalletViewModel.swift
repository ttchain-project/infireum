//
//  ManageWalletViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ManageWalletViewModel: KLRxViewModel {
    struct Input {
        let wallet: Wallet
        let managePwdHintInput: Driver<Void>
        let exportPKeyInput: Driver<Void>
        let editNameInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: ManageWalletViewModel.Input
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    //MARK: - Public
    public var isAbleToExportPKey: Observable<Bool> {
        return wallet
            .map {
                ChainType.init(rawValue: $0.chainType)!
            }
            .map { $0 != .btc }
    }
    
    public var wallet: Observable<Wallet> {
        return _wallet.asObservable()
    }
    
    public var startManagePwdHint: Driver<Wallet> {
        return input.managePwdHintInput.map {
            [unowned self] in self.input.wallet
        }
    }
    
    public var startExportPKey: Driver<Wallet> {
        return input.exportPKeyInput
            .flatMapLatest {
            [unowned self]
            _ -> Driver<Bool> in
                return self.isAbleToExportPKey
                    .take(1).concat(Observable.never())
                    .asDriver(onErrorJustReturn: false)
            }
            .filter { $0 }
            .map {
                [unowned self] _ in self.input.wallet
            }
    }
    
    public var startEditName: Driver<Wallet> {
        return input.editNameInput.map {
            [unowned self] in self.input.wallet
        }
    }
    
    //MARK: - Private
    private lazy var _wallet: BehaviorRelay<Wallet> = {
        return BehaviorRelay.init(value: input.wallet)
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public function
    public func changeWalletName(to name: String) {
        _wallet.value.name = name
        DB.instance.update()
        
        OWRxNotificationCenter.instance.notifyWalletNameUpdate(of: _wallet.value)
        
        reloadWallet(fromDB: false)
    }
    
    public func reloadWallet(fromDB: Bool) {
        if fromDB {
        
            let pred = Wallet.createPredicate(from: _wallet.value.encryptedPKey!, _wallet.value.chainType, _wallet.value.walletMainCoinID!)
            guard let updatedWallet = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil)?.first else {
                return errorDebug(response: ())
            }
            
            _wallet.accept(updatedWallet)
        }else {
            _wallet.accept(_wallet.value)
        }
    }
    
    public func checkInputIsWalletPwd(_ input: String) -> Bool {
        return _wallet.value.isWalletPwd(rawPwd: input)
    }
    
}
