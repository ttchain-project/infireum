//
//  LightWithdrawalAssetViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LightWithdrawalAssetViewController: KLModuleViewController,KLVMVC {
    var viewModel: WithdrawalAssetViewModel!
    
    @IBOutlet weak var transferAmountLabel: UILabel!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var transferAmtTextField: UITextField!
    @IBOutlet weak var transferAllButton: UIButton!
    
    typealias ViewModel = WithdrawalAssetViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let asset: Asset
        let fiat: Fiat
    }

    func config(constructor: LightWithdrawalAssetViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalAssetViewModel.InputSource(asset: constructor.asset, fiat: constructor.fiat, amtStrInout: transferAmtTextField.rx.text),
            output: ()
        )
        transferAmtTextField.keyboardType = .decimalPad
         bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    private func bindViewModel() {
        
        transferAmtTextField.delegate = self
        
        let coin = viewModel.input.asset.coin!
        let coinName = coin.inAppName!
        viewModel.assetAvailableAmt.map {
            amt -> String? in
            let _amtString = amt.asString(
                digits: C.Coin.min_digit,
                force: true,
                maxDigits: Int(coin.digit),
                digitMoveCondition: { Decimal.init(string: $0) ?? 0 != amt }
            )
            
            let dls = LM.dls
            return dls.withdrawal_label_assetAmt(_amtString, coinName)
            }
            .bind(to: balanceAmountLabel.rx.text)
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        transferAmtTextField.set(placeholder: dls.withdrawal_placeholder_withdrawalAmt)
        transferAmountLabel.text = dls.transfer_amount_title
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        transferAmtTextField.set(textColor: palette.label_main_1, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
        transferAllButton.set(textColor: palette.label_main_2, font: .owMedium(size: 17), text: LM.dls.transfer_all_amount, backgroundColor: UIColor.init(hexString: "18ADD4"))
        transferAmountLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 17))
        balanceAmountLabel.set(textColor: UIColor.init(white: 0, alpha: 0.4), font: .owMedium(size: 17))
        
    }
}


extension LightWithdrawalAssetViewController: UITextFieldDelegate {
    
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
