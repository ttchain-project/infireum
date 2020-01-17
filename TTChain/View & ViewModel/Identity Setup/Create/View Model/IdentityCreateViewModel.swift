//
//  IdentityCreateViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HDWalletKit

class IdentityCreateViewModel: KLRxViewModel {
    typealias InputSource = Input
    
    typealias OutputSource = Output
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
//        let nameInput: ControlProperty<String?>
        let pwdInput: ControlProperty<String?>
        let confirmPwdInput: ControlProperty<String?>
        let pwdHintInput: ControlProperty<String?>
        let confirmInput: Driver<Void>
        let accpetBtnInput: UIButton
    }
    
    struct Output {
//        let onStartCreateIdentity: () -> Void
//        let onFinishCreateIdentity: (APIResult<CreateResult>) -> Void
        let onFinishCheckingInputValidity: (InputValidity) -> Void
        let onUpdateEmptyFieldsStatus: (Bool) -> Void
    }
    
    enum InputValidity {
        case valid
//        case emptyIdentityName
        case identity_invalidFormat(desc: String)
        case emptyPwd
        case pwd_invalidFormat(desc: String)
        case emptyConfirmPwd
        case confirmPwd_invalidFormat(desc: String)
        case emptyPwdHint
        case pwdHint_invalidFormat(desc: String)
        case conditionsNotAccepted
    }
    
    typealias CreateResult = APIWalletCreateResult
    
    var input: IdentityCreateViewModel.Input
    var output: IdentityCreateViewModel.Output

    private let name: BehaviorRelay<String?> = BehaviorRelay.init(value: " ")
    private let pwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let confirmPwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwdHint: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    
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
//        (input.nameInput <-> name).disposed(by: bag)
        (input.pwdInput <-> pwd).disposed(by: bag)
        (input.confirmPwdInput <-> confirmPwd).disposed(by: bag)
        (input.pwdHintInput <-> pwdHint).disposed(by: bag)
        
        input.accpetBtnInput.rx.klrx_tap.drive(onNext: {
            self.input.accpetBtnInput.isSelected = !self.input.accpetBtnInput.isSelected
        }).disposed(by:bag)
        
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
    
    private func bindInternalLogic() {
        Observable.combineLatest(
                name.map { $0 == nil ? true : $0!.count > 0 },
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
//        guard let _name = name.value, _name.count > 0 else {
//            return .emptyIdentityName
//        }
//
//        switch _name.ow_isValidIdentityName {
//        case .incorrectFormat(desc: let desc):
//            return .identity_invalidFormat(desc: desc)
//        case .valid:
//            break
//        }
        
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
        case .incorrectFormat(let desc):
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
        
        if !self.input.accpetBtnInput.isSelected {
            return .conditionsNotAccepted
        }
        return .valid
    }
    
    public func getIdentitySource() -> BackupWalletViewController.Config {
        return BackupWalletViewController.Config(name:name.value!,pwd:pwd.value!,pwdHint:pwdHint.value!)
    }
    //MARK: - Identity create
    private func createIdentity() -> RxAPIResponse<CreateResult> {
        guard let _name = name.value,
            let _pwd = pwd.value,
            let _hint = pwdHint.value else {
            return RxAPIResponse.just(.failed(error: .noData))
        }
        
        
        return Server.instance.createAccount(defaultMnemonic: nil)
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    let walletResouces: [CreateResult.WalletResource] = model.walletsMap.compactMap({ (k, v) in
                            guard let coin = Coin.getCoin(ofIdentifier: k) else {
                                return nil
                            }
                        
                            return CreateResult.WalletResource(
                                pKey: v.pKey, address: v.address, mainCoin: coin
                            )
                        })
                    
                    
                    let result = CreateResult(name: _name, mnemonic: model.mnemonic, walletsResource: walletResouces, pwd: _pwd, pwdHint: _hint)
                    return RxAPIResponse.ElementType.success(result)
                }
        }

    }
}

// MARK: - Helper
extension IdentityCreateViewModel {
    fileprivate func isPwdValid(_ pwd: String) -> Bool {
        switch pwd.ow_isValidWalletPwd {
        case .valid: return true
        case .incorrectFormat: return false
        }
    }
}
