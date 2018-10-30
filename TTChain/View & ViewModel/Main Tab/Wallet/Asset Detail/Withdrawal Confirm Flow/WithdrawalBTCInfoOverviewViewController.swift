//
//  WithdrawalInfoOverviewViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/8.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalBTCInfoOverviewViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var infoBase: UIView!
    @IBOutlet weak var transAmtLabel: UILabel!
    @IBOutlet weak var transCoinLabel: UILabel!
    
    @IBOutlet weak var transTypeTitleLabel: UILabel!
    @IBOutlet weak var transTypeContentLabel: UILabel!
    @IBOutlet weak var transTypeSepline: UIView!
    
    @IBOutlet weak var toAddrTitleLabel: UILabel!
    @IBOutlet weak var toAddrContentLabel: UILabel!
    @IBOutlet weak var toAddrSepline: UIView!
    
    @IBOutlet weak var fromAddrTitleLabel: UILabel!
    @IBOutlet weak var fromAddrContentBase: UIView!
    @IBOutlet weak var fromAddrContentLabel: UILabel!
    @IBOutlet weak var fromWalletNameLabel: UILabel!
    @IBOutlet weak var fromAddrSepline: UIView!
    
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeContentBase: UIView!
    @IBOutlet weak var feeContentLabel: UILabel!
    @IBOutlet weak var feeContentSepLine: UIView!
    
    @IBOutlet weak var remarkNoteTitlelabel: UILabel!
    @IBOutlet weak var remarkNoteContentLabel: UILabel!
    @IBOutlet weak var remarkNoteSeparatorView: UIView!
    
    @IBOutlet weak var nextstepBtn: UIButton!
    
    struct Config {
        let info: WithdrawalInfo
    }
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalInfoOverviewViewModel
    var viewModel: WithdrawalInfoOverviewViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: WithdrawalBTCInfoOverviewViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: WithdrawalInfoOverviewViewModel.InputSource(
                info: constructor.info,
                changeWalletInput: fromAddrContentBase.rx.klrx_tap.asDriver(),
                changeFeeRateInput: feeContentBase.rx.klrx_tap.asDriver(),
                confirmInput: nextstepBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }

    private func bindViewModel() {
        viewModel.transAmt.map {
            $0.asString(digits: 18)
        }
        .bind(to: transAmtLabel.rx.text)
        .disposed(by: bag)
        
        viewModel.coin.map { $0.inAppName! }
        .bind(to: transCoinLabel.rx.text)
        .disposed(by: bag)
        
        viewModel.toAddr
            .bind(to: toAddrContentLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.fromAddr
            .bind(to: fromAddrContentLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.fromAsset
            .map { $0.wallet!.name! }
            .bind(to: fromWalletNameLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.feeRate.map { $0.btcToSatoshi.asString(digits: 0) }
            .map {
                $0 + " sat/b"
            }
            .bind(to: feeContentLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.onStartChangingWallet
            .drive(onNext: {
                [unowned self] info in
                self.toChooseWallet(withInfo: info)
            })
            .disposed(by: bag)
        
        viewModel.onStartChangingFeeRate
            .drive(onNext: {
                [unowned self] info in
                self.toUpdateFeeRate(withInfo: info)
            })
            .disposed(by: bag)
        
        viewModel.toValidate
            .subscribe(onNext: {
                [unowned self] info in
                self.toPwdValidate(withInfo: info)
            })
            .disposed(by: bag)
        
        viewModel.foundValidationError
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] err in
                self.showSimplePopUp(with: "",
                                     contents: err.localizedFailedDesciption,
                                     cancelTitle: LM.dls.g_done,
                                     cancelHandler: nil)
            })
            .disposed(by: bag)
        
        viewModel.remarkNote.bind(to: remarkNoteContentLabel.rx.text)
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        let info = viewModel.input.info
        title = dls.withdrawalConfirm_title
        transTypeTitleLabel.text = dls.withdrawalConfirm_label_payment_detail
        toAddrTitleLabel.text = dls.withdrawalConfirm_label_receipt_address
        fromAddrTitleLabel.text = dls.withdrawalConfirm_label_payment_address
        feeTitleLabel.text = dls.withdrawalConfirm_label_miner_fee
        
        transTypeContentLabel.text = dls.withdrawalConfirm_label_payment_detail_content(info.feeCoin.inAppName!)
        remarkNoteTitlelabel.text = dls.abInfo_label_note
        
        nextstepBtn.setTitleForAllStates(dls.g_next)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btnAlertCancelNormal"), title: nil)
        
        view.backgroundColor = palette.bgView_sub
        let renderTitle: (UILabel) -> Void = {
            label in
            label.set(textColor: palette.label_sub, font: .owRegular(size: 12))
        }
        
        renderTitle(transTypeTitleLabel)
        renderTitle(fromAddrTitleLabel)
        renderTitle(toAddrTitleLabel)
        renderTitle(feeTitleLabel)
        renderTitle(remarkNoteTitlelabel)

        let renderContent: (UILabel) -> Void = {
            label in
            label.set(textColor: palette.label_main_1, font: .owRegular(size: 12))
        }
        
        renderContent(transTypeContentLabel)
        renderContent(toAddrContentLabel)
        renderContent(fromAddrContentLabel)
        renderContent(feeContentLabel)
        renderContent(remarkNoteContentLabel)

        fromWalletNameLabel.set(textColor: palette.label_sub, font: .owRegular(size: 12))
        
        nextstepBtn.set(color: palette.btn_bgFill_enable_text, font: UIFont.owRegular(size: 14), backgroundColor: palette.btn_bgFill_enable_bg)
        
        let renderSepline: (UIView) -> Void = {
            sep in
            sep.backgroundColor = palette.sepline
        }
        
        renderSepline(toAddrSepline)
        renderSepline(fromAddrSepline)
        renderSepline(feeContentSepLine)
        renderSepline(transTypeSepline)
        renderSepline(remarkNoteSeparatorView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        changeLeftBarButtonToDismissToRoot(tintColor: .black, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    @IBAction func test(_ sender: Any) {
    //        let vc = xib(vc: WithdrawalInfoOverviewViewController.self)
    //        let nav = UINavigationController.init(rootViewController: vc)
    //        nav.modalPresentationStyle = .overFullScreen
    //        self.navigationController?.present(nav, animated: true, completion: nil)
    //        vc.changeBackBarButton()
    //        vc.title = "test2"
    //    }
    
    
    // MARK: - Navigation
    
    private func toPwdValidate(withInfo info: WithdrawalInfo){
        let vc = WithdrawalConfirmPwdValidationViewController.instance(from: WithdrawalConfirmPwdValidationViewController.Config(info: info)
        )
        
        navigationController?.pushViewController(vc)
    }
    
    private func toChooseWallet(withInfo info: WithdrawalInfo) {
        let vc = WithdrawalConfirmChangeWalletViewController.instance(from: WithdrawalConfirmChangeWalletViewController.Config(info: info)
        )
        
        navigationController?.pushViewController(vc)
        vc.selectNotifier.subscribe(onNext: {
            [unowned self]
            asset in
            self.viewModel.changeAsset(asset)
        })
            .disposed(by: bag)
    }
    
    
    private func toUpdateFeeRate(withInfo info: WithdrawalInfo) {
        let vc = WithdrawalBTCFeeInfoViewController.instance(from: WithdrawalBTCFeeInfoViewController.Config(
            defaultFeeOption: info.feeOption, defaultFeeRate: info.feeRate.btcToSatoshi
            )
        )
        
        navigationController?.pushViewController(vc)
        let dls = LM.dls
        let palette = TM.palette
        let completeBtn = vc.createRightBarButton(
            target: self,
            selector: #selector(completeUpdateFee),
            image: nil,
            title: dls.g_done,
            toColor: palette.application_main, shouldClear: true,
            size: CGSize.init(width: 44, height: 30)
        )
        
        completeBtn.set(color: palette.application_main,
                        font: UIFont.owRegular(size: 18),
                        text: dls.g_done)
        
        vc.isAllFieldsHaveValue.bind(to: completeBtn.rx.isEnabled).disposed(by: vc.bag)
        
        vc.title = dls.withdrawalConfirm_changeFee_title
        vc.changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
//        vc.changeNavShadowVisibility()
    }
    
    @objc private func completeUpdateFee() {
        if let top = navigationController?.topViewController as? WithdrawalBTCFeeInfoViewController {
            let result = top.viewModel.getSelectedResult()
            viewModel.changeFeeOption(result.0)
            viewModel.changeFeeRate(result.1)
        }
        
        navigationController?.popToViewController(self, animated: true)
    }
 

}
