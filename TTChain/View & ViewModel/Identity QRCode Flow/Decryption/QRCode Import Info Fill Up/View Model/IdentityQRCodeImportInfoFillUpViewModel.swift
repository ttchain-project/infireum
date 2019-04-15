//
//  IdentityQRCodeImportInfoFillUpViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
class IdentityQRCodeImportInfoFillUpViewModel: KLRxViewModel {
    struct Input {
        let purpose: IdentityQRCodeDecryptionFlow.Purpose
        let infoContnet: IdentityQRCodeContent
        let identityNameInput: ControlProperty<String?>
        let pwdInput: ControlProperty<String?>
        let pwdHintInput: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    enum InvalidFieldCheckResult {
        case emptyIdName
        case emptyPwd
        case emptyPwdHint
        
        case invalidFormat_idName(desc: String)
        case invalidFormat_pwd(desc: String)
        case invalidFormat_hint(desc: String)
    }
    
    var bag: DisposeBag = DisposeBag.init()
    var input: IdentityQRCodeImportInfoFillUpViewModel.InputSource
    var output: IdentityQRCodeImportInfoFillUpViewModel.OutputSource
    
    public var onFindingInvalidFieldCheckResult: Observable<InvalidFieldCheckResult> {
        return _onFindingInvalidFieldCheckResult.asObservable()
    }
    
    private let _onFindingInvalidFieldCheckResult = PublishRelay<InvalidFieldCheckResult>.init()
    
//    public var onStartImport: Observable<Void> {
//        return _onStartImport.asObservable()
//    }
//
//    private let _onStartImport: PublishRelay<Void> = PublishRelay.init()
//
//    public var onFinishImport: Observable<RxAPIVoidResponse.E> {
//        return _onFinishImport.asObservable()
//    }
//
//    private let _onFinishImport: PublishRelay<RxAPIVoidResponse.E> = PublishRelay.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
    }
    
    func setupDefaultIdentityNameIfPossible() {
        switch input.purpose {
        case .importWallet:
            let identity = Identity.singleton!
            idName.accept(identity.name)
        case .restoreIdentity:
            break
        }
    }
    
    func concatInput() {
        (input.identityNameInput <-> idName).disposed(by: bag)
        (input.pwdInput <-> pwd).disposed(by: bag)
        (input.pwdHintInput <-> hint).disposed(by: bag)
        setupDefaultIdentityNameIfPossible()
    }
    
    func concatOutput() {
        
    }
    
    private let idName: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let pwd: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    private let hint: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    
    private func isWalletUnitExistInLocal(_ unit: IdentityQRCodeContentWalletUnit) -> Bool {
        guard let id = Identity.singleton,
            let currentLocalWallets = id.wallets?.array as? [Wallet] else {
                return false
        }
        
        guard !currentLocalWallets.isEmpty else { return false }
        
        for wallet in currentLocalWallets {
            if wallet.address!.caseInsensitiveCompare(unit.address) == .orderedSame {
                return true
            }
        }
        
        return false
    }
    
    public func attemptImport() -> Bool {
        if let invalid = checkFieldsValidity() {
            _onFindingInvalidFieldCheckResult.accept(invalid)
            return false
        }else {
            switch input.purpose {
            case .importWallet:
                let content = input.infoContnet
                let pwd = self.pwd.value!
                let hint = self.hint.value!
                let identity = Identity.singleton!
                //In import wallet flow, all the imported units should not be from system, and also should not store the mnemonic.
                let allWalletSources = (content.systemWallets + content.importedWallets)
                
                //Filter out already existed wallets.
                let importNeededSources = allWalletSources
                    .filter {
                        [unowned self] in
                        !self.isWalletUnitExistInLocal($0)
                    }
                    .map {
                        $0.transformToWalletCreateSource(pwd: pwd, pwdHint: hint, isFromSystem: false, mnemonic: nil)
                    }
                
                guard importNeededSources.isNotEmpty else {
                    return true
                }

                guard let wallets = Wallet.create(identity: identity, sources: importNeededSources),
                    wallets.count == importNeededSources.count else {
                        return false
                }
                
                DispatchQueue.main.async {
                    OWRxNotificationCenter.instance
                        .notifyWalletsImported()
                }
                
                return true
            case .restoreIdentity:
                guard Identity.create(fromQRCodeContent: input.infoContnet, idName: idName.value!, pwd: pwd.value!, hint: hint.value!) != nil else {
                    return false
                }
                
                return true
            }
        }
    }
    
    private func checkFieldsValidity() -> InvalidFieldCheckResult? {
        guard let idName = idName.value, idName.count > 0 else {
            return .emptyIdName
        }
        
        guard let pwd = pwd.value, pwd.count > 0 else {
            return .emptyPwd
        }
        
        guard let hint = hint.value, hint.count > 0 else {
            return .emptyPwdHint
        }
        
        switch idName.ow_isValidIdentityName {
        case .valid:
            break
        case .incorrectFormat(desc: let desc):
            return .invalidFormat_idName(desc: desc)
        }
        
        switch pwd.ow_isValidWalletPwd {
        case .valid:
            break
        case .incorrectFormat(desc: let desc):
            return .invalidFormat_pwd(desc: desc)
        }
        
        switch hint.ow_isValidPwdHint {
        case .valid:
            break
        case .incorrectFormat(desc: let desc):
            return .invalidFormat_hint(desc: desc)
        }
        
        return nil
    }
}
