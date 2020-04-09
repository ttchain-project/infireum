//
//  BackQRCodePwdEntryViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/8/21.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class BackQRCodePwdEntryViewController: UIViewController {

    var bag = DisposeBag()
    
    var finalResult = PublishSubject<IdentityQRCodeEncryptionFlow.PwdAndHintInputResult>.init()
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.set(textColor: .cloudBurst, font: .owMedium(size:24), text: LM.dls.withdrawalConfirm_pwdVerify_placeholder_wallet_pwd)
        }
    }
    @IBOutlet weak var pwdTitleLabel: UILabel! {
        didSet {
            pwdTitleLabel.set(textColor: TM.palette.label_main_1, font: .owRegular(size: 14),text:LM.dls.createID_placeholder_password)
        }
    }
    @IBOutlet weak var pwdTextField: OWInputTextField! {
        didSet {
            pwdTextField.sepline.backgroundColor = TM.palette.sepline
            pwdTextField.textColor = TM.palette.bg_fill_new
            pwdTextField.placeHolderColor = TM.palette.input_placeholder
            pwdTextField.delegate = self
            pwdTextField.set(placeholder: LM.dls.qrCodeExport_alert_placeholder_pwd)

        }
    }
    @IBOutlet weak var reminderMsgLabel: UILabel!{
        didSet {
            reminderMsgLabel.set(textColor: TM.palette.label_main_1, font: .owRegular(size: 14),text:LM.dls.createID_placeholder_passwordNote)
        }
    }
    @IBOutlet weak var reminderMsgTextField: OWInputTextField!{
        didSet {
            reminderMsgTextField.sepline.backgroundColor = TM.palette.sepline
            reminderMsgTextField.textColor = TM.palette.bg_fill_new
            reminderMsgTextField.placeHolderColor = TM.palette.input_placeholder
            reminderMsgTextField.set(placeholder: LM.dls.qrCodeExport_alert_placeholder_hint)

        }
    }
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitleForAllStates(LM.dls.g_cancel)
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.isEnabled = false
            doneButton.setTitleForAllStates(LM.dls.g_confirm)
            doneButton.set(
                font: UIFont.owRegular(size: 14)
            )
            doneButton.backgroundColor = TM.palette.btn_bgFill_enable_bg
            doneButton.setTitleColor(TM.palette.btn_bgFill_enable_text, for: .normal)
            doneButton.setTitleColor(TM.palette.btn_bgFill_disable_text, for: .disabled)
        }
    }
    fileprivate var pwdVisibleBtn: UIButton!
    fileprivate var hintVisibleBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        bindUI()
    }
    func setupUI() {
        pwdVisibleBtn = UIButton.init(type: .custom)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_show"), for: .normal)
        pwdVisibleBtn.setImage(#imageLiteral(resourceName: "btn_hide"), for: .selected)
        pwdVisibleBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 44, height: 44))
        pwdVisibleBtn.isSelected = true
        
        hintVisibleBtn = UIButton.init(type: .custom)
        hintVisibleBtn.setImage(#imageLiteral(resourceName: "btn_show"), for: .normal)
        hintVisibleBtn.setImage(#imageLiteral(resourceName: "btn_hide"), for: .selected)
        hintVisibleBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 44, height: 44))
        hintVisibleBtn.isSelected = true

        pwdTextField.rightView = pwdVisibleBtn
        pwdTextField.rightViewMode = .always
        pwdTextField.isSecureTextEntry = true

        reminderMsgTextField.rightView = hintVisibleBtn
        reminderMsgTextField.rightViewMode = .always
        reminderMsgTextField.isSecureTextEntry = true

    }
    
    func bindUI()  {
        Observable.combineLatest(
            pwdTextField.rx.text
                .replaceNilWith("")
                .map { $0.count > 0 },
            reminderMsgTextField.rx.text
                .replaceNilWith("")
                .map { $0.count > 0 }
            )
            .map { $0 && $1 }
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: bag)
        
        pwdVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pwdVisibleBtn.isSelected = !self.pwdVisibleBtn.isSelected
            self.pwdTextField.isSecureTextEntry = self.pwdVisibleBtn.isSelected
        })
            .disposed(by: bag)

        hintVisibleBtn.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.hintVisibleBtn.isSelected = !self.hintVisibleBtn.isSelected
            self.reminderMsgTextField.isSecureTextEntry = self.hintVisibleBtn.isSelected
        })
            .disposed(by: bag)

        doneButton.rx.klrx_tap.drive(onNext: { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let identity = Identity.singleton ,let wallets = identity.wallets?.array as? [Wallet] else {
                         return
                     }
                     
                     let systemWallets = wallets.filter { $0.isFromSystem }
                     let pwdSet = Set.init(systemWallets.map { $0.ePwd! })
                     guard pwdSet.count == 1 else { return }
                     let sampleWallet = systemWallets[0]
            
            guard let pwd = self.pwdTextField.text, let hint = self.reminderMsgTextField.text else {
                return
            }
            if case .incorrectFormat(let desc) = pwd.ow_isValidWalletPwd {
                self.finalResult.onNext(.invalidPwdFormat(desc: desc))
            }else if case .incorrectFormat(let desc) = hint.ow_isValidPwdHint {
                self.finalResult.onNext(.invalidPwdHintFormat(desc: desc))
            }else if pwd == hint  {
                self.finalResult.onNext(.samePasswordAndHint(desc: LM.dls.strValidate_field_pwdHintSame))
            } else if !sampleWallet.isWalletPwd(rawPwd: pwd) {
                self.finalResult.onNext(.invalidPwdFormat(desc: LM.dls.myIdentity_error_pwd_is_wrong))
            } else if let pwdhint = sampleWallet.pwdHint, pwdhint != hint {
                self.finalResult.onNext(.invalidPwdHintFormat(desc: LM.dls.qrCodeImport_info_g_alert_error_field_hint))
            } else {
                self.finalResult.onNext(IdentityQRCodeEncryptionFlow.PwdAndHintInputResult.success(pwd: pwd, pwdHint: hint))
            }
            self.dismiss(animated: false, completion: nil)

        }).disposed(by: bag)
        
        backButton.rx.klrx_tap.drive(onNext: {
            self.finalResult.onNext(IdentityQRCodeEncryptionFlow.PwdAndHintInputResult.skipped)
            self.dismiss(animated: false, completion: nil)

        }).disposed(by: bag)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension BackQRCodePwdEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pwdTextField  {
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
