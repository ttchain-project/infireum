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
    }

    struct Output {
        let onStartImportWallet: () -> Void
        let onFinishImportWallet: (APIResult<CreateResult>) -> Void
        let onFinishCheckingInputValidity: (InputValidity) -> Void
        let onUpdateEmptyFieldsStatus: (Bool) -> Void
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
            .asObservable()
            .flatMapLatest {
                [unowned self]
                _ -> RxAPIResponse<CreateResult> in
                self.output.onStartImportWallet()
                return self.importWallet()
            }
            .asObservable()
            .subscribe(onNext: {
                [unowned self]
                result in
                self.output.onFinishImportWallet(result)
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
        guard let _pKey = pKey.value, _pKey.count > 0 else {
            return .emptyPKey
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
    private func importWallet() -> RxAPIResponse<CreateResult> {
        guard let _pKey = pKey.value,
            let _pwd = pwd.value,
            let _hint = pwdHint.value,let _walletName = walletName.value else {
                return RxAPIResponse.just(.failed(error: .noData))
        }
        
        let mainCoinID = input.mainCoinID
        return Server.instance.convertKeyToAddress(pKey: _pKey,encrypted: true)
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err): return .failed(error: err)
                case .success(let model):
                    let addr: String
                    guard let _addr = model.addressMap[mainCoinID] else {
                        return .failed(error: GTServerAPIError.noData)
                    }
                    
                    addr = _addr
                    
                    guard !self.walletIsExistInDB(address: addr, pKey: _pKey, mainCoiniD: mainCoinID) else {
                        let alertMsg = LM.dls.importWallet_privateKey_error_wallet_exist_already
                        return .failed(error: GTServerAPIError.incorrectResult(alertMsg, alertMsg))
                    }
                    
                    let result = CreateResult(
                        pKey: _pKey,
                        address: addr,
                        mainCoinID: mainCoinID,
                        pwd: _pwd,
                        pwdHint: _hint,
                        walletName:_walletName
                    )
                    
                    return .success(result)
                }
            }
    }
    
}

// MARK: - Helper
extension ImportWalletViaPrivateKeyViewModel {
    fileprivate func isPwdValid(_ pwd: String) -> Bool {
        return pwd.count >= 8
    }
}
