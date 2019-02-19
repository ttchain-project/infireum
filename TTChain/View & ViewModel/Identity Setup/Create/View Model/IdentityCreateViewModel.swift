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
        let nameInput: ControlProperty<String?>
        let pwdInput: ControlProperty<String?>
        let confirmPwdInput: ControlProperty<String?>
        let pwdHintInput: ControlProperty<String?>
        let confirmInput: Driver<Void>
    }
    
    struct Output {
//        let onStartCreateIdentity: () -> Void
//        let onFinishCreateIdentity: (APIResult<CreateResult>) -> Void
        let onFinishCheckingInputValidity: (InputValidity) -> Void
        let onUpdateEmptyFieldsStatus: (Bool) -> Void
    }
    
    enum InputValidity {
        case valid
        case emptyIdentityName
        case identity_invalidFormat(desc: String)
        case emptyPwd
        case pwd_invalidFormat(desc: String)
        case emptyConfirmPwd
        case confirmPwd_invalidFormat(desc: String)
        case emptyPwdHint
        case pwdHint_invalidFormat(desc: String)
    }
    
    typealias CreateResult = APIWalletCreateResult
    
    var input: IdentityCreateViewModel.Input
    var output: IdentityCreateViewModel.Output
    
    private let name: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
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
        (input.nameInput <-> name).disposed(by: bag)
        (input.pwdInput <-> pwd).disposed(by: bag)
        (input.confirmPwdInput <-> confirmPwd).disposed(by: bag)
        (input.pwdHintInput <-> pwdHint).disposed(by: bag)
        
        input.confirmInput
            .map {
                [unowned self] in self.checkValidity()
            }
            .map {
                validity -> InputValidity in
                return validity
            }
//            .filter { $0 }
//            .asObservable()
//            .flatMapLatest {
//                [unowned self]
//                _ -> RxAPIResponse<CreateResult> in
//                self.output.onStartCreateIdentity()
//                return self.createIdentity()
//            }
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
        guard let _name = name.value, _name.count > 0 else {
            return .emptyIdentityName
        }
        
        switch _name.ow_isValidIdentityName {
        case .incorrectFormat(desc: let desc):
            return .identity_invalidFormat(desc: desc)
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
        
        return .valid
    }
    
    public func getIdentitySource() -> BackupWalletNoteViewController.Config {
        return BackupWalletNoteViewController.Config(name:name.value!,pwd:pwd.value!,pwdHint:pwdHint.value!)
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
        //TODO: Use mock data now
//        let fakeWallets: [CreateResult.WalletResource] =
//        [
//            CreateResult.WalletResource(
//                pKey: "b38840f94dec1f1d7ce95db0c4cadbfb964be3333db313a89b9e5d2935471b5d",
//                address: "0x9887FA8062E8D4e8B045BD2ca805e447b4340275",
//                type: .eth
//            ),
//            CreateResult.WalletResource(
//                pKey: "5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF",
//                address: "1CC3X2gu58d6wXUWMffpuzN9JAfTUWu4Kj",
//                type: .btc
//            ),
//            CreateResult.WalletResource(
//                pKey: "b38840f94dec1f1d7ce95db0c4cadbfb964be3333db313a89b9e5d2935471b5e",
//                address: "0xF5e544462FE66cb30C2d3546cFF82c061616b42D",
//                type: .cic
//            )
//        ]
//
//        let fakeMnemonic = "rose rocket invest real refuse margin festival danger anger border idle brown"
//        let result = CreateResult(name: _name, mnemonic: fakeMnemonic, walletsResource: fakeWallets, pwd: _pwd, pwdHint: _hint)
//        return RxAPIResponse.just(.success(result)).delay(2, scheduler: MainScheduler.instance)
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
