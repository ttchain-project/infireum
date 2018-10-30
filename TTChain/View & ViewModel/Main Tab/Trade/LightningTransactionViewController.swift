//
//  LightningTransactionViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightningTransactionViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    typealias ViewModel = LightningTransactionViewModel
    var viewModel: LightningTransactionViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var tradePanelBase: UIView!
    @IBOutlet weak var rateTitleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var fromCoinBase: UIView!
    @IBOutlet weak var fromCoinIcon: UIImageView!
    @IBOutlet weak var fromCoinNameLabel: UILabel!
    @IBOutlet weak var fromWalletLabel: UILabel!
    @IBOutlet weak var fromAssetAmtLabel: UILabel!
    
    private let fromSourcePicker: UIPickerView = UIPickerView.init()
    private let fromPickerResponder: UITextField = UITextField.init()
    
    @IBOutlet weak var fromCoinAmtBase: UIView!
    @IBOutlet weak var fromCoinAmtTextField: UITextField!
    @IBOutlet weak var fromCoinAmtSepline: UIView!
    private let toPickerResponder: UITextField = UITextField.init()
    
    @IBOutlet weak var toCoinBase: UIView!
    @IBOutlet weak var toCoinIcon: UIImageView!
    @IBOutlet weak var toCoinNameLabel: UILabel!
    @IBOutlet weak var toWalletLabel: UILabel!
    @IBOutlet weak var toAssetAmtLabel: UILabel!
    
    private let toSourcePicker: UIPickerView = UIPickerView.init()
    
    @IBOutlet weak var toCoinAmtBase: UIView!
    @IBOutlet weak var toCoinAmtTextField: UITextField!
    @IBOutlet weak var toCoinAmtSepline: UIView!
    
    @IBOutlet weak var exchangeBase: UIView!
    @IBOutlet weak var exchangeBtn: UIButton!
    
    @IBOutlet weak var recordHeaderBase: UIView!
    @IBOutlet weak var recordHeaderTitleLabel: UILabel!
    @IBOutlet weak var recordSepline: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noRecordLabel: UILabel!
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        setupTableView()
        setupMatchSelectPanel()
        
        let fCoins = Coin.lightningTransactionFromCoins
        let fCoin = fCoins[0]
        let tCoins = Coin.lightningTransactionToCoins(withFromCoin: fCoin)
        let tCoin = tCoins[0]
        
        viewModel = ViewModel.init(
            input: LightningTransactionViewModel.InputSource(
                fromAmtStrInout: fromCoinAmtTextField.rx.text,
                transferInput: exchangeBtn.rx.tap.asDriver(),
                defaultFromCoins: fCoins,
                defaultFromCoin: fCoin,
                defaultToCoins: tCoins,
                defaultToCoin: tCoin
            ),
            output: ()
        )
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
        assignPickerSource()
        enablePickerViewInputAutoSelection()
        bindViewModel()
    }
    
    private func setupMatchSelectPanel() {
        fromPickerResponder.inputView = fromSourcePicker
        fromCoinBase.addSubview(fromPickerResponder)
        fromCoinBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.fromPickerResponder.becomeFirstResponder()
        })
        .disposed(by: bag)
        
        toPickerResponder.inputView = toSourcePicker
        toCoinBase.addSubview(toPickerResponder)
        toCoinBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.toPickerResponder.becomeFirstResponder()
        })
        .disposed(by: bag)
        
        toCoinAmtTextField.isUserInteractionEnabled = false
        fromCoinAmtTextField.keyboardType = .decimalPad
    }
    
    private func assignPickerSource() {
        fromSourcePicker.delegate = self
        fromSourcePicker.dataSource = self
        toSourcePicker.delegate = self
        toSourcePicker.dataSource = self
//        fromSourcePicker.reloadAllComponents()
//        toSourcePicker.reloadAllComponents()
    }
    
    private func setupTableView() {
        tableView.register(LightningTransRecordTableViewCell.nib, forCellReuseIdentifier: LightningTransRecordTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func enablePickerViewInputAutoSelection() {
        fromPickerResponder.rx.autoSelectFirstRowOfPickerViewIfNeeded(inBag: bag)
        toPickerResponder.rx.autoSelectFirstRowOfPickerViewIfNeeded(inBag: bag)
    }
    
    private func bindViewModel() {
        fromCoinAmtTextField.delegate = self
        
        viewModel.records.bind(to: tableView.rx.items(cellIdentifier: LightningTransRecordTableViewCell.cellIdentifier(), cellType: LightningTransRecordTableViewCell.self)) {
            [unowned self]
            row, record, cell in
            cell.config(withRecord: record, urlHandler: { [unowned self] (url) in
                self.routeToBlockExplorer(withUrl: url)
            })
        }
        .disposed(by: bag)
        
        viewModel.records.map { $0.isEmpty }.bind(to: tableView.rx.isHidden).disposed(by: bag)
        
//        viewModel.fromCoins.bind(to: fromCoinPicker.rx.itemTitles) {
//            row, coin -> String? in
//            return coin.name!
//        }
//        .disposed(by: bag)
//
//        viewModel.toCoins.bind(to: toCoinPicker.rx.itemTitles) {
//            row, coin -> String? in
//            return coin.name!
//        }
//        .disposed(by: bag)
        
        viewModel.transRate.map {
            $0?.asString(digits: 2)
        }
        .bind(to: rateLabel.rx.text)
        .disposed(by: bag)
        
        viewModel.toAmt.map {
            //18 is just a value safe enough to support all possible coins
            //as in here there's no need to waste CPU resource to get the precise digit
            $0?.asString(digits: 18)
        }
        .bind(to: toCoinAmtTextField.rx.text)
        .disposed(by: bag)
        
        let fromCoin = viewModel.selectedFromCoin
        let toCoin = viewModel.selectedToCoin
        
        fromCoin.subscribe(onNext: { [unowned self] in self.setupFromCoinView(with: $0) }).disposed(by: bag)
        toCoin.subscribe(onNext: { [unowned self] in self.setupToCoinView(with: $0) }).disposed(by: bag)
        
        viewModel.selectedFromWallet
            .map {
                $0?.name ?? LM.dls.lightningTx_label_custom
            }
            .bind(to: fromWalletLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.selectedToWallet
            .map {
                $0?.name ?? LM.dls.lightningTx_label_custom
            }
            .bind(to: toWalletLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.selectedFromAssetAmt
            .map {
                [unowned self]
                amt -> String in
                if let _amt = amt {
                    let coin = self.viewModel.getSelectedFromCoin()
                    let minDigit = C.Coin.min_digit
                    let maxDigit = Int(coin.digit)
                    let amtStr = _amt.asString(
                        digits: minDigit,
                        force: true,
                        maxDigits: maxDigit,
                        digitMoveCondition: { (str) -> Bool in
                            Decimal.init(string: str) != amt
                        })
                    
                    return LM.dls.lightningTx_label_remain_amt(amtStr)
                }else {
                    return "-"
                }
            }
            .bind(to: fromAssetAmtLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.selectedToAssetAmt
            .map {
                [unowned self]
                amt -> String in
                if let _amt = amt {
                    let coin = self.viewModel.getSelectedToCoin()
                    let minDigit = C.Coin.min_digit
                    let maxDigit = Int(coin.digit)
                    let amtStr = _amt.asString(
                        digits: minDigit,
                        force: true,
                        maxDigits: maxDigit,
                        digitMoveCondition: { (str) -> Bool in
                            Decimal.init(string: str) != amt
                    })
                    
                    return LM.dls.lightningTx_label_remain_amt(amtStr)
                }else {
                    return "-"
                }
            }
            .bind(to: toAssetAmtLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.onFindOutInvalidInfoWhilePackageTransferInfo.subscribe(onNext: {
            [unowned self]
            invalidInfo in
            switch invalidInfo {
            case .valid: break
            case .emptyFromAmt:
                self.fromCoinAmtTextField.becomeFirstResponder()
            case .insuffientFromAmt:
                let fromCoin = self.viewModel.getSelectedFromCoin()
                self.showSimplePopUp(
                    with: LM.dls
                        .lightningTx_error_insufficient_asset_amt(fromCoin.inAppName!),
                    contents: "",
                    cancelTitle: LM.dls.g_confirm,
                    cancelHandler: nil
                )
            case .unableToCalculateToAmt:
                let dls = LM.dls
                self.showSimplePopUp(
                    with: dls.lightningTx_error_empty_transRate_title,
                    contents: dls.lightningTx_error_empty_transRate_content,
                    cancelTitle: dls.g_confirm,
                    cancelHandler: { _ in
                        self.viewModel.refreshTransRate()
                    }
                )
            case .noFromAsset:
                let fromCoin = self.viewModel.getSelectedFromCoin()
                self.showSimplePopUp(
                    with: LM.dls
                        .lightningTx_error_no_asset_title(fromCoin.inAppName!),
                    contents: LM.dls
                        .lightningTx_error_no_asset_content(fromCoin.inAppName!),
                    cancelTitle: LM.dls.g_confirm,
                    cancelHandler: nil
                )
            }
        })
            .disposed(by: bag)
        
        viewModel.onStartTransferWithCreateSource
            .subscribe(onNext: {
                [unowned self] source in
                self.toConfirmVC(with: source)
            })
            .disposed(by: bag)
        
        
    }
    
    private func setupFromCoinView(with coin: Coin) {
        fromCoinIcon.image = coin.iconImg
        fromCoinNameLabel.text = coin.inAppName
    }
    
    private func setupToCoinView(with coin: Coin) {
        toCoinIcon.image = coin.iconImg
        toCoinNameLabel.text = coin.inAppName
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.lightningTx_title
        rateTitleLabel.text = dls.lightningTx_label_rate
        exchangeBtn.setTitleForAllStates(dls.lightningTx_btn_exchange)
        fromCoinAmtTextField.set(placeholder: dls.lightningTx_placeholder_out_amt)
        toCoinAmtTextField.set(placeholder: dls.lightningTx_placeholder_in_amt)
        recordHeaderTitleLabel.text = dls.lightningTx_label_txRecord
        noRecordLabel.text = dls.lightningTx_label_empty_tx
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bg_clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 18))
        
        tradePanelBase.backgroundColor = palette.specific(color: .clear)
        rateTitleLabel.set(
            textColor: palette.specific(color: .owCoolGreen),
            font: .owRegular(size: 13)
        )
        
        rateLabel.set(
            textColor: palette.specific(color: .owCoolGreen),
            font: .owRegular(size: 13)
        )
        
        fromCoinNameLabel.set(
            textColor: palette.specific(color: .owMarineBlue),
            font: .owRegular(size: 12.7)
        )
        
        fromWalletLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 9)
        )
        
        fromAssetAmtLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 9)
        )
        
        toCoinNameLabel.set(
            textColor: palette.specific(color: .owMarineBlue),
            font: .owRegular(size: 12.7)
        )
        
        toWalletLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 9)
        )
        
        toAssetAmtLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 9)
        )
        
        fromCoinBase.set(
            backgroundColor: palette.bgView_main,
            borderInfo: (color: palette.bgView_border, width: 1)
        )
        
