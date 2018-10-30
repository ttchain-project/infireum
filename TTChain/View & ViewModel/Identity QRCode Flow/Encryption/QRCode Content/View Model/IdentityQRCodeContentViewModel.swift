//
//  IdentityQRCodeContentViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import PhotosUI

class IdentityQRCodeContentViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let infoContent: IdentityQRCodeContent
        let pwd: String
        let pwdHint: String
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: IdentityQRCodeContentViewModel.InputSource
    var output: IdentityQRCodeContentViewModel.OutputSource
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    public var infoContent: Observable<IdentityQRCodeContent> {
        return .just(input.infoContent)
    }
    
    enum QRCodeParseResult {
        case success(CIImage)
        case failed(desc: String)
    }
    
    public var qrCodeParseResult: Observable<QRCodeParseResult> {
        return Observable.create({
            [weak self]
            (observer) -> Disposable in
            guard let wSelf = self else {
                return Disposables.create()
            }
            
            /*
             //TODO: Switch this for multiple QRCodes.
             if let qrCodeRawTextContent = wSelf.input.infoContent.generateMultipleQRCodeContent(withPwd: wSelf.input.pwd) {
             if let qrCode = QRCodeGenerator.generateMegaQRCodeCombine(for: qrCodeRawTextContent) {
             */
            
            if let qrCodeRawTextContent = wSelf.input.infoContent.generateQRCodeContent(withPwd: wSelf.input.pwd) {
                DispatchQueue.main.async {
                    if let qrCode = QRCodeGenerator.gZipAndgenerateQRCode(from: qrCodeRawTextContent) {
                        observer.onNext(.success(qrCode))
                    }else {
                        //LOC:
                        let info = wSelf.input.infoContent
                        observer.onNext(.failed(desc: "无法从钱包资讯生成 QRCODE (strLength: \(qrCodeRawTextContent.count), sw: \(info.systemWallets.count), \(info.importedWallets.count)"))
                    }
                }
            }else {
                observer.onNext(.failed(desc: "无法使用您输入的密码 \(wSelf.input.pwd) 解密内容"))
            }
            
            return Disposables.create()
        })
    }
    
    public var creationDate: Observable<Date> {
        let date = Date.init(timeIntervalSince1970:  self.input.infoContent.timestamp)
        return .just(date)
    }
    
    enum ImgSavingError: Error {
        case authNotDetermined
        case unauthorized
        
        var localizedDescription: String {
            let dls = LM.dls
            return dls.qrcodeProcess_alert_content_album_permission_denied
        }
    }
    
    private var _savingCompletionHandler: (() -> Void)?
    
    public func saveImgToLocal(_ img: UIImage,
                               onComplete: @escaping () -> Void) throws {
        
        _savingCompletionHandler = onComplete
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let scaledImg = img.scaleImage(toSize: CGSize.init(width: 2048, height: 2048))!
//            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
//            onSavingImgCompleted()
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: scaledImg)
                }

                onSavingImgCompleted()
            }
            catch let e {
                throw e
            }
            
        case .notDetermined:
            throw ImgSavingError.authNotDetermined
        case .denied, .restricted:
            throw ImgSavingError.unauthorized
        }
    }

    private func onSavingImgCompleted() {
        _savingCompletionHandler?()
        _savingCompletionHandler = nil
    }
}
