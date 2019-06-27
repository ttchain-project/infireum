//
//  IdentityQRCodeImportInfoFillUpViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

final class IdentityQRCodeImportInfoFillUpViewController: KLModuleViewController, KLVMVC {
    struct Config {
        let purpose: IdentityQRCodeDecryptionFlow.Purpose
        let infoContent: IdentityQRCodeContent
        let resultCallback: (IdentityQRCodeDecryptionFlow.Result) -> Void
    }
    
    @IBOutlet weak var idStackView: UIStackView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var idNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    
    @IBOutlet weak var importBtn: UIButton!
    
    @IBOutlet var seplines: [UIView]!
    
    typealias Constructor = Config
    typealias ViewModel = IdentityQRCodeImportInfoFillUpViewModel
    var viewModel: IdentityQRCodeImportInfoFillUpViewModel!
    
    private var resultCallBack: ((IdentityQRCodeDecryptionFlow.Result) -> Void)?
    
    func config(constructor: Config) {
        resultCallBack = constructor.resultCallback
        view.layoutIfNeeded()
        
        viewModel = ViewModel.init(
            input: IdentityQRCodeImportInfoFillUpViewModel.InputSource(
                purpose: constructor.purpose,
                infoContnet: constructor.infoContent,
                identityNameInput: idNameTextField.rx.text,
                pwdInput: pwdTextField.rx.text,
                pwdHintInput: hintTextField.rx.text
            ),
            output: ()
        )
        
        bindImportAction()
        bindViewModel()
        hiddenIDNameTextFieldIfNeeded(forPurpose: constructor.purpose)
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    var bag: DisposeBag = DisposeBag.init()
    
    private func hiddenIDNameTextFieldIfNeeded(forPurpose purpose: IdentityQRCodeDecryptionFlow.Purpose) {
        switch purpose {
        case .importWallet:
            idStackView.isHidden = true
        case .restoreIdentity:
            break
        }
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        
        title = dls.qrCodeImport_info_title
        introLabel.text = dls.qrCodeImport_info_label_intro
        idNameTextField.set(placeholder: dls.qrCodeImport_info_placeholder_idName)
        pwdTextField.set(placeholder: dls.qrCodeImport_info_placeholder_pwd)
        hintTextField.set(placeholder: dls.qrCodeImport_info_placeholder_hint)
        importBtn
            .setTitleForAllStates(dls.qrCodeImport_info_btn_startImport)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        changeBackBarButton(toColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"))
        
        introLabel.set(textColor: palette.label_asAppMain, font: .owRegular(size: 12))
        
        for sep in seplines {
            sep.backgroundColor = palette.sepline
        }
        
        idNameTextField.set(
            textColor: palette.input_text,
            font: .owRegular(size: 14),
            placeHolderColor: palette.input_placeholder
        )
        
        pwdTextField.set(
            textColor: palette.input_text,
            font: .owRegular(size: 14),
            placeHolderColor: palette.input_placeholder
        )
        
        hintTextField.set(
            textColor: palette.input_text,
            font: .owRegular(size: 14),
            placeHolderColor: palette.input_placeholder
        )
        
        importBtn.set(
            color: palette.btn_bgFill_enable_text,
            font: .owRegular(size: 14),
            backgroundColor: palette.btn_bgFill_enable_bg
        )
    }
    
    private func bindImportAction() {
        importBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                [weak self]
                _ in
                guard let wSelf = self else { return }
                if wSelf.viewModel.attemptImport() {
                    wSelf.resultCallBack?(.importSucceed)
                }
            })
            .disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.onFindingInvalidFieldCheckResult
            .subscribe(onNext: {
                [weak self]
                invalidResult in
                let dls = LM.dls
                switch invalidResult {
                case .emptyIdName:
                    self?.idNameTextField.becomeFirstResponder()
                case .emptyPwd:
                    self?.pwdTextField.becomeFirstResponder()
                case .emptyPwdHint:
                    self?.hintTextField.becomeFirstResponder()
                case .invalidFormat_pwd(desc: let desc):
                    self?.presentInvalidFormatAlert(
                        fieldName: dls.qrCodeImport_info_g_alert_error_field_pwd,
                        desc: desc
                    )
                case .invalidFormat_idName(desc: let desc):
                    self?.presentInvalidFormatAlert(fieldName: dls.qrCodeImport_info_g_alert_error_field_idName, desc: desc)
                case .invalidFormat_hint(desc: let desc):
                    self?.presentInvalidFormatAlert(fieldName: dls.qrCodeImport_info_g_alert_error_field_hint, desc: desc)
                    
                }
            })
            .disposed(by: bag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func presentInvalidFormatAlert(fieldName: String, desc: String) {
        let dls = LM.dls
        showSimplePopUp(with: dls.qrCodeImport_info_g_alert_error_title_error_field(fieldName), contents: desc, cancelTitle: dls.g_cancel, cancelHandler: nil)
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
