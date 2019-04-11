//
//  CreateRedEnvelopeViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/22.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift


class CreateRedEnvelopeViewController: UIViewController {

    @IBOutlet weak var coinTypeTitleLabel: UILabel! {
        didSet {
            coinTypeTitleLabel.text = LM.dls.red_env_send_currency
        }
    }
    @IBOutlet weak var selectedCoinNameLabel: UILabel! {
        didSet {
            viewModel.output.walletCoinTitleSubject.bind(to: selectedCoinNameLabel.rx.text)
                .disposed(by: viewModel.disposeBag)
            selectedCoinNameLabel.textColor = .black
            selectedCoinNameLabel.font = UIFont.owMedium(size: 15)
        }
    }
    
    @IBOutlet weak var selectedCoinAmountLabel: UILabel! {
        didSet {
            viewModel.output.balanceSubject.bind(to: selectedCoinAmountLabel.rx.text)
                .disposed(by: viewModel.disposeBag)
            selectedCoinAmountLabel.textColor = UIColor.owIceCold
            selectedCoinAmountLabel.font = .owMedium(size:15)
        }
    }
    
    @IBOutlet weak var selectCoinButon: UIButton!
    
    @IBOutlet weak var amountToTransferTitleLabel: UILabel! {
        didSet {
            amountToTransferTitleLabel.text = LM.dls.red_env_send_enter_amount
        }
    }
    @IBOutlet weak var amountTransferTextField: UITextField! {
        didSet {
            amountTransferTextField.rx.text.bind(to: viewModel.input.amountRelay).disposed(by: viewModel.disposeBag)
            amountTransferTextField.placeholder = LM.dls.red_env_send_enter_amount
            
        }
    }
    
