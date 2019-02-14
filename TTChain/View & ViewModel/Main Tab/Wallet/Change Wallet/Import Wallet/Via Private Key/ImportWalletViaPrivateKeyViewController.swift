//
//  ImportWalletViaPrivateKeyViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ImportWalletViaPrivateKeyViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let mainCoinID: String
        /// The Private Key (might be scanned from QRCode)
        let defaultPKey: String?
    }
    
    typealias Constructor = Config
    typealias ViewModel = ImportWalletViaPrivateKeyViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: ImportWalletViaPrivateKeyViewModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pKeyBase: UIView!
    @IBOutlet weak var pKeyTextView: KLPlaceholderTextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pwdTitleLabel: UILabel!
    
    @IBOutlet weak var pwdTextField: OWInputTextField!
    @IBOutlet weak var confirmPwdTextField: OWInputTextField!
    @IBOutlet weak var pwdHintTextField: OWInputTextField!
    
    @IBOutlet weak var importBtn: UIButton!
    
    fileprivate var pwdVisibleBtn: UIButton!
    
    private var fields: [OWInputTextField] {
        return [pwdTextField, confirmPwdTextField, pwdHintTextField]
    }
    
    lazy var hud: KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            descText: LM.dls.importWallet_privateKey_hud_importing,
            spinnerColor: TM.palette.hud_spinner,
            textColor: TM.palette.hud_text
        )
    }()
    
    func config(constructor: Config) {
        view.layoutIfNeeded()
        setupUI()
        viewModel = ViewModel.init(
            input:
            ImportWalletViaPrivateKeyViewModel.InputSource(
                mainCoinID: constructor.mainCoinID,
                defaultPKey: constructor.defaultPKey,
                pKeyInput: pKeyTextView.rx.text,
                pwdInput: pwdTextField.rx.text,
                confirmPwdInput: confirmPwdTextField.rx.text,
                pwdHintInput: pwdHintTextField.rx.text,
                confirmInput: importBtn.rx.tap.asDriver()
            ),
            output:
            ImportWalletViaPrivateKeyViewModel.OutputSource(
                onStartImportWallet: {
                    [weak self] in
                    guard let wSelf = self else { return }
                    wSelf.hud.startAnimating(inView: wSelf.navigationController!.view)
                    
                },
                onFinishImportWallet: {
                    [weak self] (apiResult) in
                    guard let wSelf = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        switch apiResult {
                        case .failed(error: let err):
                            wSelf.showAPIErrorResponsePopUp(from: err, cancelTitle: LM.dls.g_cancel)
                        case .success(let result):
                            wSelf.hud.updateType(
                                KLHUD.HUDType.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")),
                                text: LM.dls.importWallet_privateKey_hud_imported
                            )
                            wSelf.handleImportWalletResult(result)
                            wSelf.notifyUserQRCodeUpdated()
                        }
                        
                        wSelf.hud.stopAnimating()
                    })
                },
                onFinishCheckingInputValidity: {
                    [weak self] validity in
                    guard let wSelf = self else { return }
                    wSelf.respondToFieldCheckValidityResult(validity: validity)
                },
                onUpdateEmptyFieldsStatus: {
                    [weak self] isValid in
                    guard let wSelf = self else { return }
                    let palette = ThemeManager.instance.theme.value.palette
                    wSelf.importBtn.backgroundColor =
                        isValid ? palette.btn_bgFill_enable_bg : palette.btn_bgFill_disable_bg
                }
            )
        )
        
        bindUI()
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func setupUI() {
        pwdVisibleBtn = UIButton.init(type: .custom)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOn"), for: .normal)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOff"), for: .selected)
        pwdVisibleBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 44, height: 44))
        pwdVisibleBtn.isSelected = true
        
        confirmPwdTextField.rightView = pwdVisibleBtn
        confirmPwdTextField.rightViewMode = .always
        confirmPwdTextField.isSecureTextEntry = true
        
        pwdTextField.isSecureTextEntry = true
        
        pKeyBase.cornerRadius = 5
        
    }
    
    private func bindUI() {
        pwdVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pwdVisibleBtn.isSelected = !self.pwdVisibleBtn.isSelected
            self.confirmPwdTextField.isSecureTextEntry = self.pwdVisibleBtn.isSelected
        })
            .disposed(by: bag)
        
        pKeyTextView.rx.contentSize.map { $0.height }.bind(to: textViewHeight.rx.constant).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handleImportWalletResult(_ result: ViewModel.CreateResult) {
        guard let ids = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil),
            ids.count == 1, let id = ids.first else {
                return errorDebug(response: ())
        }
        
        let mainCoin = Coin.getCoin(ofIdentifier: viewModel.input.mainCoinID)!
        let name = Wallet.importedWalletName(ofMainCoin: mainCoin)
        
        guard let newWallet = Wallet.create(
            identity: id,
            source: (
                address: result.address,
                pKey: result.pKey,
                mnenomic: nil,
                isFromSystem: false,
                name: name,
                pwd: result.pwd,
                pwdHint: result.pwdHint,
                chainType: mainCoin.owChainType,
                mainCoinID: mainCoin.walletMainCoinID!
            )
            ) else {
                return errorDebug(response: ())
        }
        
        OWRxNotificationCenter.instance.notifyWalletImported(of: newWallet)
    }
    
    private var flow: IdentityQRCodeEncryptionFlow?
    private func notifyUserQRCodeUpdated() {
        flow = IdentityQRCodeEncryptionFlow.start(
            launchType: .importWallet,
            identity: Identity.singleton!,
            onViewController: self,
            onComplete: { [weak self] (result) in
                self?.dismiss(animated: true, completion: nil)
            }
        )
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        let mainCoinID = viewModel.input.mainCoinID
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        title = dls.importWallet_privateKey_import_general_wallet(coin.inAppName!)
        
        titleLabel.text = dls.importWallet_privateKey_label_desc_private_key
        pwdTitleLabel.text = dls.importWallet_privateKey_label_setPwd
        importBtn.setTitleForAllStates(dls.importWallet_privateKey_btn_startImport)
        
        pKeyTextView.placeholder = dls.importWallet_privateKey_placeholder_hint_fill_in_private_key
        
        pwdTextField.set(
            placeholder: dls.importWallet_privateKey_placeholder_walletPwd
        )
        
        confirmPwdTextField.set(
            placeholder: dls.importWallet_privateKey_placeholder_confirmPwd
        )
        
        pwdHintTextField.set(
            placeholder: dls.importWallet_privateKey_placeholder_pwdHint
        )
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bg_1)
        
        navigationController?.navigationBar.renderShadow()
        
        if navigationController?.viewControllers.first == self {
            changeLeftBarButtonToDismissToRoot(tintColor: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        }else {
            changeBackBarButton(
                toColor: theme.palette.nav_item_1,
                image: #imageLiteral(resourceName: "arrowNavBlack")
            )
        }
        
        createRightBarButton(target: self, selector: #selector(toQRCodeCamera), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), toColor: theme.palette.nav_item_1)
        
        titleLabel.set(
            textColor: theme.palette.label_sub,
            font: UIFont.owRegular(size: 12)
        )
        
        pwdTitleLabel.set(
            textColor: theme.palette.label_main_1,
            font: .owRegular(size: 14)
        )
        
        for field in fields {
            field.sepline.backgroundColor = theme.palette.sepline
            field.textColor = theme.palette.input_text
            field.placeHolderColor = theme.palette.input_placeholder
        }
        
        importBtn.set(
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
        pKeyBase.set(
            borderInfo: (color: theme.palette.bgView_border, width: 1)
        )
        
        pKeyTextView.textColor = theme.palette.input_text
        
        importBtn.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        importBtn.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
    }
    
    private func respondToFieldCheckValidityResult(validity: ViewModel.InputValidity) {
        let dls = LM.dls
        switch validity {
        case .pwd_invalidFormat:
            showSimplePopUp(
                with: dls.importWallet_privateKey_error_pwd_invalid_format,
                contents: dls.importWallet_privateKey_error_pwd_invalid_format_content,
                cancelTitle: LM.dls.g_cancel,
                cancelHandler: nil
            )
        case .confirmPwd_notMatchPwd:
            showSimplePopUp(
                with: dls.importWallet_privateKey_error_confirmPwd_diff_with_pwd,
                contents: dls.importWallet_privateKey_error_confirmPwd_diff_with_pwd_content,
                cancelTitle: LM.dls.g_cancel,
                cancelHandler: nil
            )
        case .alreadyHasSameWallet:
            showSimplePopUp(
                with: dls.importWallet_privateKey_error_wallet_exist_already,
                contents: "",
                cancelTitle: LM.dls.g_cancel,
                cancelHandler: nil
            )
        default: return
        }
    }
    
    fileprivate var qrCodeVCNav: UINavigationController?
    @objc private func toQRCodeCamera() {
        let vc = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .importWallet(viewModel.input.mainCoinID),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .privateKey(let result):
                        self.qrCodeVCNav?.dismiss(animated: true, completion: {
                            self.viewModel.updatePKey(result.0)
                        })
                    default: break
                    }
                },
                isTypeLocked: true
            )
        )
        
        qrCodeVCNav = vc
        present(vc, animated: true, completion: nil)
    }
}
