//
//  WithdrawalBTCFeeInfoViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalBTCFeeInfoViewController: KLModuleViewController, WithdrawalChildVC, KLVMVC {
    
    @IBOutlet weak var regularBase: UIView!
    @IBOutlet weak var regularLabel: UILabel!
    @IBOutlet weak var regularCheck: UIImageView!
    @IBOutlet weak var regularSepline: UIView!
    
    @IBOutlet weak var priorityBase: UIView!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var priorityCheck: UIImageView!
    @IBOutlet weak var prioritySepline: UIView!
    
    @IBOutlet weak var manualBase: UIView!
    @IBOutlet weak var manualTextField: UITextField!
    @IBOutlet weak var manualCheck: UIImageView!
    @IBOutlet weak var manualSepline: UIView!

    struct Config {
        let defaultFeeOption: FeeManager.Option?
        let defaultFeeRate: Decimal?
    }
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalBTCFeeInfoViewModel
    var viewModel: WithdrawalBTCFeeInfoViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalBTCFeeInfoViewModel.InputSource(
                feeDefault: WithdrawalBTCFeeInfoViewModel.FeeDefaultInput(
                    defaultFeeManagerOption: constructor.defaultFeeOption,
                    defaultFeeRate: constructor.defaultFeeRate
                ),
                typeSelectInput: Driver.merge(
                    regularBase.rx.klrx_tap.map { .regular },
                    priorityBase.rx.klrx_tap.map { .priority },
                    manualTextField.rx.controlEvent(UIControlEvents.editingDidBegin).asDriver().map { .manual }
                ),
                manualRateStrInout: manualTextField.rx.text
            ),
            output: ()
        )
        
        manualTextField.keyboardType = .decimalPad
        manualTextField.delegate = self
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return viewModel.satPerByte.map { $0 != nil }
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        manualTextField.set(placeholder: dls.withdrawal_placeholder_custom_btc_feeRate)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        regularLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
        priorityLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
        manualTextField.set(textColor: palette.input_text, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
        
        regularSepline.backgroundColor = palette.sepline
        prioritySepline.backgroundColor = palette.sepline
        manualSepline.backgroundColor = palette.sepline
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        viewModel.selectedOption.subscribe(onNext: {
            [unowned self] in self.updateOptionSelectedLayout(option: $0)
        })
        .disposed(by: bag)
        
        let dls = LM.dls
        viewModel.regularSatPerByte.map {
            rate -> String in
            return dls.withdrawal_placeholder_btc_feeRate_normal
                + " "
                + rate.asString(digits: 8)
                + " "
                + "btc" //dls.fee_sat_per_byte
            }
            .bind(to: regularLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.prioritySatPerByte.map {
            rate -> String in
            
            return dls.withdrawal_placeholder_btc_feeRate_priority
                + " "
                + rate.asString(digits: 8)
                + " "
                + "btc" //dls.fee_sat_per_byte
            }
            .bind(to: priorityLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func updateOptionSelectedLayout(option: ViewModel.InputOption) {
        switch option {
        case .manual:
            manualCheck.isHidden = false
            regularCheck.isHidden = true
            priorityCheck.isHidden = true
        case .priority:
            manualCheck.isHidden = true
            regularCheck.isHidden = true
            priorityCheck.isHidden = false
            self.view.endEditing(true)
        case .regular:
            manualCheck.isHidden = true
            regularCheck.isHidden = false
            priorityCheck.isHidden = true
            self.view.endEditing(true)
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

extension WithdrawalBTCFeeInfoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Always enable delete
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
                let maxDigit: Int = 8
                isRegexCheckPassed = (digitPart.count) <= maxDigit
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
                viewModel.updateManualFee(fee: finalValue)
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
