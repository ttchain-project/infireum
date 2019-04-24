//
//  IdentitySetupViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class IdentitySetupViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    typealias ViewModel = IdentitySetupViewModel
    var viewModel: IdentitySetupViewModel!
    
    var bag: DisposeBag = DisposeBag.init()
    private lazy var scanner = { QRCodeImgScanner.init() }()
    private weak var qrcodeCameraVC: UINavigationController?
    
    //MARK: - Outlet
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var createNoteLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var sepline: UIView!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var bgHeaderImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        createBtn.roundBothSides()
        restoreBtn.roundBothSides()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: IdentitySetupViewModel.InputSource(
                onCreate: createBtn.rx.tap.asDriver(),
                onRestore: restoreBtn.rx.tap.asDriver()
            ),
            output: IdentitySetupViewModel.OutputSource(
                startCreate: {
                    [weak self] in self?.toCreate()
            },
                startRestore: {
                    [weak self] in self?.presentIdentityRestoreActionSheet()
            })
        )
    }
    
    override func renderTheme(_ theme: Theme) {
        headerLabel.set(
            textColor: theme.palette.label_main_2,
            font: UIFont.owRegular(size: 20)
        )
        
        createBtn.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 15)
        )
        createBtn.backgroundColor = theme.palette.btn_bgFill_enable_bg
        
//        let image = #imageLiteral(resourceName: "buttonPinkSolid").resizableImage(withCapInsets: .init(top: 0, left: 20, bottom: 0, right: 20), resizingMode: UIImageResizingMode.stretch)
        
