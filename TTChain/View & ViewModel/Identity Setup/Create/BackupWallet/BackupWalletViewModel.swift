//
//  BackupWalletViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import HDWalletKit

class BackupWalletViewModel:KLRxViewModel {
    
    var bag:DisposeBag = DisposeBag()
    typealias InputSource = Input
    typealias OutputSource = Output
    var input: Input
    var output: Output
    
    struct Input {
        var name:String
        var pwd:String
        var pwdHint:String
    }
    
    struct Output {
        let bottomButtonIsEnabled = BehaviorRelay<Bool>(value: false)
        let qrcodeImage = BehaviorRelay<UIImage?>(value: nil)
        let errorMessageSubject = PublishSubject<String>.init()
        let animateHUDSubject = PublishSubject<Bool>.init()
    }
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
    }
    func concatInput() {}
    func concatOutput() {}
    
    func createIdentity() {
        self.output.animateHUDSubject.onNext(true)
        
        let mnemonic = Mnemonic.create()
        guard Identity.create(mnemonic: mnemonic, name:self.input.name , pwd: input.pwd, hint: input.pwdHint) != nil else {
            self.output.animateHUDSubject.onNext(false)
            #if DEBUG
            fatalError()
            #else
            self.output.errorMessageSubject.onNext(LM.dls.sortMnemonic_error_create_user_fail)
            
            return
            #endif
        }
 
        WalletCreator.createNewWallet(forChain: .btc, mnemonic: mnemonic, pwd: input.pwd, pwdHint: input.pwdHint, isSystemWallet:true)
            .flatMap { response -> Single<Bool> in
            if response {
                return WalletCreator.createNewWallet(forChain: .eth, mnemonic: mnemonic, pwd: self.input.pwd, pwdHint: self.input.pwdHint, isSystemWallet:true)
            }else {
                return .error(GTServerAPIError.apiReject)
            }
            }.subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe(onSuccess: { (status) in
                self.output.animateHUDSubject.onNext(false)
                TTNWalletManager.setupTTNWallet(withPwd: self.input.pwd)
                if status {
                     self.output.bottomButtonIsEnabled.accept(true)
                }
            }) { (error) in
                self.output.animateHUDSubject.onNext(false)
                self.output.errorMessageSubject.onNext(LM.dls.sortMnemonic_error_create_wallet_fail)
            }.disposed(by: bag)
    }
    
    public func createQRCode(fromContent content:IdentityQRCodeContent) {
        
            if let qrCodeRawTextContent = content.generateQRCodeContent(withPwd: content.pwd ?? "") {
                DispatchQueue.main.async {
                    if let qrCode = QRCodeGenerator.gZipAndgenerateQRCode(from: qrCodeRawTextContent) {
                        self.output.qrcodeImage.accept(UIImage.init(ciImage: qrCode))
                        self.takeScreenshot(true)
                    }else {
                        self.output.errorMessageSubject.onNext("无法从钱包资讯生成 QRCODE")
                    }
                }
            }else {
                self.output.errorMessageSubject.onNext("无法使用您输入的密码 \(content.pwd ?? "")  解密内容")
            }
            
        }
    private func takeScreenshot(_ shouldSave: Bool = true) {
            var screenshotImage :UIImage?
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            guard let context = UIGraphicsGetCurrentContext() else {return}
            layer.render(in:context)
            screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let image = screenshotImage, shouldSave {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
}
