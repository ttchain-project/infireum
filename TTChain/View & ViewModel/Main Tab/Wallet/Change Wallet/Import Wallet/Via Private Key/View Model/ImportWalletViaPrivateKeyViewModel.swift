//
//  ImportWalletViaPrivateKeyViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HDWalletKit

class ImportWalletViaPrivateKeyViewModel: KLRxViewModel {
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let mainCoinID: String
        let defaultPKey: String?
        let pKeyInput: ControlProperty<String?>
        let pwdInput: ControlProperty<String?>
        let confirmPwdInput: ControlProperty<String?>
        let pwdHintInput: ControlProperty<String?>
        let confirmInput: Driver<Void>
        let walletName: ControlProperty<String?>
        let purpose:ImportWalletViaPrivateKeyViewController.Config.Purpose
    }

    struct Output {
        let onStartImportWallet: () -> Void
        let onFinishImportWallet: () -> Void
        let onFinishCheckingInputValidity: (InputValidity) -> Void
        let onUpdateEmptyFieldsStatus: (Bool) -> Void
        let onErrorMessage = PublishSubject<String>()
    }
    
    enum InputValidity {
        case valid
        case emptyPKey
        case emptyPwd
        case pwd_invalidFormat
        case emptyConfirmPwd
        case confirmPwd_notMatchPwd
        case emptyPwdHint
        case emptyWalletName
        case alreadyHasSameWallet
    }
    
    struct CreateResult {
        let pKey: String
        let address: String
        let mainCoinID: String
        let pwd: String
        let pwdHint: String
        let walletName:String
    }
    
    var input: ImportWalletViaPrivateKeyViewModel.Input
    var output: ImportWalletViaPrivateKeyViewModel.Output
    
    
    private let pKey: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let confirmPwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwdHint: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let walletName: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    
    private let hasEmptyFields: BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
    
    //MARK: - functions
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        (input.pKeyInput <-> pKey).disposed(by: bag)
        (input.pwdInput <-> pwd).disposed(by: bag)
        (input.confirmPwdInput <-> confirmPwd).disposed(by: bag)
        (input.pwdHintInput <-> pwdHint).disposed(by: bag)
        (input.walletName <-> walletName).disposed(by: bag)
        pKey.accept(input.defaultPKey)
        
        input.confirmInput
            .map {
                [unowned self] in self.checkValidity()
            }
            .map {
                [unowned self]
                validity -> Bool in
                let shouldContinue = validity == .valid
                if !shouldContinue {
                    self.output.onFinishCheckingInputValidity(validity)
                }
                
                return shouldContinue
            }
            .filter { $0 }
            .asObservable().subscribe(onNext:{ _ in
                self.output.onStartImportWallet()
                self.input.purpose == .create ? self.createWallet() : self.importWallet()
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        Observable.combineLatest(
            pKey.map { $0 == nil ? true : $0!.count > 0 },
            pwd.map { $0 == nil ? true : $0!.count > 0 },
            confirmPwd.map { $0 == nil ? true : $0!.count > 0 },
            pwdHint.map { $0 == nil ? true : $0!.count > 0 },
             walletName.map { $0 == nil ? true : $0!.count > 0 }
            )
            .map { $0 && $1 && $2 && $3 && $4}
            .bind(to: hasEmptyFields)
            .disposed(by: bag)
        
        hasEmptyFields.asObservable().subscribe(onNext: {
            [unowned self] hasEmpty in
            self.output.onUpdateEmptyFieldsStatus(hasEmpty)
        })
            .disposed(by: bag)
    }
    
    //MARK: - Validity
    private func checkValidity() -> InputValidity {
        
        if self.input.purpose == .import {
            guard let _pKey = pKey.value, _pKey.count > 0 else {
                return .emptyPKey
            }
        }
        
        guard let _pwd = pwd.value, _pwd.count > 0 else {
            return .emptyPwd
        }
        
        guard isPwdValid(_pwd) else {
            return .pwd_invalidFormat
        }
        
        guard let _confirmPwd = confirmPwd.value, _confirmPwd.count > 0 else {
            return .emptyConfirmPwd
        }
        
        guard _confirmPwd == _pwd else {
            return .confirmPwd_notMatchPwd
        }
        
        guard let _hint = pwdHint.value, _hint.count > 0 else {
            return .emptyPwdHint
        }
        
        guard let _walletName = walletName.value, _walletName.count > 0 else {
            return .emptyWalletName
        }
        
        //This check will move to after getting the address result response to compare address as well.
//        guard !walletIsExistInDB(pKey: _pKey, mainCoiniD: input.mainCoinID) else {
//            return .alreadyHasSameWallet
//        }
        
        return .valid
    }
    
    private func walletIsExistInDB(address: String, pKey: String, mainCoiniD: String) -> Bool {
        let pred = Wallet.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Wallet.walletMainCoinID), value: mainCoiniD))
        guard let wallets = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil) else {
            return errorDebug(response: false)
        }
        
        for wallet in wallets {
            if wallet.pKey == pKey || wallet.address! == address {
                return true
            }
        }
        
        return false
    }
    
    public func updatePKey(_ key: String) {
        pKey.accept(key)
    }
    
    //MARK: - Wallet Import
    private func importWallet() {

            guard let _pKey = self.pKey.value,
                let _pwd = self.pwd.value,
                let _hint = self.pwdHint.value,let _walletName = self.walletName.value else {
                    self.output.onErrorMessage.onNext(LM.dls.g_error_emptyData)
                    return
            }
            
            let mainCoinID = self.input.mainCoinID
            let coin:HDWalletKit.Coin = mainCoinID == Coin.btc_identifier ? .bitcoin : .ethereum
            guard let privateKey = PrivateKey.init(pk: _pKey, coin: coin) else {
                self.output.onErrorMessage.onNext(LM.dls.g_error_decryptFail_privateKey)
                return
            }
        
            let publicAddress = privateKey.publicKey.address
        
        guard !self.walletIsExistInDB(address: publicAddress, pKey: _pKey, mainCoiniD: mainCoinID) else {
            self.output.onErrorMessage.onNext(LM.dls.importWallet_privateKey_error_wallet_exist_already)
            return
        }
            let result = CreateResult(
                pKey: _pKey,
                address: publicAddress,
                mainCoinID: mainCoinID,
                pwd: _pwd,
                pwdHint: _hint,
                walletName:_walletName
            )
        self.handleImportWalletResult(result)
    }
    private func handleImportWalletResult(_ result: CreateResult) {
        guard let ids = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil),
            ids.count == 1, let id = ids.first else {
                return errorDebug(response: ())
        }
        
        let mainCoin = Coin.getCoin(ofIdentifier: input.mainCoinID)!
        
        guard let newWallet = Wallet.create(
            identity: id,
            source: (
                address: result.address,
                pKey: result.pKey,
                mnenomic: nil,
                isFromSystem: false,
                name: result.walletName,
                pwd: result.pwd,
                pwdHint: result.pwdHint,
                chainType: mainCoin.owChainType,
                mainCoinID: mainCoin.walletMainCoinID!
            )
            ) else {
                return errorDebug(response: ())
        }
        self.output.onFinishImportWallet()
        OWRxNotificationCenter.instance.notifyWalletImported(of: newWallet)
    }
    
    private func createWallet() {
        
        guard  let _pwd = self.pwd.value,
            let _hint = self.pwdHint.value,
            let _walletName = self.walletName.value else {
                self.output.onErrorMessage.onNext(LM.dls.g_error_emptyData)
                return
        }
        let chain:ChainType = self.input.mainCoinID == Coin.btc_identifier ? .btc : .eth
        let predForWallet = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: chain.rawValue))
        guard let wallets = DB.instance.get(type: Wallet.self, predicate: predForWallet, sorts: nil),
            let wallet = wallets.filter ({ $0.isFromSystem }).first else {
                self.output.onErrorMessage.onNext(LM.dls.g_error_emptyData)

                return
        }
        guard let mnemonic = wallet.attemptDecryptMnemonic(withRawPwd: _pwd) else {
            self.output.onErrorMessage.onNext(LM.dls.walletManage_error_pwd)

            return
        }
        
        WalletCreator.createNewWallet(forChain: chain, mnemonic: mnemonic, pwd: _pwd, pwdHint: _hint, isSystemWallet:false,walletName:_walletName)
            .subscribe({ [unowned self] (status) in
                self.output.onFinishImportWallet()
                OWRxNotificationCenter.instance.notifyWalletsImported()
            }).disposed(by: bag)
    }
    
}

// MARK: - Helper
extension ImportWalletViaPrivateKeyViewModel {
    fileprivate func isPwdValid(_ pwd: String) -> Bool {
        return pwd.count >= 8
    }
}
