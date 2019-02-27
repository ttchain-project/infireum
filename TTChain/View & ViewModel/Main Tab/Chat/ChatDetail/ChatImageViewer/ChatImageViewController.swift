//
//  ChatImageViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/2.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Photos

final class ChatImageViewController: KLModuleViewController, KLVMVC {
    
    func config(constructor: ChatImageViewController.Config) {
        
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: (), output:())
        
        
        self.imageScrollView.setup()
        KLRxImageDownloader.instance.download(source: constructor.image) {
            result in
            switch result {
            case .failed:
                self.imageScrollView.display(image: #imageLiteral(resourceName: "no_image"))
            case .success(let img):
                self.createRightBarButton(target: self, selector: #selector(self.saveImage), title: LM.dls.ab_update_btn_save,toColor:.owWhite, shouldClear: true)
                self.image = img
                self.imageScrollView.display(image: img)
            }
        }
    }
    
    var viewModel: ChatImageViewModel!
    
    struct Config {
        let image:URL
    }
    var image: UIImage?
    
    typealias Constructor = Config
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias ViewModel = ChatImageViewModel
    
    @IBOutlet weak var imageScrollView: ImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func saveImage() {
        guard self.image != nil else {
            return
        }
        self.attemptSavingQRCodeImg {}
    }
    
    private func attemptSavingQRCodeImg(onSaved: @escaping () -> Void) {
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
                     self.saveImgToLocal(self.image!, onComplete: {
                        self.view.makeToast(LM.dls.image_saved_success)
                    })
                
            }
        }
    }
    
    private func handleUserAlbumAuthResultStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            attemptSavingQRCodeImg() {}
        case .denied, .restricted:
            presentAlbumAuthorizationDeniedAlert()
        case .notDetermined:
            attemptSavingQRCodeImg() {}
        }
    }
    
    private func presentAlbumAuthorizationDeniedAlert() {
        
        let dls = LM.dls
        showSimplePopUp(
            with: dls.qrcodeProcess_alert_title_album_permission_denied,
            contents: dls.qrcodeProcess_alert_content_album_permission_denied,
            cancelTitle: dls.g_confirm,
            cancelHandler: nil
        )
    }
    
    public func saveImgToLocal(_ img: UIImage,
                               onComplete: @escaping () -> Void) {
        
//        let scaledImg = img.scaleImage(toSize: CGSize.init(width: 2048, height: 2048))!
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            }
            onComplete()
        }
        catch let e {
            print(e)
        }
    }
}
