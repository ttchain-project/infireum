//
//  WithdrawalConfirmationViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/19.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class WithdrawalConfirmationViewController: KLModuleViewController, KLVMVC {
    var viewModel: WithdrawalConfirmationViewModel!
    typealias ViewModel = WithdrawalConfirmationViewModel
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Config
    
    struct Config {
        let info:WithdrawalInfo
    }
    
    func config(constructor: WithdrawalConfirmationViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: WithdrawalConfirmationViewModel.Input(info:constructor.info), output: ())
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var transferAmtTitleLabel: UILabel!
    @IBOutlet weak var transferAmtValueLabel: UILabel!
    
    @IBOutlet weak var senderAddressTitleLabel: UILabel!
    @IBOutlet weak var senderAddressValueLabel: UILabel!
    
    @IBOutlet weak var receiversAddressTitleLabel: UILabel!
    @IBOutlet weak var receiversAddressValueLabel: UILabel!

    @IBOutlet weak var feeAmtTitleLabel: UILabel!
    @IBOutlet weak var feeAmtValueLabel: UILabel!
    @IBOutlet weak var feeContentDetailLabel: UILabel!
    
    @IBOutlet weak var notesTitleLabel: UILabel!
    @IBOutlet weak var notesValueLabel: UILabel!

    lazy var allTitleLabels:[UILabel] = [transferAmtTitleLabel,senderAddressTitleLabel,receiversAddressTitleLabel,feeAmtTitleLabel,notesTitleLabel]
    lazy var allValueLabels:[UILabel] = [transferAmtValueLabel,senderAddressValueLabel,receiversAddressValueLabel,feeAmtValueLabel,notesValueLabel]
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    override func renderTheme(_ theme: Theme) {
       _ = allTitleLabels.map {label in
            label.set(textColor: theme.palette.application_main, font: .owRegular(size:12))
        }
        _ = allValueLabels.map {label in
            label.set(textColor: theme.palette.label_main_1, font: .owRegular(size:14))
        }
        feeContentDetailLabel.set(textColor: theme.palette.label_sub, font: .owRegular(size:12))
    }
    override func renderLang(_ lang: Lang) {
        
        let titles = [lang.dls.transfer_amount_title,lang.dls.withdrawalConfirm_label_payment_address,lang.dls.withdrawalConfirm_label_receipt_address,lang.dls.withdrawalConfirm_label_miner_fee,lang.dls.abInfo_label_note]
        
        for (label,title) in zip(self.allTitleLabels,titles) {
            label.text = title
        }
        confirmButton.setTitleForAllStates(lang.dls.g_confirm)
        modifyButton.setTitleForAllStates(lang.dls.transfer_back_button_title)
    }
    
    func bindUI() {
        self.feeContentDetailLabel.isHidden = self.viewModel.input.info.asset.wallet!.walletMainCoinID != Coin.eth_identifier
        
        self.viewModel.transferAmoutStr.bind(to: self.transferAmtValueLabel.rx.text).disposed(by: bag)
        self.viewModel.senderAddress.bind(to: self.senderAddressValueLabel.rx.text).disposed(by: bag)
        
        self.viewModel.receiverAddress.bind(to: self.receiversAddressValueLabel.rx.text).disposed(by: bag)
        
        self.viewModel.totalFeeStr.bind(to: self.feeAmtValueLabel.rx.text).disposed(by: bag)
        
        self.feeContentDetailLabel.isHidden = self.viewModel.input.info.asset.wallet!.walletMainCoinID != Coin.eth_identifier
        self.viewModel.ethFeeDetailContent.bind(to: self.feeContentDetailLabel.rx.text).disposed(by: bag)
        
        self.viewModel.noteString.bind(to: self.notesValueLabel.rx.text).disposed(by: bag)
        
        self.modifyButton.rx.klrx_tap.drive(onNext:{_ in self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        self.confirmButton.rx.klrx_tap.drive(onNext:{[weak self] _ in
            guard let `self` = self else{
                return
            }
            self.askPwdBeforTransfer().subscribe(onSuccess: { (status) in
                if status {
                    self.viewModel.startDeposit().bind(onNext: self.handleTransferState).disposed(by: self.bag)
                }
            }).disposed(by: self.bag)
        }).disposed(by: bag)
    }
    
    func askPwdBeforTransfer() -> Single<Bool>{
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.withdrawal_title(self.viewModel.input.info.asset.coin!.inAppName!),
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
                tf.set(placeholder:dls.qrCodeImport_alert_placeholder_pwd(self.viewModel.input.info.wallet.pwdHint ?? "") )
                tf.isSecureTextEntry = true
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
                    self.hud.stopAnimating()
                    self.showSuccessPopup(forRecord: record)
                    
                }
            }
        }
    }
    
    func showSuccessPopup(forRecord record:TransRecord) {
        self.showAlert(title: LM.dls.g_success, message: LM.dls.transfer_success_check_record_message, buttonTitles: [LM.dls.check_record_btn_title,LM.dls.g_close]) { (index) in
            switch index {
            case 0:
                DLogInfo("ShowRecord")
                guard let presentingVC = self.navigationController?.presentingViewController else {
                    return
                }
                self.navigationController?.dismiss(animated: false, completion: {
                    let transRecordVC = TransRecordDetailViewController.instance(from: TransRecordDetailViewController.Config(transRecord: record, asset: self.viewModel.input.info.asset))
                    let navVC = presentingVC as! UINavigationController
                    navVC.pushViewController(transRecordVC, animated: false)
                })
            default:
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
