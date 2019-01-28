//
//  OWQRCodeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/19.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class OWQRCodeViewController: OWQRCodeBaseViewController, KLVMVC {
    struct _Constructor {
        let purpose: Purpose
        let resultCallback: ResultCallback
        let isTypeLocked: Bool
    }
    
    typealias Constructor = _Constructor
    
    typealias ViewModel = OWQRCodeViewModel
    var viewModel: OWQRCodeViewModel!
    
    fileprivate var cornerLayer: CAShapeLayer!
    
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var btnStack: UIStackView!
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var importWalletBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    
    fileprivate var focusingBtn: UIButton!
    
    fileprivate lazy var indicator: UIView = {
        let indi = UIView(frame:
            CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 10, height: 10)
            )
        )
        
        indi.backgroundColor = .owWhite
        indi.layer.cornerRadius = 5
        
        return indi
    }()
    
    enum Purpose {
        //All associated-values is mainCoinID
        case general(String?)
        case withdrawal(String?)
        case restoreIdentity
        case importWallet(String?)
        case addContacts(String?)
        case userId
        
        var targetMainCoinID: String? {
            switch self {
            case .restoreIdentity, .userId: return nil
            case .general(let id), .addContacts(let id), .importWallet(let id), .withdrawal(let id):
                return id
            }
        }
        
        var targetType: ChainType? {
            if let _id = targetMainCoinID {
                let coin = Coin.getCoin(ofIdentifier: _id)
                return coin?.owChainType
            }else {
                return nil
            }
        }
        
        var scanningType: ScanningType {
            switch self {
            case .general: return .withdrawal
            case .withdrawal: return .withdrawal
            case .importWallet: return .importWallet
            case .addContacts: return .contact
            case .restoreIdentity: return .restoreIdentity
            case .userId: return .userId
            }
        }
        
        //        var supportSourceTypes: [OWStringValidator.ValidationSourceType] {
        //            switch self {
        //            case .general(let type):
        //                return [
        //                    .withdrawal(type: type),
        //                    .privateKey(type: type),
        //                    .mnemonic(type: type),
        //                    .addressBook(type: type)
        //                ]
        //            case .importWallet(let type):
        //                return [
        //                    .privateKey(type: type),
        //                    .mnemonic(type: type)
        //                ]
        //            case .addContacts(let type):
        //                return [ .addressBook(type: type) ]
        //            case .withdrawal(let type):
        //                return [ .withdrawal(type: type) ]
        //            case .restoreIdentity:
        //                return [ .mnemonic(type: nil) ]
        //            }
        //        }
    }
    
    enum ScanningType {
        case withdrawal
        case importWallet
        case contact
        case restoreIdentity
        case userId
        
        func supportSourceTypes(ofPurpose purpose: Purpose) -> [OWStringValidator.ValidationSourceType] {
            switch self {
            case .importWallet:
                switch purpose {
                case .restoreIdentity:
                    return [ .mnemonic(id: nil) ]
                case .importWallet(let id), .general(let id):
                    return [
                        .privateKey(id: id),
                        .mnemonic(id: id)
                    ]
                default: return []
                }
            case .withdrawal:
                return [ .withdrawal(id: purpose.targetMainCoinID) ]
            case .contact:
                return [ .addressBook(id: purpose.targetMainCoinID) ]
            case .restoreIdentity:
                return [ .identityQRCode ]
            case .userId:
                return [ .userId ]
            }
        }
    }
    
    typealias ResultCallback = (OWStringValidator.ValidationResultType, Purpose, ScanningType) -> Void
    var resultCallback: ResultCallback?
    
    private var _purpose: Purpose!
    public var scanningType: Observable<ScanningType> {
        return _scanningType.asObservable()
    }
    
    private lazy var _scanningType: BehaviorRelay<ScanningType> = {
        return .init(value: .importWallet)
    }()
    
    internal func config(constructor: OWQRCodeViewController._Constructor) {
        resultCallback = constructor.resultCallback
        
        view.layoutIfNeeded()
        _purpose = constructor.purpose
        _scanningType.accept(_purpose.scanningType)
        
        let withdrawal: Driver<ScanningType> = withdrawalBtn.rx.tap.asDriver().map {
            return .withdrawal
        }
        
        let importWallet: Driver<ScanningType> = importWalletBtn.rx.tap.asDriver().map {
            return .importWallet
        }
        
        let addContact: Driver<ScanningType> = contactBtn.rx.tap.asDriver().map {
            return .contact
        }
        
        let scanningType: Driver<ScanningType> = Driver.merge(withdrawal, importWallet, addContact)
        let sourceChoose: Driver<[OWStringValidator.ValidationSourceType]> =
            scanningType.map { $0.supportSourceTypes(ofPurpose: constructor.purpose) }
        
        scanningType.drive(_scanningType).disposed(by: bag)
        
        viewModel = ViewModel.init(
            input:
            OWQRCodeViewModel.InputSource(
                validationTypesSource: sourceChoose
                    .startWith(
                        constructor.purpose.scanningType
                            .supportSourceTypes(
                                ofPurpose: constructor.purpose)
                )
            ),
            output:
            OWQRCodeViewModel.OutputSource(
                validateResultHandler: { [unowned self] (result) in
                    self.handleCheckResult(result: result)
            })
        )
        
        setupUI()
        bindUI()
        
        if constructor.isTypeLocked {
            changeToTypeLockedLayout()
        }
        
        switch constructor.purpose.scanningType {
        case .contact:
            moveIndicator(toBtn: contactBtn, animated: false)
        case .importWallet, .restoreIdentity:
            moveIndicator(toBtn: importWalletBtn, animated: false)
        case .withdrawal:
            moveIndicator(toBtn: withdrawalBtn, animated: false)
        case .userId:
            moveIndicator(toBtn: withdrawalBtn, animated: false)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let btn = focusingBtn, indicator.center.x != btn.center.x || indicator.center.y != btn.frame.maxY + 12 {
            moveIndicator(toBtn: btn, animated: false)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let btn = focusingBtn, indicator.center.x != btn.center.x || indicator.center.y != btn.frame.maxY + 12 {
            moveIndicator(toBtn: btn, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate let sideLength: CGFloat = 40
    fileprivate let cornerRad: CGFloat = 5
    fileprivate let lineWidth: CGFloat = 2
    
    override func configureLayout() {
        super.configureLayout()
        cornerLayer = CAShapeLayer.init()
        
        cornerLayer.lineWidth = lineWidth
        cornerLayer.strokeColor = UIColor.owWhite.cgColor
        cornerLayer.fillColor = UIColor.clear.cgColor
        
        let path = leftUpPath(in: validRect)
        path.addPath(rightUpPath(in: validRect))
        path.addPath(leftDownPath(in: validRect))
        path.addPath(rightDownPath(in: validRect))
        
        cornerLayer.path = path
        cornerLayer.lineCap = kCALineCapRound
        
        view.layer.addSublayer(cornerLayer)
        
        view.bringSubview(toFront: introLabel)
        view.bringSubview(toFront: withdrawalBtn)
        view.bringSubview(toFront: importWalletBtn)
        view.bringSubview(toFront: contactBtn)
        view.bringSubview(toFront: indicator)
    }
    
    private func leftUpPath(in square: CGRect) -> CGMutablePath {
        let path = UIBezierPath.init()
        let left = CGPoint.init(x: square.origin.x, y: square.origin.y + sideLength)
        path.move(to: left)
        
        let straightVertical = CGPoint.init(x: left.x, y: square.minY + cornerRad)
        path.addLine(to: straightVertical)
        
        let arcCenter = CGPoint.init(x: square.origin.x + cornerRad, y: square.origin.y + cornerRad)
        path.addArc(
            withCenter: arcCenter,
            radius: cornerRad,
            startAngle: .pi,
            endAngle: .pi * 3 / 2,
            clockwise: true
        )
        
        let straightHorizon = CGPoint.init(x: square.minX + sideLength, y: square.minY)
        path.addLine(to: straightHorizon)
        
        return path.cgPath.mutableCopy()!
    }
    
    private func rightUpPath(in square: CGRect) -> CGMutablePath {
        let path = UIBezierPath.init()
        let right = CGPoint.init(x: square.maxX, y: square.minY + sideLength)
        path.move(to: right)
        
        let straightVertical = CGPoint.init(x: right.x, y: square.minY + cornerRad)
        path.addLine(to: straightVertical)
        
        let arcCenter = CGPoint.init(x: square.maxX - cornerRad, y: square.minY + cornerRad)
        path.addArc(
            withCenter: arcCenter,
            radius: cornerRad,
            startAngle: 0,
            endAngle: .pi * 3 / 2,
            clockwise: false
        )
        
        let straightHorizon = CGPoint.init(x: square.maxX - sideLength, y: square.minY)
        path.addLine(to: straightHorizon)
        
        return path.cgPath.mutableCopy()!
    }
    
    private func leftDownPath(in square: CGRect) -> CGMutablePath {
        let path = UIBezierPath.init()
        let left = CGPoint.init(x: square.minX, y: square.maxY - sideLength)
        path.move(to: left)
        
        let straightVertical = CGPoint.init(x: left.x, y: square.maxY - cornerRad)
        path.addLine(to: straightVertical)
        
        let arcCenter = CGPoint.init(x: square.minX + cornerRad, y: square.maxY - cornerRad)
        path.addArc(
            withCenter: arcCenter,
            radius: cornerRad,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: false
        )
        
        let straightHorizon = CGPoint.init(x: square.minX + sideLength, y: square.maxY)
        path.addLine(to: straightHorizon)
        
        return path.cgPath.mutableCopy()!
    }
    
    private func rightDownPath(in square: CGRect) -> CGMutablePath {
        let path = UIBezierPath.init()
        let right = CGPoint.init(x: square.maxX, y: square.maxY - sideLength)
        path.move(to: right)
        
        let straightVertical = CGPoint.init(x: right.x, y: square.maxY - cornerRad)
        path.addLine(to: straightVertical)
        
        let arcCenter = CGPoint.init(x: square.maxX - cornerRad, y: square.maxY - cornerRad)
        path.addArc(
            withCenter: arcCenter,
            radius: cornerRad,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        let straightHorizon = CGPoint.init(x: square.maxX - sideLength, y: square.maxY)
        path.addLine(to: straightHorizon)
        
        return path.cgPath.mutableCopy()!
    }
    
    override func findQRCode(content: String) {
        viewModel.updateNewScannedSource(content)
    }
    
    func setupUI() {
        if indicator.superview == nil {
            view.addSubview(indicator)
        }
        
        createImgPickerNavItem()
    }
    
    private func createImgPickerNavItem() {
        let dls = LM.dls
        let palette = TM.palette
        _ = createRightBarButton(
            target: self,
            selector: #selector(startPickPhotoFromCamera),
            title: "選擇相片",
            toColor: palette.nav_item_2,
            size: CGSize.init(width: 50, height: 30)
        )
    }
    
    func bindUI() {
        scanningType.map {
            [unowned self]
            type -> UIButton in
            switch type {
            case .contact:
                return self.contactBtn
            case .importWallet, .restoreIdentity:
                return self.importWalletBtn
            case .withdrawal:
                return self.withdrawalBtn
            case .userId: return self.withdrawalBtn
            }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] btn in
                self.moveIndicator(toBtn: btn, animated: true)
            })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.qrcode_title
        introLabel.text = dls.qrcode_label_intro
        withdrawalBtn.setTitle(dls.qrcode_btn_withdrawal, for: .normal)
        importWalletBtn.setTitle(dls.qrcode_btn_importWallet, for: .normal)
        contactBtn.setTitle(dls.qrcode_btn_contact, for: .normal)
    }
    
    override func renderTheme(_ theme: Theme) {
        navigationController?.navigationBar.barTintColor = theme.palette.nav_bg_2
        navigationController?.navigationBar.tintColor = theme.palette.nav_item_2
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : theme.palette.nav_item_2,
            NSAttributedStringKey.font : UIFont.owDemiBold(size: 20)
        ]
        
        changeLeftBarButtonToDismissToRoot(tintColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavWhite"))
        
        introLabel.set(
            textColor: theme.palette.specific(color: .owWhite), font: UIFont.owMedium(size: 15)
        )
        
        withdrawalBtn.set(
            textColor: theme.palette.specific(color: .owWhite),
            font: UIFont.owMedium(size: 15)
        )
        
        importWalletBtn.set(
            textColor: theme.palette.specific(color: .owWhite),
            font: UIFont.owMedium(size: 15)
        )
        
        contactBtn.set(
            textColor: theme.palette.specific(color: .owWhite),
            font: UIFont.owMedium(size: 15)
        )
    }
    
    override func handleNetworkStatusChange(_ status: NetworkStatus) {
        
    }
    
    private func changeToTypeLockedLayout() {
        btnStack.isHidden = true
        indicator.isHidden = true
    }
    
    
    private(set) var imgPicker: UIImagePickerController?
    @objc private func startPickPhotoFromCamera() {
        DispatchQueue.main.async {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization {
                    [weak self] (status) in
                    self?.handleUserAlbumAuthResultStatus(status)
                }
            case .authorized:
                self.presentImagePicker()
            case .denied, .restricted:
                self.presentAlbumAuthorizationDeniedAlert()
            }
        }
    }
    
    private func presentImagePicker() {
        imgPicker = UIImagePickerController.init()
        imgPicker?.delegate = self
        imgPicker?.sourceType = .savedPhotosAlbum
        imgPicker?.allowsEditing = false
        present(imgPicker!, animated: true, completion: nil)
    }
    
    private func handleUserAlbumAuthResultStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            startPickPhotoFromCamera()
        case .denied, .restricted:
            presentAlbumAuthorizationDeniedAlert()
        case .notDetermined:
            startPickPhotoFromCamera()
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
    
    private var hud: KLHUD?
    private func startAnalyzeImgQRCodeContent(img: UIImage) {
        let scanner = QRCodeImgScanner.init()
        
        hud = KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(
                    width: 100,
                    height: 100)
            ),
            descText: LM.dls.qrcodeProcess_hud_decoding
        )
        
        hud?.startAnimating(inView: self.view)
        
        DispatchQueue.global().async {
            guard let firstResult = scanner.detectQRCodeMsgContents(img)?.first else {
                DispatchQueue.main.async {
                    self.hud?.stopAnimating()
                    self.hud = nil
                    self.presentImgAnalyzeFailedAlert()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.hud?.stopAnimating()
                self.hud = nil
                self.findQRCode(content: firstResult)
            }
        }
        
    }
    
    private func presentImgAnalyzeFailedAlert() {
        let dls = LM.dls
        showSimplePopUp(
            with: dls.qrcodeProcess_alert_title_cannot_find_qrcode_in_img,
            contents: dls.qrcodeProcess_alert_content_cannot_find_qrcode_in_img,
            cancelTitle: dls.g_cancel,
            cancelHandler: nil
        )
    }
}

extension OWQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true) {
                [weak self] in
                self?.startAnalyzeImgQRCodeContent(img: image)
            }
        }else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - Indicator moving
