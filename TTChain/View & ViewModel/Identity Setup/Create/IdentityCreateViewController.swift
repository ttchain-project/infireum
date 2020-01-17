//
//  IdentityCreateViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class IdentityCreateViewController: KLModuleViewController, KLVMVC {
    typealias Constructor = Void
    
//    @IBOutlet weak var nameTitleLabel: UILabel!
//    @IBOutlet weak var nameTextField: OWInputTextField!
    @IBOutlet weak var pwdTitleLabel: UILabel!
    @IBOutlet weak var pwdTextField: OWInputTextField!
    @IBOutlet weak var confirmPwdTitleLabel: UILabel!
    @IBOutlet weak var confirmTextField: OWInputTextField!
    fileprivate var pwdVisibleBtn: UIButton!
    @IBOutlet weak var pwdHintTitleLabel: UILabel!
    @IBOutlet weak var pwdHintTextField: OWInputTextField!
    
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var acceptPrivacyPolicyBtn: UIButton!
    
    private var fields: [OWInputTextField] {
        return [pwdTextField, confirmTextField, pwdHintTextField]
    }
    private var labels: [UILabel] {
        return [pwdTitleLabel, confirmPwdTitleLabel, pwdHintTitleLabel]
    }
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!

    typealias ViewModel = IdentityCreateViewModel
    var viewModel: IdentityCreateViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    var privacyVC:PrivacyPolicyViewController?
    
    lazy var hud: KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            descText: LM.dls.createID_hud_creating,
            spinnerColor: TM.palette.hud_spinner,
            textColor: TM.palette.hud_text
        )
    }()
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        setupUI()
        viewModel = ViewModel.init(
            input:
            IdentityCreateViewModel.InputSource(
//                nameInput: nameTextField.rx.text,
                pwdInput: pwdTextField.rx.text,
                confirmPwdInput: confirmTextField.rx.text,
                pwdHintInput: pwdHintTextField.rx.text,
                confirmInput: createBtn.rx.tap.asDriver(),
                accpetBtnInput:self.acceptPrivacyPolicyBtn
            ),
            output:
            IdentityCreateViewModel.OutputSource(

                onFinishCheckingInputValidity: {
                    [weak self] validity in
                    guard let wSelf = self else { return }
                    if case .valid = validity  {
                        self?.handleCreateIdentityResult()
                    }else {
                        wSelf.respondToFieldCheckValidityResult(validity: validity)
                    }
                },
                onUpdateEmptyFieldsStatus: {
                    [weak self] isValid in
                    guard let wSelf = self else { return }
                    let palette = ThemeManager.instance.theme.value.palette
                    wSelf.createBtn.backgroundColor =
                        isValid ? palette.btn_bgFill_enable_bg : palette.btn_bgFill_disable_bg
                }
            )
        )
        
        bindUI()
    }
    
    private func setupUI() {
        pwdVisibleBtn = UIButton.init(type: .custom)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_show"), for: .normal)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_hide"), for: .selected)
        pwdVisibleBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 44, height: 44))
        pwdVisibleBtn.isSelected = true
        
        confirmTextField.rightView = pwdVisibleBtn
        confirmTextField.rightViewMode = .always
        confirmTextField.isSecureTextEntry = true
        
        pwdTextField.isSecureTextEntry = true
        
//        nameTextField.delegate = self
        pwdTextField.delegate = self
        confirmTextField.delegate = self
        pwdHintTextField.delegate = self
        acceptPrivacyPolicyBtn.isSelected = true
    }
    
    fileprivate func showPrivacyPolicyVC() {
        let vc = PrivacyPolicyViewController.init(status: { (status) in
            self.acceptPrivacyPolicyBtn.isSelected = status
            self.privacyVC?.dismiss(animated: true)
        })
        self.privacyVC = vc
        self.present(vc, animated: true, completion: nil)
    }
    
    private func bindUI() {
        pwdVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pwdVisibleBtn.isSelected = !self.pwdVisibleBtn.isSelected
            self.confirmTextField.isSecureTextEntry = self.pwdVisibleBtn.isSelected
        })
        .disposed(by: bag)
        
        self.backButton.rx.klrx_tap.drive(onNext:{ _ in
            if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
        self.privacyPolicyLabel.rx.klrx_tap.drive(onNext:{
            self.showPrivacyPolicyVC()
        }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handleCreateIdentityResult() {
        let idenitySource = self.viewModel.getIdentitySource()
        let vc = BackupWalletViewController.instance(from: idenitySource)
        navigationController?.pushViewController(vc)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = nil
        createBtn.setTitleForAllStates(dls.g_next)
        backButton.setTitleForAllStates(lang.dls.g_cancel)
//        nameTitleLabel.text = dls.account
//        nameTextField.set(placeholder: dls.create_identity_username_placeholder)
        pwdTitleLabel.text =  dls.createID_placeholder_password
        pwdTextField.set(placeholder: dls.create_identity_password_placeholder)
        confirmPwdTitleLabel.text = dls.createID_placeholder_confirmPassword
        confirmTextField.set(placeholder: dls.create_identity_reenter_password_placeholder)
        pwdHintTitleLabel.text = dls.createID_placeholder_passwordNote
        pwdHintTextField.set(placeholder: dls.create_identity_password_reminder_placeholder)
        
        privacyPolicyLabel.text = dls.create_identity_privacy_policy_btn_title
    }
    
    override func renderTheme(_ theme: Theme) {

        self.hideDefaultNavBar()
        for field in fields {
            field.sepline.backgroundColor = theme.palette.sepline
            field.textColor = theme.palette.bg_fill_new
            field.placeHolderColor = theme.palette.input_placeholder
        }
        for label in labels {
            label.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        }
        createBtn.set(
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
        createBtn.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        createBtn.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
        privacyPolicyLabel.set(textColor: theme.palette.bg_fill_new, font: .owRegular(size:14))
        
    }
    
    private func respondToFieldCheckValidityResult(validity: ViewModel.InputValidity) {
        let dls = LM.dls
        switch validity {
        case .pwd_invalidFormat(let desc):
            showSimplePopUp(with: dls.createID_error_pwd_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .confirmPwd_invalidFormat(let desc):
            showSimplePopUp(with: dls.createID_error_confirmPwd_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .identity_invalidFormat(desc: let desc):
            showSimplePopUp(with: dls.createID_error_identityName_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .pwdHint_invalidFormat(desc: let desc):
            showSimplePopUp(with: dls.createID_error_pwdHint_title,
                            contents: desc,
                            cancelTitle: LM.dls.g_cancel,
                            cancelHandler: nil)
        case .emptyPwd:
            pwdTextField.becomeFirstResponder()
//        case .emptyIdentityName:
//            nameTextField.becomeFirstResponder()
        case .emptyPwdHint:
            pwdHintTextField.becomeFirstResponder()
        case .emptyConfirmPwd:
            confirmTextField.becomeFirstResponder()
        case .conditionsNotAccepted:
            self.privacyPolicyLabel.shake()
        case .valid: break
        }
    }


}

extension IdentityCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pwdTextField || textField == confirmTextField {
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
