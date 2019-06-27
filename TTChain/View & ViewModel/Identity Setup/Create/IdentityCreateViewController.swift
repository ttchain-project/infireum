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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: OWInputTextField!
    @IBOutlet weak var pwdTextField: OWInputTextField!
    @IBOutlet weak var confirmTextField: OWInputTextField!
    fileprivate var pwdVisibleBtn: UIButton!
    @IBOutlet weak var pwdHintTextField: OWInputTextField!
    
    private var fields: [OWInputTextField] {
        return [nameTextField, pwdTextField, confirmTextField, pwdHintTextField]
    }
    
    @IBOutlet weak var createBtn: UIButton!
    
    typealias ViewModel = IdentityCreateViewModel
    var viewModel: IdentityCreateViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
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
                nameInput: nameTextField.rx.text,
                pwdInput: pwdTextField.rx.text,
                confirmPwdInput: confirmTextField.rx.text,
                pwdHintInput: pwdHintTextField.rx.text,
                confirmInput: createBtn.rx.tap.asDriver()
            ),
            output:
            IdentityCreateViewModel.OutputSource(
//                onStartCreateIdentity: {
//                    [weak self] in
//                    guard let wSelf = self else { return }
//                    wSelf.hud.startAnimating(inView: wSelf.view)
//
//                },
//                onFinishCreateIdentity: {
//                    [weak self] (apiResult) in
//                    guard let wSelf = self else { return }
//                    wSelf.hud.stopAnimating()
//
//                    switch apiResult {
//                    case .failed(error: let err):
//                        wSelf.showAPIErrorResponsePopUp(from: err, cancelTitle: LM.dls.g_cancel)
//                    case .success(let result):
//                        wSelf.handleCreateIdentityResult(result)
//                    }
//                },
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
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOn"), for: .normal)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOff"), for: .selected)
        pwdVisibleBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 44, height: 44))
        pwdVisibleBtn.isSelected = true
        
        confirmTextField.rightView = pwdVisibleBtn
        confirmTextField.rightViewMode = .always
        confirmTextField.isSecureTextEntry = true
        
        pwdTextField.isSecureTextEntry = true
        
        nameTextField.delegate = self
        pwdTextField.delegate = self
        confirmTextField.delegate = self
        pwdHintTextField.delegate = self
    }
    
    private func bindUI() {
        pwdVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pwdVisibleBtn.isSelected = !self.pwdVisibleBtn.isSelected
            self.confirmTextField.isSecureTextEntry = self.pwdVisibleBtn.isSelected
        })
        .disposed(by: bag)
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
        let vc = BackupWalletNoteViewController.instance(source: idenitySource)
        navigationController?.pushViewController(vc)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = nil
        titleLabel.text = dls.createID_title
        createBtn.setTitleForAllStates(dls.createID_btn_create)
        nameTextField.set(placeholder: dls.createID_placeholder_name)
        pwdTextField.set(placeholder: dls.createID_placeholder_password)
        confirmTextField.set(placeholder: dls.createID_placeholder_confirmPassword)
        pwdHintTextField.set(placeholder: dls.createID_placeholder_passwordNote)
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bar_tint)
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: theme.palette.nav_item_1,
            image: #imageLiteral(resourceName: "arrowNavBlack")
        )
        
        titleLabel.set(
            textColor: theme.palette.label_main_1,
            font: UIFont.owMedium(size: 18)
        )
        
        for field in fields {
            field.sepline.backgroundColor = theme.palette.sepline
            field.textColor = theme.palette.input_text
            field.placeHolderColor = theme.palette.input_placeholder
        }
        
        createBtn.set(
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
        createBtn.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        createBtn.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
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
        case .emptyIdentityName:
            nameTextField.becomeFirstResponder()
        case .emptyPwdHint:
            pwdHintTextField.becomeFirstResponder()
        case .emptyConfirmPwd:
            confirmTextField.becomeFirstResponder()
            
        case .valid: break
        }
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
