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
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var createNoteLabel: UILabel!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var loginOptionsView: UIStackView!
    @IBOutlet weak var restoreOptionsView: UIView!
    @IBOutlet weak var signUsingQRCode: UIButton!
    @IBOutlet weak var signUsingMnenomics: UIButton!
    @IBOutlet weak var backToLoginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        self.restoreOptionsView.isHidden = true
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
                    [weak self] in self?.showRestoreView()
            })
        )
        self.bindUI()
    }
    
    override func renderTheme(_ theme: Theme) {
        
        createBtn.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),backgroundColor:theme.palette.btn_bgFill_enable_bg
        )
        
        
        self.view.backgroundColor = .white
        
        createNoteLabel.set(
            textColor: theme.palette.bg_fill_new,
            font: UIFont.owRegular(size: 12)
        )
        
        restoreBtn.set(
            textColor: .cloudBurst,
            font: UIFont.owRegular(size: 14),backgroundColor:.white, borderInfo:(color:.cloudBurst, width: 1)
        )
        restoreBtn.cornerRadius = restoreBtn.height/2
        createBtn.cornerRadius = createBtn.height/2
        
        signUsingQRCode.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),backgroundColor:theme.palette.btn_bgFill_enable_bg
        )
        signUsingMnenomics.set(
            textColor: theme.palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),backgroundColor:theme.palette.btn_bgFill_enable_bg
        )
        
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        createBtn.setTitleForAllStates(dls.register_new_account_btn_title)
        createNoteLabel.text = dls.register_account_msg_label_login
        restoreBtn.setTitleForAllStates(dls.original_account_login)
        signUsingMnenomics.setTitleForAllStates(dls.login_actionsheet_restore_mnemonic)
        signUsingQRCode.setTitleForAllStates(dls.login_actionsheet_restore_qrcode)
        backToLoginBtn.setTitleForAllStates(dls.g_cancel)
    }
    
    private func toCreate() {
        
            let vc = PrivacyPolicyViewController.init(status: { (status) in
                self.presentedViewController?.dismiss(animated: true, completion: {
                    if status {
                        let nav = IdentityCreateViewController.navInstance()
                        self.present(nav, animated: true, completion: nil)
                    }
                })
            })
            self.present(vc, animated: true, completion: nil)
    }
    
    private func toRestore() {
        let vc = RestoreMnemonicViewController.navInstance()
        vc.navigationBar.renderShadow()
        present(vc, animated: true, completion: nil)
    }

    func showRestoreView() {
        self.loginOptionsView.isHidden = true
        self.restoreOptionsView.isHidden = false
    }
    func showLoginView() {
        self.loginOptionsView.isHidden = false
        self.restoreOptionsView.isHidden = true
    }
    func bindUI() {
        self.backToLoginBtn.rx.klrx_tap.drive(onNext:{ _ in
            self.showLoginView()
        }).disposed(by: bag)
        
        self.signUsingMnenomics.rx.klrx_tap.drive(onNext:{ _ in
            self.toRestore()
        }).disposed(by: bag)
        
        self.signUsingQRCode.rx.klrx_tap.drive(onNext:{ _ in
            self.presentQRCodeRestoreImgPicker()
        }).disposed(by: bag)
    }
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