extension OWQRCodeViewController {
    fileprivate func moveIndicator(toBtn btn: UIButton, animated: Bool) {
        var targetCenter = navigationController!.view.convert(btn.center, from: btnStack)
        targetCenter.y += (btn.frame.height * 0.5 + 12)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.indicator.center = targetCenter
            }
        }else {
            self.indicator.center = targetCenter
        }
        
        self.focusingBtn = btn
    }
}

// MARK: - Result Handler
extension OWQRCodeViewController {
    fileprivate func handleCheckResult(result: OWStringValidator.ValidationResultType) {
        print("Get result \(result)")
        //TODO: Handle error type here.
        // However send all the event back to the callback.
        switch result {
        case .privateKey(let pKey, possibleAddresssesInfo: let possiblesAddressInfos):
            if let mainCoinID = _purpose.targetMainCoinID {
                //Target a specific wallet type info
                if let idx = possiblesAddressInfos.index(where: { (info) -> Bool in
                    return info.mainCoin.identifier == mainCoinID
                }) {
                    resultCallback?(
                        .privateKey(
                            pKey,
                            possibleAddresssesInfo: [possiblesAddressInfos[idx]]
                        ),
                        self._purpose,
                        self._scanningType.value
                    )
                } else {
                    //DICUSSTION: Should the vc handle the filter here?
                    resultCallback?(.unsupported(pKey), self._purpose, self._scanningType.value)
                }
            }else {
                //Prepare enter the source pick part, make sure there's no picking process here.
                guard navigationController?.presentedViewController == nil else {
                    return
                }
                
                pickPrivateKeyWalletSource(from: possiblesAddressInfos)
                    .subscribe(
                        onSuccess: {
                            [unowned self]
                            info in
                            guard  let _info = info else { return }
                            self.resultCallback?(
                                .privateKey(
                                    pKey,
                                    possibleAddresssesInfo: [_info]
                                ),
                                self._purpose,
                                self._scanningType.value
                            )
                        }
                    )
                    .disposed(by: bag)
            }
        case .unsupported:
            presentUnsupportWarning(fromResult: result)
        case .userId:
            resultCallback?(result, self._purpose, self._scanningType.value)
            dismiss(animated: true, completion: nil)
        default:
            resultCallback?(result, self._purpose, self._scanningType.value)
        }
    }
    
