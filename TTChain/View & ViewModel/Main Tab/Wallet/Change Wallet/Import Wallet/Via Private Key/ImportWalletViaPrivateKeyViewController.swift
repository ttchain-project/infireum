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
    enum Purpose {
        case `import`
        case create
    }
    struct Config {
        let mainCoinID: String
        /// The Private Key (might be scanned from QRCode)
        let defaultPKey: String?
        let purpose:Purpose?
        
    }
    
    typealias Constructor = Config
    typealias ViewModel = ImportWalletViaPrivateKeyViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: ImportWalletViaPrivateKeyViewModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pKeyBase: UIView!
    @IBOutlet weak var pKeyTextView: KLPlaceholderTextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var privateKeyStackView: UIStackView!
    @IBOutlet weak var enterWalleNameLabel: UILabel!
    @IBOutlet weak var walletNameTextField: OWInputTextField!
    
    @IBOutlet weak var pwdTextField: OWInputTextField!
    @IBOutlet weak var enterPasswordLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPwdTextField: OWInputTextField!
    
    @IBOutlet weak var passwordHintLabel: UILabel!
    @IBOutlet weak var pwdHintTextField: OWInputTextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var instructionLabel1: UILabel!
    @IBOutlet weak var instructionLabel2: UILabel!
    
    fileprivate var pwdVisibleBtn: UIButton!
    
    private var fields: [OWInputTextField] {
        return [walletNameTextField,pwdTextField, confirmPwdTextField, pwdHintTextField]
    }
    
    private var labels: [UILabel] {
        return [enterWalleNameLabel,enterPasswordLabel, confirmPasswordLabel, passwordHintLabel]
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
    
    var purpose: Purpose!
    
    func config(constructor: Config) {
        view.layoutIfNeeded()
        self.purpose = constructor.purpose ?? .import
        
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
                confirmInput: confirmButton.rx.tap.asDriver(),
                walletName:self.walletNameTextField.rx.text,
                purpose:self.purpose
            ),
            output:
            ImportWalletViaPrivateKeyViewModel.OutputSource(
                onStartImportWallet: {
                    [weak self] in
                    guard let wSelf = self else { return }
                    wSelf.hud.startAnimating(inView: wSelf.view)
                    
                },
                onFinishImportWallet: {
                    [weak self] in
                    guard let wSelf = self else { return }
                    wSelf.hud.stopAnimating()
                    wSelf.showSuccessPopup()
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
                    wSelf.confirmButton.backgroundColor =
                        isValid ? palette.btn_bgFill_enable_bg : palette.btn_bgFill_disable_bg
                }
            )
        )

        self.viewModel.output.onErrorMessage.bind(to:self.rx.message).disposed(by:bag)
        bindUI()
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    func showSuccessPopup() {
        let successPopup = SuccessWalletViewController.init(purpose: self.purpose) {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        self.present(successPopup, animated: false, completion: nil)
    }
    
    private func setupUI() {
        self.privateKeyStackView.isHidden = purpose == .create

        pwdVisibleBtn = UIButton.init(type: .custom)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_show"), for: .normal)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_hide"), for: .selected)
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
        
        self.backButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.navigationController?.viewControllers.first == self {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
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
        let name = result.walletName
        
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
        title = self.purpose == .import ?  dls.importWallet_privateKey_import_general_wallet(coin.inAppName!) : lang.dls.create_new_wallet + "(\(coin.inAppName!))"
        
        titleLabel.text = dls.importWallet_privateKey_label_desc_private_key
        confirmButton.setTitleForAllStates(dls.g_confirm)
        backButton.setTitleForAllStates(lang.dls.g_cancel)

        
        pKeyTextView.placeholder = dls.importWallet_privateKey_placeholder_hint_fill_in_private_key
        
        enterPasswordLabel.text = dls.restoreIdentity_placeholder_walletPwd
        
        pwdTextField.set(
            placeholder: dls.create_identity_password_placeholder
        )
        
        confirmPasswordLabel.text = dls.restoreIdentity_placeholder_walletConfirmPwd
        confirmPwdTextField.set(
            placeholder: dls.create_identity_reenter_password_placeholder
        )
        passwordHintLabel.text = dls.restoreIdentity_placeholder_pwdHint
        pwdHintTextField.set(
            placeholder: dls.create_identity_password_reminder_placeholder
        )
        
        enterWalleNameLabel.text = dls.strValidate_field_walletName + "(\(coin.inAppName!))"
        walletNameTextField.set(
            placeholder: dls.new_wallet_name
        )
        
        self.instructionLabel1.text = "* " + dls.add_wallet_password_warning_one
        self.instructionLabel2.text = "* " +  dls.add_wallet_password_warning_two
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_2, barTint: theme.palette.nav_bar_tint)
        
        navigationController?.navigationBar.renderShadow()
        
        if navigationController?.viewControllers.first == self {
            changeLeftBarButtonToDismissToRoot(tintColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        }else {
            changeBackBarButton(
                toColor: theme.palette.nav_item_2,
                image: #imageLiteral(resourceName: "btn_previous_light")
            )
        }
        
        if purpose == .import {
            createRightBarButton(target: self, selector: #selector(toQRCodeCamera), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), toColor: theme.palette.nav_item_1)
        }
        
        titleLabel.set(
            textColor: theme.palette.label_sub,
            font: UIFont.owRegular(size: 12)
        )
        
        for field in fields {
            field.sepline.backgroundColor = theme.palette.sepline
            field.textColor = theme.palette.input_text
            field.placeHolderColor = theme.palette.input_placeholder
        }
        
        for label in labels {
            label.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 12))
        }
        confirmButton.set(
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
        pKeyBase.set(
            borderInfo: (color: theme.palette.bgView_border, width: 1)
        )
        
        pKeyTextView.textColor = theme.palette.input_text
        
        confirmButton.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        confirmButton.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
        
        instructionLabel1.set(textColor: theme.palette.bg_fill_new, font: .owRegular(size:12))
        instructionLabel2.set(textColor: theme.palette.bg_fill_new, font: .owRegular(size:12))
        
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
