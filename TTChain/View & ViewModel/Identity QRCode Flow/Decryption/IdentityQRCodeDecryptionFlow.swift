//
//  IdentityQRCodeDecryptionFlow.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class IdentityQRCodeDecryptionFlow: NSObject, Rx {
    var bag: DisposeBag = DisposeBag.init()
    enum Purpose {
        case restoreIdentity
        case importWallet
    }
    
    enum Result {
        case importSucceed
        case importFailure
        case cancel
    }
    
    private(set) var onCompleteHandler: (Result) -> Void
    
    private let _onComplete: PublishRelay<Result> = PublishRelay.init()
    private let infoRawContent: String
    private let purpose: Purpose
    
    private(set) weak var requestVC: UIViewController?
    
    static func start(purpose: Purpose,
                      infoRawContent: String,
                      onViewController vc: UIViewController,
                      onComplete: @escaping (Result) -> Void) -> IdentityQRCodeDecryptionFlow {
        let flow = IdentityQRCodeDecryptionFlow.init(
            purpose: purpose,
            infoRawContent: infoRawContent,
            onViewController: vc,
            onComplete: onComplete
        )
        
        flow.start()
        return flow
    }
    
    required init(purpose: Purpose,
                  infoRawContent: String,
                  onViewController vc: UIViewController,
                  onComplete: @escaping (Result) -> Void) {
        
        self.purpose = purpose
        self.infoRawContent = infoRawContent
        self.requestVC = vc
        self.onCompleteHandler = onComplete
        
        super.init()
        
        bindCompleteCallback()
    }
    
    private func start() {
        presentPwdValidationAlert()
            .subscribe(onNext: {
                [weak self]
                result in
                let dls = LM.dls
                switch result {
                case .invalidPwd(desc: let desc):
                    self?.requestVC?.showSimplePopUp(
                        with: dls.qrCodeImport_alert_error_wrong_pwd_title,
                        contents: desc,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: { (_) in
                            self?.start()
                    })
                case .cancel:
                    self?._onComplete.accept(.cancel)
                case .success(content: let content):
                    self?.presentQRCodeImportWalletsView(withInfoContent: content)
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
    
    private enum ContentDecryptionResult {
        case cancel
        case invalidPwd(desc: String)
        case success(content: IdentityQRCodeContent)
    }
    
    private var pwdTextField: UITextField?
    private func presentPwdValidationAlert() -> Observable<ContentDecryptionResult> {
        return Observable.create({ [weak self]
            (observer) -> Disposable in
            guard
                let wSelf = self,
                let vc = wSelf.requestVC else {
                    observer.onNext(.cancel)
                    return Disposables.create()
            }
            
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.qrCodeImport_alert_input_pwd,
                message: dls.qrCodeImport_alert_content,
                preferredStyle: .alert)
            
            
            let cancel = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel) { (_) in
                observer.onNext(.cancel)
            }
            
            let confirm = UIAlertAction.init(title: LM.dls.g_confirm, style: .default, handler: { (_) in
                guard let pwd = wSelf.pwdTextField?.text else {
                        observer.onNext(errorDebug(response: .cancel))
                        return
                }
                
                if case .incorrectFormat(let desc) = pwd.ow_isValidWalletPwd {
                    observer.onNext(.invalidPwd(desc: desc))
                    return
                }
                
                guard let content = IdentityQRCodeContent.init(qrCodeRawContent: wSelf.infoRawContent, pwd: pwd) else {
                    observer.onNext(.invalidPwd(desc: dls.qrCodeImport_alert_error_wrong_pwd_content))
                    return
                }
                
                observer.onNext(.success(content: content))
            })
            
            alert.addTextField(configurationHandler: { (tf) in
                wSelf.pwdTextField = tf
                tf.delegate = self
                if let hint = IdentityQRCodeContent.Finder.findPwdHintFromQRCodeRawContentIfPossible(wSelf.infoRawContent) {
                    tf.set(placeholder: dls.qrCodeImport_alert_placeholder_pwd(hint))
                }
            })
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            vc.present(alert, animated: true, completion: {
                wSelf.pwdTextField!
                    .rx.text
                    .replaceNilWith("")
                    .map { $0.count > 0 }
                    .bind(to: confirm.rx.isEnabled)
                    .disposed(by: wSelf.bag)
            })
            
            return Disposables.create()
        })
    }
    
    private func presentQRCodeImportWalletsView(withInfoContent infoContent: IdentityQRCodeContent) {
        let vc = IdentityQRCodeImportViewController.navInstance(
            from: IdentityQRCodeImportViewController.Config(
                purpose: purpose,
                infoContent: infoContent,
                resultCallback: {
                    [weak self]
                    result in
                    guard let wSelf = self, let reqVC = wSelf.requestVC else { return }
                    reqVC.dismiss(animated: true, completion: {
                        wSelf._onComplete.accept(result)
                    })
            })
        )
        
        requestVC?.present(vc, animated: true, completion: nil)
    }
    
}

extension IdentityQRCodeDecryptionFlow: UITextFieldDelegate {
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