    fileprivate func presentUnsupportWarning(fromResult result: OWStringValidator.ValidationResultType) {
        let dls = LM.dls
        showSimplePopUp(
            with: dls.qrcodeProcess_alert_title_cannot_decode_qrcode_in_img,
            contents: dls.qrcodeProcess_alert_content_cannot_decode_qrcode_in_img,
            cancelTitle: LM.dls.g_cancel,
            cancelHandler: {
                [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.resultCallback?(result, wSelf._purpose, wSelf._scanningType.value)
            }
        )
    }
    
    fileprivate func pickPrivateKeyWalletSource(from sources: [OWStringValidator.ValidationResultType.AddressInfo]) -> Single<OWStringValidator.ValidationResultType.AddressInfo?> {
        return Single.create(subscribe: { [unowned self] (result) -> Disposable in
            let alert = UIAlertController.init(
                title: LM.dls.qrcode_actionSheet_pickChainTypeToImport_title,
                message: LM.dls.qrcode_actionSheet_pickChainTypeToImport_content,
                preferredStyle: .actionSheet)
            
            sources.forEach({ (source) in
                let actionTitle: String = LM.dls.qrcode_actionSheet_btn_mainCoinType(source.mainCoin.inAppName!)
                
                let action = UIAlertAction.init(title: actionTitle, style: .default, handler: { _ in
                    result(.success(source))
                })
                
                alert.addAction(action)
            })
            
            let cancel = UIAlertAction.init(title: LM.dls.g_cancel,
                                            style: .cancel,
                                            handler: { (_) in
                                                result(.success(nil))
            })
            
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        })
    }
}
