//
//  ImageSaver.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/25.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import Photos
import RxSwift

class ImageSaver {
    
    private var vcToShow: UIViewController =  UIViewController()
    private var imageToSave:UIImage = UIImage()
    private var event:((SingleEvent<Void>) -> ())!
    
   static func saveImage(image:UIImage, onViewController vc: UIViewController) -> Single<Void> {
        
        return Single.create(subscribe: { event -> Disposable in
            let instance = ImageSaver()
            instance.imageToSave = image
            instance.vcToShow = vc
            instance.event = event
            instance.attemptSavingImg {}
             return Disposables.create()
        })
    }
    
    private func attemptSavingImg(onSaved: @escaping () -> Void) {
        DispatchQueue.main.async {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization {
                    [unowned self]
                    (status) in
                    self.handleUserAlbumAuthResultStatus(status)
                }
            case .denied, .restricted:
                self.presentAlbumAuthorizationDeniedAlert()
            case .authorized:
                self.saveImgToLocal(self.imageToSave, onComplete: {
                    self.vcToShow.view.makeToast(LM.dls.image_saved_success)
                    self.event(.success(()))
                })
            }
        }
    }
    
    private func handleUserAlbumAuthResultStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            attemptSavingImg() {}
        case .denied, .restricted:
            presentAlbumAuthorizationDeniedAlert()
        case .notDetermined:
            attemptSavingImg() {}
        }
    }
    
    private func presentAlbumAuthorizationDeniedAlert() {
        
        let dls = LM.dls
        self.vcToShow.showSimplePopUp(
            with: dls.qrcodeProcess_alert_title_album_permission_denied,
            contents: dls.qrcodeProcess_alert_content_album_permission_denied,
            cancelTitle: dls.g_confirm,cancelHandler:{ _ in
                self.event(.success(()))
        })
    }
    
    func saveImgToLocal(_ img: UIImage,
                               onComplete: @escaping () -> Void) {
        
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            }
            onComplete()
        }
        catch let e {
            self.event(.error(e))
            print(e)
        }
    }
}