//        createBtn.setBackgroundImage(image, for: .normal)
        
        createNoteLabel.set(
            textColor: theme.palette.label_sub,
            font: UIFont.owRegular(size: 12.5)
        )
        
        orLabel.set(
            textColor: theme.palette.label_sub,
            font: UIFont.owRegular(size: 12.5)
        )
        
        sepline.set(backgroundColor: theme.palette.sepline)
        
        restoreBtn.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 15)
        )
        restoreBtn.backgroundColor = theme.palette.btn_bgFill_enable_bg

        self.bgHeaderImgView.backgroundColor = .clear
     
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        headerLabel.text = dls.login_label_title
        createBtn.setTitleForAllStates(dls.login_btn_create)
        createNoteLabel.text = dls.login_label_desc
        orLabel.text = " " + dls.login_label_or + " "
        restoreBtn.setTitleForAllStates(dls.login_btn_restore)
    }
    
    private func toCreate() {
        let nav = IdentityCreateViewController.navInstance()
        present(nav, animated: true, completion: nil)
    }
    
    private func toRestore() {
        let nav = IdentityRestoreViewController.navInstance()
        nav.navigationBar.renderShadow()
        present(nav, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Restore Type Choose
import PhotosUI
extension IdentitySetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var kImgPicker: String { return "kImgPicker" }
    private var imgPicker: UIImagePickerController? {
        get {
            return objc_getAssociatedObject(self, kImgPicker) as? UIImagePickerController
        }set {
            objc_setAssociatedObject(self, kImgPicker, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func presentIdentityRestoreActionSheet() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let dls = LM.dls
        let fromMnemonic = UIAlertAction.init(
            title: dls.login_actionsheet_restore_mnemonic,
            style: .default) { [weak self] (_) in
                self?.toMnemonicRestore()
        }
        
        let fromQRCode = UIAlertAction.init(
            title: dls.login_actionsheet_restore_qrcode,
            style: .default) { [weak self] (_) in
                self?.presentQRCodeRestoreImgPicker()
        }
        
        let cancel = UIAlertAction.init(
            title: dls.g_cancel,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(fromMnemonic)
        alert.addAction(fromQRCode)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func toMnemonicRestore() {
        toRestore()
    }
    
    func presentQRCodeRestoreImgPicker() {
        
        let nav = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .restoreIdentity,
                resultCallback: {
                    [weak self]
                    (result, purpose, scanningType) in
                    switch result {
                    case .identityQRCode(rawContent: let rawContent):
                        self?.qrcodeCameraVC?.dismiss(animated: true, completion: {
                            self?
                                .startQRCodeDecryptionFlow(
                                    withRawContent: rawContent
                            )
                        })
                    default:
                        break
                    }
                },
                isTypeLocked: true
            )
        )
        
        qrcodeCameraVC = nav
        present(nav, animated: true, completion: nil)
        
        
//        requestPhotoLibraryPermissionIfNeeded {
//            [weak self]
//            (status) in
//            switch status {
//            case .denied, .restricted, .notDetermined:
//                self?.presentAlbumAuthorizationDeniedAlert()
//            case .authorized:
//
//                let imgPicker = UIImagePickerController.init()
//                imgPicker.sourceType = .savedPhotosAlbum
//                imgPicker.delegate = self
//
//                self?.imgPicker = imgPicker
//                self?.present(imgPicker, animated: true, completion: nil)
//            }
//        }
    }
    
    
    func requestPhotoLibraryPermissionIfNeeded(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        switch currentStatus  {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(completion)
        default:
            completion(currentStatus)
        }
    }
    
    func presentAlbumAuthorizationDeniedAlert() {
        
        let dls = LM.dls
        showSimplePopUp(
            with: dls.login_alert_title_camera_permission_denied,
            contents: dls.login_alert_content_camera_permission_denied,
            cancelTitle: dls.g_confirm,
            cancelHandler: nil
        )
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let rawContent = analyzeQRCodeImg(img: img) {
            picker.dismiss(animated: true) {
                [weak self] in
                self?.startQRCodeDecryptionFlow(withRawContent: rawContent)
//                let imgView = UIImageView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 200, height: 200)))
//                imgView.center = self!.view.center
//                imgView.image = img
//
//                self!.view.addSubview(imgView)
            }
        }else {
            picker.dismiss(animated: true) {
                [weak self] in
                self?.presentInvalidImgAlert()
            }
        }
    }
    
    private var kQRCodeDecryptionFlow: String { return "kQRCodeDecryptionFlow" }
    private var qrCodeDecryptionFlow: IdentityQRCodeDecryptionFlow? {
        get {
            return objc_getAssociatedObject(self, kQRCodeDecryptionFlow) as? IdentityQRCodeDecryptionFlow
        }set {
            objc_setAssociatedObject(self, kQRCodeDecryptionFlow, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startQRCodeDecryptionFlow(withRawContent rawContent: String) {
        qrCodeDecryptionFlow = IdentityQRCodeDecryptionFlow.start(
            purpose: .restoreIdentity,
            infoRawContent: rawContent,
            onViewController: self,
            onComplete: { [weak self] (result) in
                switch result {
                case .importFailure:
                    self?.presentImportWalletsFailedAlert()
                case .cancel:
                    print("No action")
                case .importSucceed:
                    self?.toMainTab()
                }
                
                self?.qrCodeDecryptionFlow = nil
        })
    }
    
    
    func analyzeQRCodeImg(img: UIImage) -> String? {
        guard let firstResult = scanner.detectQRCodeMsgContents(img)?.first else {
            return nil
        }
        
        guard IdentityQRCodeContent.isSourceHasValidIdentityQRCodeFormat(firstResult) else {
            return nil
        }
        
        return firstResult
    }
    
    func presentInvalidImgAlert() {
        let dls = LM.dls
        showSimplePopUp(
            with: dls.qrcodeProcess_alert_title_cannot_decode_qrcode_in_img,
            contents: dls.qrcodeProcess_alert_content_cannot_decode_qrcode_in_img,
            cancelTitle: dls.g_cancel,
            cancelHandler: nil
        )
    }
    
    func presentImportWalletsFailedAlert() {
        let dls = LM.dls
        showSimplePopUp(
            with: dls.login_alert_title_import_qrcode_failed,
            contents: dls.login_alert_content_import_qrcode_failed,
            cancelTitle: dls.g_cancel,
            cancelHandler: nil
        )
    }
    
    //MARK: - Routing
    func toMainTab() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMainTab()

    }
}
