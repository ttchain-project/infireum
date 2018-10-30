//
//  IdentityQRCodeContentViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxOptional
import PhotosUI
import RxSwift


final class IdentityQRCodeContentViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var qrCodeBase: UIView!
    @IBOutlet weak var qrCodeDateLabel: UILabel!
    @IBOutlet weak var qrCodeImgView: UIImageView!
    
    @IBOutlet weak var qrCodeSaveBtn: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var systemWalletsTitleLabel: UILabel!
    @IBOutlet weak var systemWalletsContentLabel: UILabel!
    @IBOutlet weak var importedWalletsTitleLabel: UILabel!
    @IBOutlet weak var importedWalletsContentLabel: UILabel!
    
    @IBOutlet weak var finishBtn: UIButton!
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let qrCodeContent: IdentityQRCodeContent
        let pwd: String
        let pwdHint: String
        let onComplete: (IdentityQRCodeEncryptionFlow.Result) -> Void
    }
    
    typealias Constructor = Config
    typealias ViewModel = IdentityQRCodeContentViewModel
    
    var viewModel: IdentityQRCodeContentViewModel!
    
    //MARK: - Setup
    private var onComplete: ((IdentityQRCodeEncryptionFlow.Result) -> Void)?

    func config(constructor: IdentityQRCodeContentViewController.Constructor) {
        onComplete = constructor.onComplete
        
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: IdentityQRCodeContentViewModel.InputSource(
                infoContent: constructor.qrCodeContent,
                pwd: constructor.pwd,
                pwdHint: constructor.pwdHint
            ),
            output: ()
        )
        
        setupQRCodeBaseShadow()
        bindUI()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupQRCodeBaseShadow() {
        qrCodeBase.addShadow(ofColor: .owBlack20,
                             radius: 1,
                             offset: CGSize.init(width: 0, height: 1),
                             opacity: 1)
    }
    
    override func renderLang(_ lang: Lang) {
        
        let dls = lang.dls
        title = dls.qrCodeExport_title
        qrCodeSaveBtn.setTitleForAllStates(
            dls.qrCodeExport_btn_save_qrcode
        )
        descLabel.text = dls.qrCodeExport_label_desc
        
        systemWalletsTitleLabel.text = dls.qrCodeExport_label_user_system_wallets
        importedWalletsTitleLabel.text = dls.qrCodeExport_label_imported_wallets
        
        finishBtn.setTitleForAllStates(dls.g_done)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1,
                     barTint: palette.nav_bg_1)
        
        renderNavTitle(color: palette.nav_item_1,
                       font: .owMedium(size: 18))
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_1,
            image: #imageLiteral(resourceName: "arrowNavBlack"),
            title: nil
        )
        
        qrCodeBase.set(backgroundColor: palette.bgView_main)
        
        qrCodeDateLabel.set(textColor: palette.label_sub,
                            font: .owRegular(size: 12))
        qrCodeSaveBtn.set(color: palette.btn_bgFill_enable_text,
                          font: .owRegular(size: 12),
                          backgroundColor: palette.btn_bgFill_enable_bg)
        
        descLabel.set(textColor: palette.input_placeholder,
                      font: .owRegular(size: 13))
        
        systemWalletsTitleLabel.set(textColor: palette.label_main_1,
                                    font: .owRegular(size: 13))
        
        systemWalletsContentLabel.set(
            textColor: palette.input_placeholder,
            font: .owRegular(size: 13)
        )
        
        importedWalletsTitleLabel.set(textColor: palette.label_main_1,
                                      font: .owRegular(size: 13))
        
        importedWalletsContentLabel.set(
            textColor: palette.input_placeholder,
            font: .owRegular(size: 13)
        )
        
        finishBtn.set(color: palette.btn_bgFill_enable_text,
                      font: .owRegular(size: 12),
                      backgroundColor: palette.btn_bgFill_enable_bg)
    }
    
    //MARK: - Event Binding
    private func bindUI() {
        bindQRCodeContent()
        bindWalletsContent()
        bindBtnActions()
        bindFinishEventCallback()
    }
    
    private func bindQRCodeContent() {
        viewModel
            .creationDate
            .map {
                DateFormatter.dateString(from: $0, withFormat: "yyyy-MM-dd HH:mm:ss")
            }
            .bind(to: qrCodeDateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.qrCodeParseResult
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self]
                result in
                switch result {
                case .success(let img):
                    self?.qrCodeImgView.image = UIImage.init(ciImage: img)
                case .failed(desc: let desc):
                    self?.presentQRCodeParseFailedAlert(with: desc)
                }
            })
            .disposed(by: bag)
    }
    
    private func presentQRCodeParseFailedAlert(with desc: String) {
        //LOC:
        let dls = LM.dls
        showSimplePopUp(
            with: "無法生成 QRCODE",
            contents: desc,
            cancelTitle: dls.g_confirm,
            cancelHandler: nil
        )
    }
    
    private func bindWalletsContent() {
        viewModel
            .infoContent
            .map { $0.systemWallets }
            .map {
                $0.reduce("", { (names, wallet) -> String in
                    if names.count == 0 {
                        return wallet.name
                    }else {
                        return names + ", " + wallet.name
                    }
                })
            }
            .bind(to: systemWalletsContentLabel.rx.text)
            .disposed(by: bag)
        
        viewModel
            .infoContent
            .map { $0.importedWallets }
            .map {
                $0.reduce("", { (names, wallet) -> String in
                    if names.count == 0 {
                        return wallet.name
                    }else {
                        return names + ", " + wallet.name
                    }
                })
            }
            .bind(to: importedWalletsContentLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func bindBtnActions() {
        qrCodeSaveBtn.rx
            .tap
            .asDriver()
            .drive(onNext: {
                [unowned self]
                _ in
                self.attemptSavingQRCodeImg() {}
            })
            .disposed(by: bag)
        
        finishBtn.rx
            .tap
            .asDriver()
            .drive(onNext: {
                [unowned self]
                _ in
                self.finish()
            })
            .disposed(by: bag)
    }
    
    private func bindFinishEventCallback() {
        
        onFinish
            .take(1)
            .subscribe(onNext: {
                [weak self]
                _ in
                guard let wSelf = self else { return }
                if wSelf.isQRCodeSaved {
                    wSelf.onComplete?(.qrCodeStored)
                }else {
                    wSelf.onComplete?(.skipped)
                }
            })
            .disposed(by: bag)
    }
    
    private var hud: KLHUD?
    
    //MARK: - Actions
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
                do {
                    let img = self.generateQRCodeBaseViewSnapShot()
//                    #if DEBUG
//                    self.qrCodeImgView.image = img
//                    #else
                    try self.viewModel.saveImgToLocal(img, onComplete: {
                    self.view.makeToast(LM.dls.qrcodeExport_toast_qrcode_saved_to_album)
                        self.swtichSaveBtnState(isQRCodeSaved: true)
                    })
//                    #endif    b
                }catch let error {
                    self.showAPIErrorResponsePopUp(
                        from: error,
                        cancelTitle: LM.dls.g_confirm
                    )
                }
            }
        }
    }
    
    private(set) var isQRCodeSaved: Bool = false
    
    //MARK: Finish
    private var onFinish: PublishRelay<Void> = PublishRelay.init()
    
    private func finish() {
        if isQRCodeSaved {
            dismissAndSendNotificationEvent()
        }else {
            notifyQRCodeNotSaved {
                [weak self] in
                self?.dismissAndSendNotificationEvent()
            }
        }
    }
    
    private func dismissAndSendNotificationEvent() {
        weak var weakSelf = self
        dismiss(animated: true) {
            //This keep a strong ref to self, which will prevent self deallocated during the block exceution.
            //The end of the block will release and deallocate self.
            let strongSelf = weakSelf
            strongSelf?.onFinish.accept(())
        }
    }
    
    //MARK: QRCODE Saving
    private func notifyQRCodeNotSaved(onComplete: @escaping () -> Void) {
        let dls = LM.dls
        let alert = UIAlertController.init(
            title: dls.qrcodeExport_alert_title_did_not_backup_qrcode,
            message: dls.qrcodeExport_alert_content_did_not_backup_qrcode,
            preferredStyle: .alert
        )
        
        let backup = UIAlertAction.init(
            title: dls.qrcodeExport_alert_btn_backup,
            style: .default) { (_) in
                self.attemptSavingQRCodeImg() {
                    onComplete()
                }
        }
        
        let skip = UIAlertAction.init(
            title: dls.qrcodeExport_alert_btn_skip,
            style: .cancel) { (_) in
                onComplete()
        }
        
        alert.addAction(backup)
        alert.addAction(skip)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func swtichSaveBtnState(isQRCodeSaved: Bool) {
        let palette = TM.palette
        let dls = LM.dls
        if isQRCodeSaved {
            qrCodeSaveBtn.set(
                color: palette.btn_bgFill_disable_text,
                font: .owRegular(size: 12),
                backgroundColor: palette.btn_bgFill_disable_bg
            )
            
            qrCodeSaveBtn.setTitleForAllStates(dls.qrCodeExport_btn_qrcode_saved)
        }else {
            qrCodeSaveBtn.set(
                color: palette.btn_bgFill_enable_text,
                font: .owRegular(size: 12),
                backgroundColor: palette.btn_bgFill_enable_bg
            )
            
            qrCodeSaveBtn.setTitleForAllStates(dls.qrCodeExport_btn_save_qrcode)
        }
        
        self.qrCodeSaveBtn.isEnabled = !isQRCodeSaved
        self.isQRCodeSaved = isQRCodeSaved
    }
    
    private func generateQRCodeBaseViewSnapShot() -> UIImage {
        let imgRenderer = UIGraphicsImageRenderer.init(bounds: qrCodeBase.bounds)
        
        return imgRenderer.image { (context) in
            qrCodeBase.layer.render(in: context.cgContext)
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
}
