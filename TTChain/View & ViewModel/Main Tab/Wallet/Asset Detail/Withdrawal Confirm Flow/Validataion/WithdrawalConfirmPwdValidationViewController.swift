//
//  WithdrawalConfirmPwdValidationViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalConfirmPwdValidationViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var sepline: UIView!
    @IBOutlet weak var pwdVisibleBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    struct Config {
        let info: WithdrawalInfo
    }
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalConfirmPwdValidationViewModel
    var viewModel: WithdrawalConfirmPwdValidationViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: WithdrawalConfirmPwdValidationViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalConfirmPwdValidationViewModel.InputSource(
                info: constructor.info,
                pwdInout: pwdTextField.rx.text,
                confirmInput: confirmBtn.rx.tap.asDriver(),
                changePwdVisibleInput: pwdVisibleBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func bindViewModel() {
        viewModel.isPwdVisible
            .subscribe(onNext: {
                [unowned self] isVisible in
                self.pwdVisibleBtn.setImageForAllStates(isVisible ? #imageLiteral(resourceName: "iconTextfieldEyeOn") : #imageLiteral(resourceName: "iconTextfieldEyeOff"))
            })
            .disposed(by: bag)
        
        viewModel.isPwdVisible.map { !$0 }.debug("secured").bind(to: pwdTextField.rx.isSecured).disposed(by: bag)
        
        viewModel.onDetectInvalidPwdBeforeTranfer
            .subscribe(onNext: {
                [unowned self] in
                self.showInvalidPwdAlert()
            })
            .disposed(by: bag)
        
        viewModel.hasPwd.bind(to: confirmBtn.rx.isEnabled).disposed(by: bag)
//        viewModel.hasPwd.map { !$0 }.bind(to: pwdTextField.rx.isSecured).disposed(by: bag)
        viewModel.hasPwd.subscribe(onNext: {
            [unowned self]
            isEnabled in
            let palette = TM.palette
            self.confirmBtn.backgroundColor = isEnabled ? palette.btn_bgFill_enable_bg
            : palette.btn_bgFill_disable_bg
        })
        .disposed(by: bag)
        
        viewModel.transferState
            .debug("state update pass int")
            .subscribe(onNext: {
                [unowned self]
                state in
                self.handleTransferState(state)
            })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.withdrawalConfirm_pwdVerify_title
        titleLabel.text = dls.withdrawalConfirm_pwdVerify_label_input_wallet_pwd
        pwdTextField.set(
            placeholder: dls.withdrawalConfirm_pwdVerify_placeholder_wallet_pwd
        )
        
        confirmBtn.setTitleForAllStates(dls.g_confirm)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        
        view.backgroundColor = palette.bgView_sub
        
        titleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 13))
        pwdTextField.set(textColor: palette.label_main_1, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
        sepline.backgroundColor = palette.sepline
        
        confirmBtn.set(
            color: palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showInvalidPwdAlert() {
        let dls = LM.dls
        showSimplePopUp(with: dls.withdrawalConfirm_pwdVerify_error_pwd_is_wrong,
                        contents: "",
                        cancelTitle: dls.g_confirm,
                        cancelHandler: nil)
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
    
    private func handleTransferState(_ state: TransferFlowState) {
        let dls = LM.dls
        switch state {
        case .waitingUserActivate:
            break
        case .signing:
            hud.startAnimating(inView: self.navigationController!.view)
            hud.updateType(.spinner,
                           text: dls.withdrawalConfirm_pwdVerify_hud_signing)
        case .broadcasting:
            hud.updateType(.spinner,
                           text: dls.withdrawalConfirm_pwdVerify_hud_broadcasting)
        case .finished(let result):
            switch result {
            case .failed(error: let err):
                hud.stopAnimating()
                self.showAPIErrorResponsePopUp(from: err, cancelTitle: dls.g_cancel)
            case .success(let record):
                hud.updateType(.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")), text: dls.g_success)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.hud.stopAnimating()
                    
                    OWRxNotificationCenter.instance
                        .transferRecordCreated(record)
                    self.navigationController?
                        .presentingViewController?
                        .presentingViewController?
                        .dismiss(animated: true, completion: nil)
                }
            }
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
