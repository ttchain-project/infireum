//
//  ReceiptRequestViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/28.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

final class ReceiptRequestViewController: KLModuleViewController, KLVMVC {
    
    var viewModel: ReceiptRequestViewModel!
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
       
        viewModel = ViewModel.init(input: ViewModel.Input.init(amtStrInout: self.receiptAmounTextField.rx.text, coinSelectedInOut: self.coinNameTextField.rx.text), output: ())
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        self.bindUI()
    }
    
    typealias Constructor = Void
    
    var bag: DisposeBag = DisposeBag.init()
    typealias ViewModel = ReceiptRequestViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var coinTitleLabel: UILabel!
    @IBOutlet weak var coinNameTextField: UITextField! {
        didSet {
            let rightImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
            rightImage.image = #imageLiteral(resourceName: "btn_next.png")
            self.coinNameTextField.rightView = rightImage
            self.coinNameTextField.rightViewMode = .always
        }
    }
    @IBOutlet weak var receiptAmountLabel: UILabel!
    @IBOutlet weak var receiptAmounTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var coinAddressTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var coinAddressTextfield: UITextField! {
        didSet {
            coinAddressTextfield.isEnabled = false
            let rightImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
            rightImage.image = #imageLiteral(resourceName: "btn_next.png")
            self.coinAddressTextfield.rightView = rightImage
            self.coinAddressTextfield.rightViewMode = .always
        }
    }
    private let coinPickerView: UIPickerView = UIPickerView.init()
    
    private var coinSelected: PublishRelay<(String,String,String)> = PublishRelay.init()
    
    var onSelectingCoin: Observable <(String,String,String)> {
        return coinSelected.asObservable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func renderTheme(_ theme: Theme) {
        
        changeBackBarButton(toColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"))

        receiptAmounTextField.textColor = theme.palette.input_text
        receiptAmounTextField.placeHolderColor = theme.palette.input_placeholder

        coinNameTextField.textColor = theme.palette.input_text
        coinNameTextField.placeHolderColor = theme.palette.input_placeholder
     
        coinAddressTextfield.textColor = theme.palette.input_text
        coinAddressTextfield.placeHolderColor = theme.palette.input_placeholder
        
        confirmButton.set(textColor: theme.palette.btn_bgFill_enable_text,
                          backgroundColor: theme.palette.btn_bgFill_enable_bg )
        
        self.view.backgroundColor = theme.palette.bgView_main
        coinTitleLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        receiptAmountLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        coinAddressTitleLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        infoLabel.set(textColor: theme.palette.application_main, font: .owRegular(size:14))
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.title = lang.dls.chat_room_receipt
        confirmButton.setTitle(lang.dls.g_confirm, for: .normal)
        coinTitleLabel.text = lang.dls.receipt_receiving_currency
        receiptAmountLabel.text = lang.dls.receiving_amount
        coinNameTextField.placeholder = lang.dls.red_env_send_please_select
        receiptAmounTextField.placeholder = lang.dls.withdrawal_placeholder_withdrawalAmt
        coinAddressTitleLabel.text = lang.dls.withdrawal_label_toAddr
        coinAddressTextfield.placeholder = lang.dls.receipt_request_coin_address_placeholder
        backButton.setTitleForAllStates(lang.dls.g_cancel)
        let text = lang.dls.receipt_request_warning_label
        infoLabel.text = "* " + text

    }
    
    @objc func doneButtonClicked() {
        let index = self.coinPickerView.selectedRow(inComponent: 1)
        guard let coins = self.viewModel.coins.value else {
            return
        }
        guard let selectedCoin = coins.count > index ? coins[index] : nil else {
            return
        }
        self.viewModel.selectedCoin.accept(selectedCoin)
        self.view.endEditing(true)
    }
    
    func bindUI() {
        self.coinNameTextField.inputView = self.coinPickerView
        
        self.coinPickerView.delegate = self
        self.coinPickerView.dataSource = self
        
        self.confirmButton.rx.klrx_tap.asDriver().drive(onNext: { [unowned self] () in
            if self.viewModel.checkValidity() {
                self.coinSelected.accept((self.viewModel.selectedWallet.value!.address!, self.viewModel.selectedCoin.value!.identifier!, self.viewModel.getAmt()))
                self.navigationController?.popViewController(animated: true)
            }else {
                self.showAlert(title: "", message: LM.dls.receipt_request_error_string)
            }
        }).disposed(by: bag)
        
        self.backButton.rx.klrx_tap.drive(onNext:{ _ in
            if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
        
        self.receiptAmounTextField.delegate = self
        self.coinNameTextField.addDoneOnKeyboardWithTarget(self, action: #selector(doneButtonClicked),titleText:LM.dls.g_confirm)
        
        self.viewModel.selectedCoin.filterNil().subscribe(onNext: { (_) in
            self.coinAddressTextfield.text = self.viewModel.selectedWallet.value?.address
        }).disposed(by: bag)
        
        
    }
}

extension ReceiptRequestViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.viewModel.wallet.count
        case 1:
            return self.viewModel.coins.value!.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return self.viewModel.wallet[row].name ?? ""
        case 1:
            guard let coins = self.viewModel.coins.value else {
                return ""
            }
            return coins[row].inAppName
            
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            self.viewModel.selectedWallet.accept(self.viewModel.wallet[row])
            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.reloadAllComponents()
        default:
            return
        }
    }
    
    func reloadComponents() {
       
    }
}


extension ReceiptRequestViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Always enable delete
        if textField != self.receiptAmounTextField {
            return true
        }
        
        if string == "" { return true }
        let newCharacters = CharacterSet.init(charactersIn: string)
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: newCharacters)
        let isDot = (string == ".")
        let isDotAllowed = isTextFieldAllowDot(textField)
        
        guard (isDot && isDotAllowed) || isNumber else { return false }
        let str = textField.text! as NSString
        let finalStr = str.replacingCharacters(in: range, with: string)
        
        let isRegexCheckPassed: Bool
        let sepParts = finalStr.components(separatedBy: ".")
        
        if sepParts.count == 1 {
            //Means the final str doesn't contain dot
            isRegexCheckPassed = !isDot
        }
        else {
            //The final str has dot
            //if finalStr is pure "." return false
            if finalStr == "."  { isRegexCheckPassed = false }
                //sepParts should only has 2 elements.
            else if sepParts.count != 2  { isRegexCheckPassed = false }
                //sepParts has no values
            else if sepParts.last == nil { isRegexCheckPassed = false }
            else {
                //This will pass.
                let digitPart = sepParts.last!
                if let selectedCoin = viewModel.selectedCoin.value {
                    let maxDigit: Int = Int(selectedCoin.digit)
                    isRegexCheckPassed = (digitPart.count) <= maxDigit
                } else {
                    isRegexCheckPassed = false
                }
            }
        }
        
        guard isRegexCheckPassed else { return false }
        //Now we check the string is valid, try to truncated undesired string if exists.
        let zeroPrefixTruncedStr = truncatedUndesiredZeroPrefixNumericString(from: finalStr)
        if zeroPrefixTruncedStr == finalStr {
            return true
        }else {
            //Here we know the string has to truncated some undesired 0 prefix, so change the text programmatically and return false
            
            //Here we try to call update func in view model to make sure the observ send the event. (should not directly update textFied.text as it will not trigger controlProperty to send event.
            if let finalValue = Decimal.init(string: zeroPrefixTruncedStr) {
                viewModel.updateAmt(finalValue)
            }else {
                //This should not happene, just for safety.
                textField.text = zeroPrefixTruncedStr
            }
            
            return false
        }
    }
    
    
    private func isTextFieldAllowDot(_ textField: UITextField) -> Bool {
        return true
    }
    
    private func truncatedUndesiredZeroPrefixNumericString(from str: String) -> String {
        guard str.count > 1 else {
            //Avoid trunc "0"
            return str
        }
        
        if str.hasPrefix("0") && !str.hasPrefix("0.") {
            //this mean the numric string is sth like "01", "01.22"
            var truncatedStr = str
            while truncatedStr.hasPrefix("0") && !truncatedStr.hasPrefix("0.") && truncatedStr.count > 1 {
                truncatedStr.removeFirst()
            }
            
            return truncatedStr
        }else {
            return str
        }
    }
}
