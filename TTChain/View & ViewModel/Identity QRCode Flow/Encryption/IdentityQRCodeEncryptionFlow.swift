//
//  IdentityQRCodeEncryptionFlow.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class IdentityQRCodeEncryptionFlow: NSObject, Rx {
    var bag: DisposeBag = DisposeBag.init()
    
    enum Result {
        case qrCodeStored
        case skipped
        case createOwnQRCode(IdentityQRCodeContent)
    }
    
    enum LaunchType {
        //Create Identity
        case create
        //Restore Identity (with mnemonic)
        case restore_mnemonic
        //Import Wallet
        case importWallet
        //Backup identity
        case backupIdentity
    }
    
    static func start(launchType: LaunchType,
                      identity: Identity,
                      onViewController vc: UIViewController,
                      fromRegisterConfig: BackupWalletViewModel.Input? = nil,
                      onComplete: @escaping (Result) -> Void) -> IdentityQRCodeEncryptionFlow {
        let flow = IdentityQRCodeEncryptionFlow.init(
            launchType: launchType,
            identity: identity,
            onViewController: vc,
            onComplete: onComplete
        )
        if let config = fromRegisterConfig {
            flow.start(config: config)
        } else {
            flow.start()
        }
        return flow
    }
    
    private(set) var launchType: LaunchType
    private(set) var onCompleteHandler: (Result) -> Void
    
    private let _onComplete: PublishRelay<Result> = PublishRelay.init()
    private let identity: Identity
    
    private(set) weak var requestVC: UIViewController?
    
    required init(launchType: LaunchType,
                  identity: Identity,
                  onViewController vc: UIViewController,
                  onComplete: @escaping (Result) -> Void) {
        self.launchType = launchType
        self.identity = identity
        self.requestVC = vc
        self.onCompleteHandler = onComplete
        
        super.init()
        
        bindCompleteCallback()
    }
    
    private func start(config: BackupWalletViewModel.Input? = nil) {
        if let config = config {
            self.presentQRCodeContentView(withPwd: config.pwd, hint: config.pwdHint)
        } else {
            presentPwdAndHintInputAlert()
            .subscribe(onNext: {
                [unowned self]
                result in
                let dls = LM.dls
                switch result {
                case .invalidPwdFormat(desc: let desc):
                    
                    let msg = dls.qrCodeImport_info_g_alert_error_title_error_field(dls.qrCodeImport_info_g_alert_error_field_pwd)
                    self.requestVC?.showSimplePopUp(
                        with: msg,
                        contents: desc,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: { (_) in
                            self.start()
                        })
                case .invalidPwdHintFormat(desc: let desc):
                    
                    let msg = dls.qrCodeImport_info_g_alert_error_title_error_field(dls.qrCodeImport_info_g_alert_error_field_hint)
                    self.requestVC?.showSimplePopUp(
                        with: msg,
                        contents: desc,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: { (_) in
                            self.start()
                    })
                case .skipped:
                    self._onComplete.accept(.skipped)
                    
                case .samePasswordAndHint(desc: let desc):
                    
                    let msg = dls.qrCodeImport_info_g_alert_error_title_error_field(dls.qrCodeImport_info_g_alert_error_field_hint)
                    self.requestVC?.showSimplePopUp(
                        with: msg,
                        contents: desc,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: {[weak self] (_)  in
                            guard let `self` = self else {
                                return
                            }
                            self.start()
                    })
                    
                case .success(pwd: let pwd, pwdHint: let pwdHint):
                    
                    self.presentQRCodeContentView(withPwd: pwd, hint: pwdHint)
                }
            })
            .disposed(by: bag)
        }
        
    }
    
    private func bindCompleteCallback() {
        _onComplete
            .debug("On Complete")
            .take(1)
            .subscribe(onNext: {
                [weak self]
                result in
                self?.onCompleteHandler(result)
            })
            .disposed(by: bag)
    }
    
    enum PwdAndHintInputResult {
        case skipped
        case invalidPwdFormat(desc: String)
        case invalidPwdHintFormat(desc: String)
        case samePasswordAndHint(desc: String)
        case success(pwd: String, pwdHint: String)
    }
    
    private var pwdTextField: UITextField?
    private var pwdHintTextField: UITextField?
    private func presentPwdAndHintInputAlert(config: BackupWalletViewModel.Input? = nil) -> Observable<PwdAndHintInputResult> {

        let vc = BackQRCodePwdEntryViewController.init()
        if let config = config {
            vc.finalResult
                .onNext(IdentityQRCodeEncryptionFlow
                    .PwdAndHintInputResult
                    .success(pwd: config.pwd,
                             pwdHint: config.pwdHint))
        } else {
            self.requestVC?.present(vc, animated: false, completion: nil)
        }
        return vc.finalResult.asObservable()
    }
    
    private func presentQRCodeContentView(withPwd pwd: String, hint: String, isAutoSave: Bool = false) {
        
        guard let qrCodeContent = IdentityQRCodeContent.init(
            identity: identity, pwd: pwd, pwdHint: hint
            ) else {
                return errorDebug(response: ())
        }
        
        let vc = IdentityQRCodeContentViewController.navInstance(
            from: IdentityQRCodeContentViewController.Config(
                qrCodeContent: qrCodeContent,
                pwd: pwd,
                pwdHint: hint,
                onComplete: {
                    [weak self]
                    result in
                    self?._onComplete.accept(result)
            })
        )
        
        if self.launchType == .create {
            self._onComplete.accept(Result.createOwnQRCode(qrCodeContent))
        }else {
            requestVC?.presentedViewController?.dismiss(animated: true, completion: nil)
            requestVC?.present(vc, animated: true, completion: nil)
        }
    }
}

extension IdentityQRCodeEncryptionFlow: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pwdTextField {
            //No space character in pwd fields.
            guard !string.contains(" ") else { return false }
        }
        
        var text: String
        if let tf_text = textField.text {
            text = (tf_text as NSString).replacingCharacters(in: range, with: string)
        }else {
            text = string
        }
        
        guard !text.hasPrefix(" ") else { return false }
        return true
    }
}
