//
//  LightDepositWalletChooseViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/5/3.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightDepositWalletChooseViewController: KLModuleViewController,KLVMVC {
   
    var viewModel: LightDepositWalletChooseViewModel!
    
    func config(constructor: LightDepositWalletChooseViewController.Config) {
        self.view.layoutIfNeeded()
        
        self.viewModel = ViewModel.init(input: LightDepositWalletChooseViewModel.Input.init(toAsset: constructor.asset, amtStrInout: self.transferAmountTextField.rx.text), output:())
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
        self.transferAmountTextField.delegate = self
    }
    typealias ViewModel = LightDepositWalletChooseViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let asset:Asset
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var walletTitleLabel: UILabel!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var feeAmountLable: UILabel!
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var transAmountTitleLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var depositAddressTitile: UILabel!
    @IBOutlet weak var depositAddressLabel: UILabel!
    @IBOutlet weak var transferAmountTextField: UITextField!
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    func bindViewModel() {
        viewModel.fromAsset
            .map {
                $0?.wallet!.name!
            }
            .bind(to: self.walletButton.rx.title()).disposed(by: bag)
        
        viewModel.toAsset.map {
            $0.wallet?.address
        }.bind(to: self.depositAddressLabel.rx.text).disposed(by: bag)
        
        let coin = self.viewModel.fromAsset.value!.coin!
        viewModel.assetAvailableAmt.map {
            amt -> String? in
            let _amtString = amt.asString(
                digits: C.Coin.min_digit,
                force: true,
                maxDigits: Int(coin.digit),
                digitMoveCondition: { Decimal.init(string: $0) ?? 0 != amt }
            )
            let dls = LM.dls
            return dls.withdrawal_label_assetAmt(_amtString, coin.inAppName!)
            }
            .bind(to: availableBalanceLabel.rx.text).disposed(by: bag)
        
        self.viewModel.feeRate.asObservable().bind(to: self.feeAmountLable.rx.text).disposed(by:bag)
        
        self.walletButton.rx.klrx_tap.asDriver().drive(onNext: {[unowned self] _ in
            self.toSelectWallet()
        }).disposed(by: bag)
        
        self.viewModel.messageSubject.subscribe(onNext: { (message) in
            self.showSimplePopUp(with:"", contents: message, cancelTitle: LM.dls.g_cancel, cancelHandler: nil)
        }).disposed(by: bag)
        self.doneButton.rx.klrx_tap.asDriver().drive(onNext: {[unowned self] _ in
            self.startTransfer()
        }).disposed(by: bag)
        

       

    }
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: UIColor.init(hexString: "2C3C4E")!)
        //        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        
        changeLeftBarButtonToDismissToRoot(tintColor:palette.nav_item_2, image:  #imageLiteral(resourceName: "arrowNavBlack"))

        depositAddressTitile.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        transferAmountTextField.set(textColor: palette.input_text, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
        walletTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        feeTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        depositAddressLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
        walletButton.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        feeAmountLable.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        transAmountTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        availableBalanceLabel.set(textColor: UIColor.init(white: 0, alpha: 0.4), font: .owMedium(size: 17))
        doneButton.setTitleColor(palette.btn_bgFill_enable_text, for: .normal)
        doneButton.setTitleColor(palette.btn_bgFill_disable_text, for: .disabled)
        doneButton.set(font: UIFont.owRegular(size: 17))
        doneButton.cornerRadius = 12
        self.doneButton.isEnabled = false
        self.viewModel._transferAmt.map { $0 != nil }.map { status in
            self.doneButton.backgroundColor = status ? UIColor.init(hexString: "18ADD4") : palette.btn_bgFill_disable_bg
            return status
            } .asObservable().bind(to: self.doneButton.rx.isEnabled).disposed(by: bag)
    }
    override func renderLang(_ lang: Lang) {
        self.walletTitleLabel.text = lang.dls.payment_wallet
        self.navigationItem.title = "BTC" + lang.dls.light_deposit_btn_title
        depositAddressTitile.text = ""
        
        transferAmountTextField.set(placeholder: lang.dls.withdrawal_placeholder_withdrawalAmt)
        transAmountTitleLabel.text = lang.dls.transfer_amount_title
        feeTitleLabel.text = lang.dls.withdrawal_label_minerFee
        depositAddressTitile.text = lang.dls.withdrawal_label_toAddr
        doneButton.setTitleForAllStates(lang.dls.withdrawal_btn_nextstep)

    }
    
    private func toSelectWallet() {
        let vc = ChangeWalletViewController.instance(from: ChangeWalletViewController.Constructor(assetSupportLimit: viewModel.fromAsset.value,currentSelectedAsset:self.viewModel.fromAsset.value)
        )
        
        vc.onAssetSelected.take(1).subscribe(onNext: {
            [unowned self]
            asset in
            vc.dismissRoot(sender: nil)
            self.viewModel.changeFromAsset(asset: asset)
        })
            .disposed(by: bag)
        present(vc, animated: true, completion: nil)
    }
    
    func startTransfer() {
        guard let info = viewModel.initiateTransfer() else {
            return
        }
        
        self.askPwdBeforTransfer().subscribe(onSuccess: { (status) in
            if status {
                
                self.startBTCDeposit(info: info).bind(onNext: self.handleTransferState).disposed(by: self.bag)
            }
        }).disposed(by: bag)
    }
    
    func askPwdBeforTransfer() -> Single<Bool>{
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.withdrawal_title(self.viewModel.toAsset.value.coin!.inAppName!),
                message: dls.withdrawalConfirm_pwdVerify_title,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .destructive) {
                                                (_) in
                                                if let pwd = textField.text, pwd.count > 0 {
                                                    handler(.success(true))
                                                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:dls.qrCodeImport_alert_placeholder_pwd(self.viewModel._selectedWallet.value?.pwdHint ?? "") )
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func handleTransferState(_ state: TransferFlowState) {
        let dls = LM.dls
        switch state {
        case .waitingUserActivate:
            break
        case .signing:
            hud.startAnimating(inView: self.navigationController!.view)
            hud.updateType(.spinner, text: dls.ltTx_pwdVerify_hud_signing)
        case .broadcasting:
            hud.updateType(.spinner, text: dls.ltTx_pwdVerify_hud_broadcasting)
        case .finished(let result):
            switch result {
            case .failed(error: let err):
                hud.stopAnimating()
                self.showAPIErrorResponsePopUp(from: err, cancelTitle: dls.g_cancel)
            case .success(let record):
                hud.updateType(.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")), text: dls.g_success)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    OWRxNotificationCenter.instance
                        .transferRecordCreated(record)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.hud.stopAnimating()
                }
            }
        }
    }
    
    private func startBTCDeposit(info: WithdrawalInfo) -> Observable<TransferFlowState> {
        
        return Observable.create({ (observer) -> Disposable in
            TransferManager.manager.startBTCDepositToTTN(with: info, progressObserver: observer,ttnAsset: self.viewModel.toAsset.value)
            return Disposables.create()
        })
    }
}

extension LightDepositWalletChooseViewController: UITextFieldDelegate {
    
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
