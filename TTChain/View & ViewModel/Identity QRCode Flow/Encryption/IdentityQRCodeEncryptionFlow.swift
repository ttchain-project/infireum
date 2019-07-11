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
                      onComplete: @escaping (Result) -> Void) -> IdentityQRCodeEncryptionFlow {
        let flow = IdentityQRCodeEncryptionFlow.init(
            launchType: launchType,
            identity: identity,
            onViewController: vc,
            onComplete: onComplete
        )
        
        flow.start()
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
    
    private func start() {
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
    
    private enum PwdAndHintInputResult {
        case skipped
        case invalidPwdFormat(desc: String)
        case invalidPwdHintFormat(desc: String)
        case samePasswordAndHint(desc: String)
        case success(pwd: String, pwdHint: String)
    }
    
    private var pwdTextField: UITextField?
    private var pwdHintTextField: UITextField?
    private func presentPwdAndHintInputAlert() -> Observable<PwdAndHintInputResult> {

        return Observable.create({ [weak self]
            (observer) -> Disposable in
            guard
                let wSelf = self,
                let vc = wSelf.requestVC else {
                observer.onNext(.skipped)
                return Disposables.create()
            }
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.qrCodeExport_alert_backup_title,
                message: dls.qrCodeExport_alert_note_content,
                preferredStyle: .alert)
            
            
            let skipped = UIAlertAction.init(title: dls.qrcodeExport_alert_btn_skip, style: .cancel) { (_) in
                observer.onNext(.skipped)
            }
            
            let confirm = UIAlertAction.init(title: LM.dls.qrcodeExport_alert_btn_backup, style: .default, handler: { (_) in
                guard let pwd = wSelf.pwdTextField?.text,
                    let hint = wSelf.pwdHintTextField?.text else {
                        observer.onNext(errorDebug(response: .skipped))
                        return
                }
                
                if case .incorrectFormat(let desc) = pwd.ow_isValidWalletPwd {
                    observer.onNext(.invalidPwdFormat(desc: desc))
                    return
                }else if case .incorrectFormat(let desc) = hint.ow_isValidPwdHint {
                    observer.onNext(.invalidPwdHintFormat(desc: desc))
                    return
                }else if pwd == hint  {
                    observer.onNext(.samePasswordAndHint(desc: dls.strValidate_field_pwdHintSame))
                    return
                }
                
                observer.onNext(.success(pwd: pwd, pwdHint: hint))
            })
            
            alert.addTextField(configurationHandler: { (tf) in
                wSelf.pwdTextField = tf
                tf.delegate = self
                tf.isSecureTextEntry = true
                tf.set(placeholder: dls.qrCodeExport_alert_placeholder_pwd)
                //                print("Reach tf build up")
            })
            
            alert.addTextField(configurationHandler: { (tf) in
                wSelf.pwdHintTextField = tf
                tf.set(placeholder: dls.qrCodeExport_alert_placeholder_hint)
                tf.delegate = self
//                print("Reach second tf build up")
            })

            alert.addAction(skipped)
            alert.addAction(confirm)
            
            vc.present(alert, animated: true, completion: {
                print("Reach block part")
                Observable.combineLatest(
                        wSelf.pwdTextField!.rx.text
                            .replaceNilWith("")
                            .map { $0.count > 0 },
                        wSelf.pwdHintTextField!.rx.text
                            .replaceNilWith("")
                            .map { $0.count > 0 }
                    )
                    .map { $0 && $1 }
                    .bind(to: confirm.rx.isEnabled)
                    .disposed(by: wSelf.bag)
                
            })
            
            return Disposables.create()
        })
    }
    
    private func presentQRCodeContentView(withPwd pwd: String, hint: String) {
        
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