    @IBOutlet weak var numberOfReceiversView: UIStackView! {
        didSet {
            viewModel.output.isCountViewHiddenSubject.bind(to: numberOfReceiversView.rx.isHidden).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet weak var numberOfPeopleTitleLabel: UILabel! {
        didSet {
            viewModel.output.membersCountSubject.bind(to: numberOfPeopleTitleLabel.rx.attributedText).disposed(by: viewModel.disposeBag)
        }
    }
//    @IBOutlet weak var groupMemberCountLabel: UILabel! {
//        didSet {
//            viewModel.output.membersCountSubject.bind(to: groupMemberCountLabel.rx.text).disposed(by: viewModel.disposeBag)
//        }
//    }
    @IBOutlet weak var numberOfPeopleTextField: UITextField! {
        didSet {
            numberOfPeopleTextField.rx.text.orEmpty.map { Int($0) }
                .bind(to: viewModel.input.limitCountRelay).disposed(by: viewModel.disposeBag)
            numberOfPeopleTextField.placeholder = LM.dls.red_env_send_number_of_red_env
        }
    }
    @IBOutlet weak var distributionTypeTitleLabel: UILabel! {
        didSet {
            distributionTypeTitleLabel.text = LM.dls.red_env_send_dist_rule
        }
    }
    
    @IBOutlet weak var equalDistributionLabal: UILabel! {
        didSet {
            equalDistributionLabal.text = LM.dls.red_env_send_divide
        }
    }
    @IBOutlet weak var randomDisrtibutionLabel: UILabel! {
        didSet {
            randomDisrtibutionLabel.text = LM.dls.red_env_send_random
        }
    }
    @IBOutlet weak var equalDistributionButton: UIButton! {
        didSet {
            equalDistributionButton.rx.tap.asDriver().drive(onNext: {
                self.randomDistributionButton.isSelected = false
                self.equalDistributionButton.isSelected = true
                self.viewModel.input.typeRelay.accept(.group)
            }).disposed(by:viewModel.disposeBag)
            
        }
    }
    @IBOutlet weak var randomDistributionButton: UIButton! {
        didSet {
            randomDistributionButton.rx.tap.asDriver().drive( onNext:{
                self.equalDistributionButton.isSelected = false
                self.randomDistributionButton.isSelected = true
                self.viewModel.input.typeRelay.accept(.lucky)

            }).disposed(by:viewModel.disposeBag)
        }
    }
    
    @IBOutlet weak var distributionTypeStackView: UIStackView!
    
    @IBOutlet weak var expirationTimeTitleLabel : UILabel! {
        didSet {
            expirationTimeTitleLabel.text = LM.dls.red_env_send_time_limit
        }
    }
    
    @IBOutlet weak var expirationTimeLabel : UILabel! {
        didSet {
            viewModel.output.expiredSubject.bind(to: expirationTimeLabel.rx.text)
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet weak var expirationTimeSelectionButton: UIButton!
    
    @IBOutlet weak var scheduleStackView: UIStackView!
    @IBOutlet weak var scheduleTitleLabel : UILabel!
    @IBOutlet weak var sendInfFutureSelectionLabel : UILabel!
    @IBOutlet weak var sendInfFutureSelectionSwitch: UISwitch!
    @IBOutlet weak var sendInFutureTimeLabel : UILabel!
    @IBOutlet weak var sendInfutureSelectionButton: UIButton!
    
    @IBOutlet weak var messageTitleLabel: UILabel! {
        didSet {
            messageTitleLabel.text = LM.dls.red_env_send_comment
        }
    }
    @IBOutlet weak var messageTextView: KLPlaceholderTextView! {
        didSet{
            messageTextView.rx.text.bind(to: viewModel.input.messageRelay).disposed(by: viewModel.disposeBag)
            messageTextView.placeholder = LM.dls.red_env_comment_placeholder
        }
    }
    @IBOutlet weak var messageCountLabel: UILabel! {
        didSet {
            viewModel.output.countSubject.bind(to: messageCountLabel.rx.text).disposed(by: viewModel.disposeBag)
            viewModel.output.countColorSubject.bind(to: messageCountLabel.rx.textColor)
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    @IBOutlet weak var infoMessageLabelOne: UILabel! {
        didSet {
            infoMessageLabelOne.textColor = .owIceCold
            infoMessageLabelOne.text = LM.dls.red_env_send_notice_one
        }
    }
    @IBOutlet weak var infoMessageLabelTwo: UILabel! {
        didSet {
            infoMessageLabelTwo.textColor = .owIceCold
            infoMessageLabelTwo.text = LM.dls.red_env_send_notice_two
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.rx.tap.bind(to: viewModel.input.sendTapSubject).disposed(by: viewModel.disposeBag)
            viewModel.output.isSendButtonEnabledSubject.bind(to: sendButton.rx.isEnabled)
                .disposed(by: viewModel.disposeBag)
            sendButton.cornerRadius = sendButton.height/2
            sendButton.backgroundColor = UIColor.init(red:246, green:181,blue: 95)
            sendButton.setTitle(LM.dls.g_confirm, for: .normal)
        }
    }
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.output.isTypeButtonHiddenSubject.bind(to: distributionTypeStackView.rx.isHidden).disposed(by: viewModel.disposeBag)
        changeBackBarButton(toColor:Theme.default.palette.nav_item_2, image:  #imageLiteral(resourceName: "arrowNavBlack"))
        self.scheduleStackView.isHidden = true
        self.navigationItem.title = LM.dls.create_red_env_title
    }
    
    
    private lazy var walletPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    private lazy var timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    private lazy var finishedBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
            self.responder.resignFirstResponder()
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: viewModel.disposeBag)
        barButtonItem.tintColor = UIColor.black
        return barButtonItem
    }()
    private lazy var pickerViewAccessoryView: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let flexiableBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                                     target: self,
                                                     action: nil)
        toolbar.items = [flexiableBarButtonItem, finishedBarButtonItem]
        return toolbar
    }()
    private lazy var responder: UITextField = {
        let responder = UITextField()
        responder.inputAccessoryView = pickerViewAccessoryView
        view.addSubview(responder)
        return responder
    }()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btnCancelWhiteNormal.png"), style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.bind(to: viewModel.input.closeTapSubject).disposed(by: viewModel.disposeBag)
        barButtonItem.tintColor = UIColor.black
        return barButtonItem
    }()
    
    private let viewModel: CreateRedEnvelopeViewModel
   
    init(viewModel: CreateRedEnvelopeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: CreateRedEnvelopeViewController.className, bundle: nil)
        viewModel.output.messageSubject.bind(to: rx.message).disposed(by: viewModel.disposeBag)
        viewModel.output.animateHUDSubject.subscribe(onNext: { [weak self] status in
            if status {
                self?.hud.startAnimating(inView: self?.view)
            }else {
                self?.hud.stopAnimating()
            }
        }).disposed(by:viewModel.disposeBag)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func clickWalletCoin(_ sender: UIButton) {
        responder.resignFirstResponder()
        responder.inputView = walletPickerView
        responder.becomeFirstResponder()
    }
    
    @IBAction private func clickTime(_ sender: UIButton) {
        responder.resignFirstResponder()
        responder.inputView = timePickerView
        responder.becomeFirstResponder()
    }
}


extension CreateRedEnvelopeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == walletPickerView {
            return walletPickerViewTitle(row: row, component: component)
        } else if pickerView == timePickerView {
            return timePickerViewTitle(row: row, component: component)
        } else {
            return nil
        }
    }
    
    private func walletPickerViewTitle(row: Int, component: Int) -> String? {
        if component == 0 {
            return self.viewModel.wallets[row].name ?? ""
        } else {
            guard let coins = self.viewModel.coins.value else {
                return ""
            }
            return coins[row].inAppName
        }
    }
    
    private func timePickerViewTitle(row: Int, component: Int) -> String? {
        switch component {
        case 0: return "\(row)" + LM.dls.red_env_send_day
        case 1: return "\(row)" + LM.dls.red_env_send_hour
        case 2: return "\(row)" + LM.dls.red_env_send_minute
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == walletPickerView {
            if component == 0 {
                self.viewModel.input.walletRelay.accept(self.viewModel.wallets[row])
                pickerView.selectRow(0, inComponent: 1, animated: true)
                guard let coins = self.viewModel.coins.value else {
                    return
                }
                viewModel.input.walletCoinRelay.accept(coins[0])
                pickerView.reloadAllComponents()
            } else {
                guard let coins = self.viewModel.coins.value else {
                    return
                }
                viewModel.input.walletCoinRelay.accept(coins[row])
            }
        } else if pickerView == timePickerView {
            switch component {
            case 0: viewModel.input.expiredDaySubject.onNext(row)
            case 1: viewModel.input.expiredHourSubject.onNext(row)
            case 2: viewModel.input.expiredMinuteSubject.onNext(row)
            default: return
            }
        }
    }
}

extension CreateRedEnvelopeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == walletPickerView {
            return 2
        } else if pickerView == timePickerView {
            return 3
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == walletPickerView {
            if component == 0 {
                return self.viewModel.wallets.count
            } else {
                return self.viewModel.coins.value?.count ?? 0
            }
        } else if pickerView == timePickerView {
            switch component {
            case 0: return 8
            case 1: return 24
            case 2: return 60
            default: return 0
            }
        } else {
            return 0
        }
    }
}


extension CreateRedEnvelopeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Always enable delete
        if textField != self.amountTransferTextField {
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
            textField.text = zeroPrefixTruncedStr
            textField.sendActions(for: .valueChanged)
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
