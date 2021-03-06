//
//  IdentityRestoreWalletViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/21.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class IdentityRestoreViewModel: KLRxViewModel {
    
    typealias CreateResult = APIWalletCreateResult
    
    struct Input {
        let pwdInput: ControlProperty<String?>
//        let userNameInput: ControlProperty<String?>
        let confirmPwdInput: ControlProperty<String?>
        let pwdHintInput: ControlProperty<String?>
        let confirmInput: Driver<Void>
        let mnemonic:String
    }
    
    struct Output {
//        let onStartRestoreIdentity: () -> Void
//        let onFinishRestoreIdentity: (APIResult<CreateResult>) -> Void
        let onFinishCheckingInputValidity: (InputValidity) -> Void
        let onUpdateEmptyFieldsStatus: (Bool) -> Void
    }
    
    enum InputValidity {
        case valid
        case emptyMnemonic
        case mnemonic_invalidFormat(desc: String)
        case emptyPwd
        case pwd_invalidFormat(desc: String)
        case emptyConfirmPwd
        case confirmPwd_invalidFormat(desc: String)
        case emptyPwdHint
        case pwdHint_invalidFormat(desc: String)
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    
    var input: IdentityRestoreViewModel.Input
    var output: IdentityRestoreViewModel.Output
    var bag: DisposeBag = DisposeBag.init()
    
    private let mnemonic: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let confirmPwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwdHint: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let userName: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let hasEmptyFields: BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
    
    public func getUserName() -> String {
        return self.userName.value ?? "Identity_Name"
    }
    public func getPwdString() -> String? {
        return self.pwd.value
    }
    public func getPwdHintValue() -> String? {
        return self.pwdHint.value
    }
    public func getMnemonicString() -> String? {
        return self.input.mnemonic
    }
    
    //MARK: - functions
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
//        (input.mnemonicInput <-> mnemonic).disposed(by: bag)
        (input.pwdInput <-> pwd).disposed(by: bag)
        (input.confirmPwdInput <-> confirmPwd).disposed(by: bag)
        (input.pwdHintInput <-> pwdHint).disposed(by: bag)
//        (input.userNameInput <-> userName).disposed(by: bag)
        input.confirmInput
            .map {
                [unowned self] in self.checkValidity()
            }
            .map {
                validity -> InputValidity in
                return validity
            }
            .asObservable()
            .subscribe(onNext: {
                [unowned self]
                validity in
                self.output.onFinishCheckingInputValidity(validity)
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    func updateMnenomic(source: String) {
        mnemonic.accept(source)
    }
    
    private func bindInternalLogic() {
        Observable.combineLatest(
            mnemonic.map { $0 == nil ? true : $0!.count > 0 },
            pwd.map { $0 == nil ? true : $0!.count > 0 },
            confirmPwd.map { $0 == nil ? true : $0!.count > 0 },
            pwdHint.map { $0 == nil ? true : $0!.count > 0 }
            )
            .map { $0 && $1 && $2 && $3 }
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
//        guard let _mnemonic = mnemonic.value, _mnemonic.count > 0 else {
//            return .emptyMnemonic
//        }
//
        switch self.input.mnemonic.ow_isValidMnemonic {
        case .incorrectFormat(desc: let desc):
            return .mnemonic_invalidFormat(desc: desc)
        case .valid:
            break
        }
        
        guard let _pwd = pwd.value, _pwd.count > 0 else {
            return .emptyPwd
        }
        
        switch _pwd.ow_isValidWalletPwd {
        case .incorrectFormat(desc: let desc):
            return .pwd_invalidFormat(desc: desc)
        case .valid:
            break
        }
        
        guard let _confirmPwd = confirmPwd.value, _confirmPwd.count > 0 else {
            return .emptyConfirmPwd
        }
        
        switch _confirmPwd.ow_isValidConfirmPwd(pwd: _pwd) {
        case .incorrectFormat(desc: let desc):
            return .confirmPwd_invalidFormat(desc: desc)
        case .valid:
            break
        }
        
        guard let _hint = pwdHint.value, _hint.count > 0 else {
            return .emptyPwdHint
        }
        
        switch _hint.ow_isValidPwdHint {
        case .incorrectFormat(desc: let desc):
            return .pwdHint_invalidFormat(desc: desc)
        case .valid:
            break
        }
        
        return .valid
    }

    //MARK: - Identity create
    private func restoreIdentity() -> RxAPIResponse<CreateResult> {
        guard let _mnemonic = mnemonic.value,
            let _pwd = pwd.value,
            let _hint = pwdHint.value else {
                return RxAPIResponse.just(.failed(error: .noData))
        }
        
        let defaultName: String = userName.value ?? "Identity_Name"
    
        return Server.instance.createAccount(defaultMnemonic: _mnemonic)
            .map {
                result in
                switch result {
                case .failed(let error): return RxAPIResponse.ElementType.failed(error: error)
                case .success(let model):
                    let walletResources: [CreateResult.WalletResource] =
                        model.walletsMap.compactMap({ (k, v) in
                            guard let coin = Coin.getCoin(ofIdentifier: k) else {
                                return nil
                            }
                            
                            return CreateResult.WalletResource(
                                pKey: v.pKey,
                                address: v.address,
                                mainCoin: coin
                            )
                        })

                    let result = CreateResult(name: defaultName, mnemonic: model.mnemonic, walletsResource: walletResources, pwd: _pwd, pwdHint: _hint)

                    return RxAPIResponse.ElementType.success(result)
                }
            }
            .observeOn(MainScheduler.instance)
    }
}

// MARK: - Helper
extension IdentityRestoreViewModel {
    fileprivate func isPwdValid(_ pwd: String) -> Bool {
        return pwd.count >= 8
    }
}

