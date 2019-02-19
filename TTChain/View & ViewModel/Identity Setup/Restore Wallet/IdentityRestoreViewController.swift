//
//  IdentityRestoreWalletViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/21.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HDWalletKit

final class IdentityRestoreViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    typealias ViewModel = IdentityRestoreViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: IdentityRestoreViewModel!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mnemonicBase: UIView!
    @IBOutlet weak var mnemonicTextView: KLPlaceholderTextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pwdTitleLabel: UILabel!
    
    @IBOutlet weak var userNameTextField: OWInputTextField!
    @IBOutlet weak var pwdTextField: OWInputTextField!
    @IBOutlet weak var confirmPwdTextField: OWInputTextField!
    @IBOutlet weak var pwdHintTextField: OWInputTextField!
    
    @IBOutlet weak var importBtn: UIButton!
    
    fileprivate var pwdVisibleBtn: UIButton!
    
    private var fields: [OWInputTextField] {
        return [userNameTextField, pwdTextField, confirmPwdTextField, pwdHintTextField]
    }
    
    lazy var hud: KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            descText: LM.dls.restoreIdentity_hud_restoring,
            spinnerColor: TM.palette.hud_spinner,
            textColor: TM.palette.hud_text
        )
    }()
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        setupUI()
        viewModel = ViewModel.init(
            input:
            IdentityRestoreViewModel.InputSource(
                mnemonicInput: mnemonicTextView.rx.text,
                pwdInput: pwdTextField.rx.text,
                userNameInput: userNameTextField.rx.text,
                confirmPwdInput: confirmPwdTextField.rx.text,
                pwdHintInput: pwdHintTextField.rx.text,
                confirmInput: importBtn.rx.tap.asDriver()
            ),
            output:
            IdentityRestoreViewModel.OutputSource(
//                onStartRestoreIdentity: {
//                    [weak self] in
//                    guard let wSelf = self else { return }
//                    wSelf.hud.startAnimating(inView: wSelf.navigationController!.view)
//
//                },
//                onFinishRestoreIdentity: {
//                    [weak self] (apiResult) in
//                    guard let wSelf = self else { return }
//                    wSelf.hud.updateType(KLHUD.HUDType.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")),
//                                         text: LM.dls
//                                            .restoreIdentity_hud_restoreSuccess)
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
//                        wSelf.hud.stopAnimating()
//
//                        switch apiResult {
//                        case .failed(error: let err):
//                            wSelf.showAPIErrorResponsePopUp(from: err, cancelTitle: LM.dls.g_cancel)
//                        case .success(let result):
//                            wSelf.handleRestoreIdentityResult(result)
//                        }
//
//                    })
//                },
                onFinishCheckingInputValidity: {
                    [weak self] validity in
                    guard let wSelf = self else { return }
                    if case .valid = validity  {
                        self?.handleRestoreIdentityResult()
                    }else {
                        wSelf.respondToFieldCheckValidityResult(validity: validity)
                    }
                },
                onUpdateEmptyFieldsStatus: {
                    [weak self] isValid in
                    guard let wSelf = self else { return }
                    let palette = ThemeManager.instance.theme.value.palette
                    wSelf.importBtn.isEnabled = isValid
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
        
        mnemonicBase.cornerRadius = 5
        
        userNameTextField.delegate = self
        pwdTextField.delegate = self
        confirmPwdTextField.delegate = self
        pwdHintTextField.delegate = self
        
    }
    
    private func bindUI() {
        pwdVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pwdVisibleBtn.isSelected = !self.pwdVisibleBtn.isSelected
            self.confirmPwdTextField.isSecureTextEntry = self.pwdVisibleBtn.isSelected
        })
            .disposed(by: bag)
        
        mnemonicTextView.rx.contentSize.map { $0.height }.bind(to: textViewHeight.rx.constant).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handleRestoreIdentityResult() {
        
        self.hud.startAnimating(inView: self.view)

        guard let pwd = self.viewModel.getPwdString(), let pwdHint = self.viewModel.getPwdHintValue(), let mnemonic = self.viewModel.getMnemonicString() else {
            showSimplePopUp(with: LM.dls.restoreIdentity_error_create_user_fail,
                            contents: "",
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
            self.hud.stopAnimating()

            return 
        }
        
        guard Identity.create(mnemonic: mnemonic, name: self.viewModel.getUserName(), pwd: pwd, hint: pwdHint) != nil else {
            self.hud.stopAnimating()
            #if DEBUG
            fatalError()
            #else
            showSimplePopUp(with: LM.dls.restoreIdentity_error_create_user_fail,
                            contents: "",
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
            return
            #endif
        }
        
        WalletCreator.createNewWallet(forChain: .btc, mnemonic: mnemonic, pwd: pwd, pwdHint: pwdHint).flatMap { response -> Single<Bool> in
            if response {
                return WalletCreator.createNewWallet(forChain: .eth, mnemonic: mnemonic, pwd: pwd, pwdHint: pwdHint)
            }else {
                return .error(GTServerAPIError.apiReject)
            }
            }.subscribe(onSuccess: {[unowned self] (status) in
                self.hud.stopAnimating()
                if status {
                    self.startBackupIdentityQRCodeFlow()
                }
            }) { (error) in
                self.hud.stopAnimating()
                self.showSimplePopUp(with: LM.dls.sortMnemonic_error_create_wallet_fail,
                                     contents: "",
                                     cancelTitle: LM.dls.g_cancel,
                                     cancelHandler: nil)
                
            }.disposed(by: bag)
        
//        let sources = result.walletsResource.map {
//            res -> (address: String, pKey: String, mnenomic: String?, isFromSystem: Bool, name: String, pwd: String, pwdHint: String, chainType: ChainType, mainCoinID: String) in
//            return (address: res.address,
//                    pKey: res.pKey,
//                    mnenomic: result.mnemonic,
//                    isFromSystem: true,
//                    name: Wallet.defaultName(ofMainCoin: res.mainCoin),
//                    pwd: result.pwd,
//                    pwdHint: result.pwdHint,
//                    chainType: res.mainCoin.owChainType,
//                    mainCoinID: res.mainCoin.walletMainCoinID!)
//        }
//
//        guard Wallet.create(identity: id, sources: sources) != nil else {
//            #if DEBUG
//            fatalError()
//            #else
//            showSimplePopUp(with: LM.dls.restoreIdentity_error_create_wallet_fail,
//                            contents: "",
//                            cancelTitle: LM.dls.g_cancel,
//                            cancelHandler: nil)
//            return
//            #endif
//        }
//
//        startBackupIdentityQRCodeFlow()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.restoreIdentity_title
        titleLabel.text = dls.restoreIdentity_label_able_to_change_pwd_note
        pwdTitleLabel.text = dls.restoreIdentity_label_settingPwd
        userNameTextField.set(placeholder: dls.qrCodeImport_info_placeholder_idName)
        importBtn.setTitleForAllStates(dls.restoreIdentity_btn_import)
        mnemonicTextView.placeholder = dls.restoreIdentity_placeholder_mnemonic
        pwdTextField.set(placeholder: dls.restoreIdentity_placeholder_walletPwd)
        confirmPwdTextField.set(placeholder: dls.restoreIdentity_placeholder_walletConfirmPwd)
        pwdHintTextField.set(placeholder: dls.restoreIdentity_placeholder_pwdHint)
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_2, barTint: theme.palette.nav_bg_clear)
        renderNavTitle(color: theme.palette.nav_item_2, font: .owMedium(size: 20))
//        navigationController?.navigationBar.renderShadow()
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: theme.palette.nav_item_2,
            image: #imageLiteral(resourceName: "navBarBackButton")
        )
        
        createRightBarButton(target: self, selector: #selector(toQRCodeCamera), image: #imageLiteral(resourceName: "scanQRCodeButton"), toColor: theme.palette.nav_item_2)
        
        titleLabel.set(
            textColor: theme.palette.label_main_1,
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
            font: UIFont.owRegular(size: 14)
        )
        importBtn.backgroundColor = theme.palette.btn_bgFill_enable_bg
//        let image = #imageLiteral(resourceName: "buttonPinkSolid").resizableImage(withCapInsets: .init(top: 0, left: 20, bottom: 0, right: 20), resizingMode: UIImageResizingMode.stretch)
//        importBtn.setBackgroundImage(image, for: .normal)

        mnemonicBase.set(
            borderInfo: (color: theme.palette.bgView_border, width: 1)
        )
        
        mnemonicTextView.textColor = theme.palette.input_text
        mnemonicTextView.placeholderLabel.textColor = theme.palette.input_placeholder
        importBtn.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        importBtn.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
    }
    
    private func respondToFieldCheckValidityResult(validity: ViewModel.InputValidity) {
        switch validity {
        case .pwd_invalidFormat(let desc):
            showSimplePopUp(with: LM.dls.restoreIdentity_error_pwd_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .confirmPwd_invalidFormat(let desc):
            showSimplePopUp(with: LM.dls.restoreIdentity_error_confirmPwd_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .mnemonic_invalidFormat(desc: let desc):
            showSimplePopUp(with: LM.dls.restoreIdentity_error_mnemonic_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .pwdHint_invalidFormat(desc: let desc):
            showSimplePopUp(with: LM.dls.restoreIdentity_error_pwdHint_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .emptyPwd:
            pwdTextField.becomeFirstResponder()
        case .emptyMnemonic:
            mnemonicTextView.becomeFirstResponder()
        case .emptyPwdHint:
            pwdHintTextField.becomeFirstResponder()
        case .emptyConfirmPwd:
            confirmPwdTextField.becomeFirstResponder()
            
        case .valid: break
        }
    }

    fileprivate var qrCodeVCNav: UINavigationController?
    @objc private func toQRCodeCamera() {
        let vc = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .importWallet(nil),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .mnemonic(let _mnemonic):
                        print("Get: \(_mnemonic)")
                        self.qrCodeVCNav?.dismiss(animated: true, completion: {
                            [unowned self] in
                            self.viewModel.updateMnenomic(source: _mnemonic)
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
    
    //MARK: - Routing
    func toMainTab() {
        let tab = xib(vc: MainTabBarViewController.self)
        present(tab, animated: true, completion: {
            IMUserManager.launch()
            MarketTestHandler.shared.launch()

        })
    }
    
    private var flow: IdentityQRCodeEncryptionFlow?
    func startBackupIdentityQRCodeFlow() {
        let id = Identity.singleton!
        flow = IdentityQRCodeEncryptionFlow.start(
            launchType: .restore_mnemonic,
            identity: id,
            onViewController: self,
            onComplete: { [weak self] (result) in
                DispatchQueue.main.async {
                    self?.toMainTab()
                    self?.flow = nil
                }
        })
    }
}

extension IdentityRestoreViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pwdTextField || textField == confirmPwdTextField {
            //No space character in pwd fields.
            guard !string.contains(" ") else { return false }
        }
        
        var text: String
        if let tf_text = textField.text {
            text = (tf_text as NSString).replacingCharacters(in: range, with: string)
        }else {
            text = string
        }
        
        guard !text.hasPrefix(" ") else { return false }
        return true
    }
}