//        fromCoinBase.addShadow(
//            ofColor: .init(white: 203.0/256.0, alpha: 0.5),
//            radius: 1,
//            offset: CGSize.init(width: 0, height: 2),
//            opacity: 1
//        )
        
        toCoinBase.set(
            backgroundColor: palette.bgView_main,
            borderInfo: (color: palette.bgView_border, width: 1)
        )
        
//        toCoinBase.addShadow(
//            ofColor: .init(white: 203.0/256.0, alpha: 0.5),
//            radius: 1,
//            offset: CGSize.init(width: 0, height: 2),
//            opacity: 1
//        )
        
        fromCoinAmtBase.set(
            backgroundColor: palette.specific(color: .clear)
        )
        
        fromCoinAmtTextField.set(
            textColor: palette.label_main_2,
            font: .owRegular(size: 12.7),
            placeHolderColor: palette.input_placeholder
        )
        
        fromCoinAmtSepline.set(
            backgroundColor: palette.bgView_main
        )
        
        toCoinAmtBase.set(
            backgroundColor: palette.specific(color: .clear)
        )
        
        toCoinAmtTextField.set(
            textColor: palette.label_main_2,
            font: .owRegular(size: 12.7),
            placeHolderColor: palette.input_placeholder
        )
        
        toCoinAmtSepline.set(
            backgroundColor: palette.bgView_main
        )
        
        exchangeBase.backgroundColor = palette.specific(color: .clear)
        
        exchangeBtn.set(
            color: palette.label_main_2,
            font: .owRegular(size: 12.7),
            backgroundColor: palette.specific(color: .owWaterBlue)
        )
        
        recordHeaderTitleLabel.set(
            textColor: palette.label_main_1,
            font: .owRegular(size: 14)
        )
        
        recordHeaderBase.backgroundColor = palette.bgView_main
        recordSepline.backgroundColor = palette.sepline
        
        noRecordLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 11)
        )
        
        view.backgroundColor = palette.bgView_sub
    }
    
    private func routeToBlockExplorer(withUrl url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func changeFromCoin(_ fCoin: Coin) {
        viewModel.selectFromCoin(fCoin, wallet: nil)
        reloadPickerSourceAndSelection()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Route
    private let confirmAnimator: KLTransferConfirmAnimator = KLTransferConfirmAnimator.init(topRevealPercentage: 0.3)
    private func toConfirmVC(with source: LightningTransRecordCreateSource) {
        let nav = LightningTradeConfirmViewController.navInstance(from: LightningTradeConfirmViewController.Config(source: source))
        nav.transitioningDelegate = confirmAnimator
        
        present(nav, animated: true, completion: nil)
    }
}

extension LightningTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private var coinComponent: Int {
        return 0
    }
    
    private var walletComponent: Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case fromSourcePicker:
            return 2
        case toSourcePicker:
            return 2
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case fromSourcePicker:
            switch component {
            case coinComponent:
                return viewModel.optionSource.fromCoins.count
            case walletComponent:
                return viewModel.optionSource.fromWallets.count
            default: return 0
            }
        case toSourcePicker:
            switch component {
            case coinComponent:
                return viewModel.optionSource.toCoins.count
            case walletComponent:
                return viewModel.optionSource.toWallets.count
            default: return 0
            }
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case fromSourcePicker:
            switch component {
            case coinComponent:
                return viewModel.optionSource.fromCoins[row].inAppName
            case walletComponent:
                return viewModel.optionSource.fromWallets[row]?.name ??
                    LM.dls.lightningTx_label_custom
            default: return nil
            }
        case toSourcePicker:
            switch component {
            case coinComponent:
                return viewModel.optionSource.toCoins[row].inAppName
            case walletComponent:
                return viewModel.optionSource.toWallets[row]?.name ??
                    LM.dls.lightningTx_label_custom
            default: return nil
            }
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case fromSourcePicker:
            switch component {
            case coinComponent:
                let selCoin = viewModel.optionSource.fromCoins[row]
                viewModel.selectFromCoin(selCoin, wallet: nil)
            case walletComponent:
                let selWallet = viewModel.optionSource.fromWallets[row]
                viewModel.selectFromWallet(selWallet)
            default: return
            }
        case toSourcePicker:
            switch component {
            case coinComponent:
                let selCoin = viewModel.optionSource.toCoins[row]
                viewModel.selectToCoin(selCoin, wallet: nil)
            case walletComponent:
                let selWallet = viewModel.optionSource.toWallets[row]
                viewModel.selectToWallet(selWallet)
            default: return
            }
        default: return
        }
        
        reloadPickerSourceAndSelection()
    }
    
    private func reloadPickerSourceAndSelection() {
        fromSourcePicker.reloadAllComponents()
        if let idx_fromCoin = viewModel.idx_currentSelectedFromCoin {
            fromSourcePicker.selectRow(idx_fromCoin,
                                       inComponent: coinComponent,
                                       animated: true)
        }
        
        if let idx_fromWallet = viewModel.idx_currentSelectedFromWallet {
            fromSourcePicker.selectRow(idx_fromWallet,
                                       inComponent: walletComponent,
                                       animated: true)
        }
        
        if let idx_toCoin = viewModel.idx_currentSelectedToCoin {
            toSourcePicker.selectRow(idx_toCoin,
                                     inComponent: coinComponent,
                                     animated: true)
        }
        
        if let idx_toWallet = viewModel.idx_currentSelectedToWallet {
            toSourcePicker.selectRow(idx_toWallet,
                                     inComponent: walletComponent,
                                     animated: true)
        }
    }
}

extension LightningTransactionViewController: UITextFieldDelegate {
    
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
                let maxDigit: Int = Int(viewModel.getSelectedFromCoin().digit)
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
                viewModel.updateFromAmt(finalValue)
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
