//
//  WithdrawalAssetViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalAssetViewController: KLModuleViewController, KLVMVC {
    
    //MARK: - KLVMVC
    typealias ViewModel = WithdrawalAssetViewModel
    var viewModel: WithdrawalAssetViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let asset: Asset
        let fiat: Fiat
    }
    
    typealias Constructor = Config
    func config(constructor: WithdrawalAssetViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalAssetViewModel.InputSource(asset: constructor.asset, fiat: constructor.fiat, amtStrInout: transferAmtTextField.rx.text),
            output: ()
        )
        
        self.transferAllButton.isHidden = constructor.asset.wallet?.owChainType != ChainType.btc
        transferAmtTextField.keyboardType = UIKeyboardType.decimalPad
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func bindViewModel() {
        
        transferAmtTextField.delegate = self
        
        let coin = viewModel.input.asset.coin!
        let coinName = coin.inAppName!
        coinNameLabel.text = coinName
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
        .bind(to: availableAmtLabel.rx.text)
        .disposed(by: bag)
        
        let fiatValueString = viewModel.transferAmtFiatValue.map {
            value -> String in
            let _valueString = value?.asString(
                digits: 4,
                force: true,
                maxDigits: 8,
                digitMoveCondition: { Decimal.init(string: $0) ?? 0 != value }
                )
                ?? "--"
            return _valueString
        }
        
        let fiatSymbol = viewModel.fiat.map { $0.fullSymbol }
        Observable.combineLatest(fiatSymbol, fiatValueString).map { "≈ \($0) \($1)" }.bind(to: transferAmtFiatValueLabel.rx.text).disposed(by: bag)
    }
    
    //MARK: - WithdrawalAssetInfoProvider
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }

    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var availableAmtLabel: UILabel!
    
    @IBOutlet weak var transferAmtTextField: UITextField!
    @IBOutlet weak var transferAmtFiatValueLabel: UILabel!
    
    @IBOutlet weak var transferAllButton: UIButton!
    @IBOutlet weak var sepline: UIView!
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        transferAmtTextField.set(placeholder: dls.withdrawal_placeholder_withdrawalAmt)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        coinNameLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 17))
        transferAmtTextField.set(textColor: palette.label_main_1, font: .owRegular(size: 20), placeHolderColor: palette.input_placeholder)
        availableAmtLabel.set(textColor: palette.input_text, font: .owRegular(size: 14))
        transferAmtFiatValueLabel.set(textColor: palette.specific(color: .owSilver), font: .owRegular(size: 20))
        sepline.backgroundColor = palette.sepline
        transferAllButton.set(textColor: palette.label_main_1, font: .owMedium(size: 17), text: LM.dls.transfer_all_amount, backgroundColor: .clear)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func transferAllAmout(amount:Decimal?) {
    }
}

extension WithdrawalAssetViewController: UITextFieldDelegate {
    
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
