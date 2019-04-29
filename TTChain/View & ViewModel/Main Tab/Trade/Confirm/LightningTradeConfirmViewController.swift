//
//  LightningTradeConfirmViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LightningTradeConfirmViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var contentBase: UIView!
    @IBOutlet weak var fromCoinHeaderLabel: UILabel!
    @IBOutlet weak var toCoinHeaderLabel: UILabel!
    @IBOutlet weak var fromCoinTitleLabel: UILabel!
    @IBOutlet weak var fromCoinContentLabel: UILabel!
    @IBOutlet weak var fromCoinSepline: UIView!
    @IBOutlet weak var toCoinTitleLabel: UILabel!
    @IBOutlet weak var toCoinContentLabel: UILabel!
    @IBOutlet weak var toCoinSepline: UIView!
    @IBOutlet weak var transRateTitleLabel: UILabel!
    @IBOutlet weak var transRateContentLabel: UILabel!
    @IBOutlet weak var transRateSepline: UIView!
    
    @IBOutlet weak var fromAddressTitleLabel: UILabel!
    @IBOutlet weak var fromAddressContentBase: UIView!
    @IBOutlet weak var fromAddressContentLabel: UILabel!
    @IBOutlet weak var fromAddressSepLine: UIView!
    
    @IBOutlet weak var toAddressTitleLabel: UILabel!
    @IBOutlet weak var toAddressContentBase: UIView!
    @IBOutlet weak var toAddressContentLabel: UILabel!
    @IBOutlet weak var toAddressSepLine: UIView!
    
    @IBOutlet weak var feeRateTitleLabel: UILabel!
    @IBOutlet weak var feeRateContentBase: UIView!
    @IBOutlet weak var feeRateContentLabel: UILabel!
    @IBOutlet weak var feeRateSepLine: UIView!
    
    
    @IBOutlet weak var remarkNoteTitleLabel: UILabel!
    @IBOutlet weak var remarkNoteTextfield: UITextField!
    @IBOutlet weak var remarkNoteSepLine: UIView!
    
    @IBOutlet weak var nextStepBtn: UIButton!
    
    private var titleLabels: [UILabel] {
        return [fromCoinTitleLabel, toCoinTitleLabel, transRateTitleLabel, toAddressTitleLabel, fromAddressTitleLabel, feeRateTitleLabel,remarkNoteTitleLabel]
    }
    
    private var contentLabels: [UILabel] {
        return [fromCoinContentLabel,
                toCoinContentLabel,
                transRateContentLabel,
                toAddressContentLabel,
                fromAddressContentLabel,
                feeRateContentLabel]
    }
    
    private var seplines: [UIView] {
        return [fromCoinSepline, toCoinSepline, transRateSepline, toAddressSepLine, fromAddressSepLine,feeRateSepLine,remarkNoteSepLine]
    }
    
    struct Config {
        let source: LightningTransRecordCreateSource
    }
    
    typealias Constructor = Config
    typealias ViewModel = LightningTradeConfirmViewModel
    var viewModel: LightningTradeConfirmViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    
    func config(constructor: LightningTradeConfirmViewController.Config) {
        view.layoutIfNeeded()
        
        viewModel = ViewModel.init(
            input: LightningTradeConfirmViewModel.InputSource(
                source: constructor.source,
                remarkInOut: self.remarkNoteTextfield.rx.text,
                nextstepInput: nextStepBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindContentUpdate()
        bindViewModel()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.ltTx_title
        fromCoinTitleLabel.text = dls.ltTx_label_pay_info
        toCoinTitleLabel.text = dls.ltTx_label_changeTo
        transRateTitleLabel.text = dls.ltTx_label_exchangeRate
        toAddressTitleLabel.text = dls.ltTx_label_toAddr
        fromAddressTitleLabel.text = dls.ltTx_label_fromAddr
        feeRateTitleLabel.text = dls.ltTx_label_minerFee
        remarkNoteTitleLabel.text = dls.abInfo_label_note
        remarkNoteTextfield.set(placeholder: dls.transfer_note_placeholder)

        nextStepBtn.setTitleForAllStates(dls.g_next)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1,
                     barTint: palette.nav_bg_1)
        
        renderNavTitle(color: palette.nav_item_1,
                       font: .owMedium(size: 18))
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_1,
            image: #imageLiteral(resourceName: "btnAlertCancelNormal"),
            title: nil
        )
        
        view.backgroundColor = palette.bgView_sub
        contentBase.backgroundColor = palette.bgView_main
        fromCoinHeaderLabel.set(
            textColor: palette.label_main_1,
            font: .owRegular(size: 20)
        )
        
        toCoinHeaderLabel.set(
            textColor: palette.label_main_1,
            font: .owRegular(size: 20)
        )
        
        titleLabels.forEach { (label) in
            label.set(textColor: palette.label_sub,
                      font: .owRegular(size: 12))
        }
        
        contentLabels.forEach { (label) in
            if label == self.toAddressContentLabel {
                let addr = self.viewModel.getToAddress()
                label.set(
                    textColor: addr == nil ?
                        palette.label_sub :
                        palette.label_main_1,
                    font: .owRegular(size: 12)
                )
            }else {
                label.set(textColor: palette.label_main_1,
                          font: .owRegular(size: 12))
            }
        }
        
        seplines.forEach { (view) in
            view.backgroundColor = palette.sepline
        }
        
        nextStepBtn.set(
            color: palette.btn_bgFill_enable_text,
            font: UIFont.owRegular(size: 14),
            backgroundColor: palette.btn_bgFill_enable_bg
        )
        
        remarkNoteTextfield.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
        remarkNoteTextfield.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count > 30 {
                    return previous ?? String(new.prefix(30))
                } else if new.contains("\n"){
                    return previous ?? String(new.prefix(30))
                }else {
                    return new
                }
            }
            .subscribe(remarkNoteTextfield.rx.text)
            .disposed(by: bag)

    }
    
    private func bindContentUpdate() {
        fromAddressContentBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.toChangeFromWallet()
        })
            .disposed(by: bag)
        
        feeRateContentBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.toUpdateFeeRate()
        })
            .disposed(by: bag)
        
        toAddressContentBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.toChangeToAddress()
        })
            .disposed(by: bag)
    }
    
    private func bindViewModel() {
        let fromCoinName = viewModel.fromCoin.map { $0.inAppName! }
        let toCoinName = viewModel.toCoin.map { $0.inAppName! }
        fromCoinName.bind(to: fromCoinHeaderLabel.rx.text).disposed(by: bag)
        toCoinName.bind(to: toCoinHeaderLabel.rx.text).disposed(by: bag)
        
        Observable.combineLatest(viewModel.fromAmt.map { $0.asString(digits: 18) }, fromCoinName).map { $0 + " " + $1 }.bind(to: fromCoinContentLabel.rx.text).disposed(by: bag)
        
        Observable.combineLatest(viewModel.toAmt.map { $0.asString(digits: 18) }, toCoinName).map { $0 + " " + $1 }.bind(to: toCoinContentLabel.rx.text).disposed(by: bag)
        
        viewModel.transRate.map { "1 : \($0.asString(digits: 4))" }.bind(to: transRateContentLabel.rx.text).disposed(by: bag)
        
        viewModel.toAddress
            .map { $0 ?? LM.dls.ltTx_label_toAddr_empty_tap_to_set }
            .bind(to: toAddressContentLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.toAddress
            .map {
                str -> UIColor in
                let palette = TM.palette
                return str == nil ? palette.label_sub : palette.label_main_1
            }
            .bind(to: toAddressContentLabel.rx.textColor)
            .disposed(by: bag)
        
        viewModel.fromWallet.map { $0.address! }.bind(to: fromAddressContentLabel.rx.text).disposed(by: bag)
        
        Observable.combineLatest(
            viewModel.feeRate,
            viewModel.fromCoin.map { $0.walletMainCoinID! }
            ).map {
                rate, mainCoinID in
                let mainCoin = Coin.getCoin(ofIdentifier: mainCoinID)!
                let feeUnit: String
                let rateStr: String
                switch mainCoin.owChainType {
                case .btc:
                    feeUnit = LM.dls.fee_sat_per_byte
                    rateStr = rate.btcToSatoshi.asString(digits: 0)
                case .cic:
                    //CIC chain type fee is depended on the main coin it use.
                    feeUnit = mainCoin.inAppName!.lowercased()
                    rateStr = rate.asString(digits: 9)
                //THIS SHUOLD NOT HAPPENED
                case .eth,.ttn: return ""
                }
                
                return rateStr + " " + feeUnit
            }
            .bind(to: feeRateContentLabel.rx.text).disposed(by: bag)
        
        viewModel.onFinishPackageFinalSource.drive(onNext: {
            [unowned self] source in
            switch source.to.addressSource {
            case .local: break
            case .remote(addr: let addr):
                if (addr?.count ?? 0) == 0 {
                    self.toChangeToAddress()
                    return
                }
            }
            
            self.toPwdValidate(withSource: source)
        })
        .disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
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
    private func createInfoFromViewModel() -> WithdrawalInfo? {
        let source = viewModel.input.source
        guard let assets = source.from.fromWallet?.assets?.array as? [Asset],
            let idx = assets.index(where: { (asset) -> Bool in
                return asset.coinID! == source.from.coinID
            }) else {
                return nil
        }
        let note = viewModel.getRemarkNotes()
        let asset = assets[idx]
        let option = viewModel.getFeeOption()
        //btc/b cic/b
        let feeRate = viewModel.getFeeRate()
        
        let info = WithdrawalInfo(asset: asset, withdrawalAmt: source.from.amt, address: source.from.address, feeRate: feeRate, feeAmt: source.fee.amt, feeCoin: Coin.getCoin(ofIdentifier: source.fee.coinID)!, feeOption: option, note: note
        )

        return info
    }
    
    private func toChangeFromWallet() {
        guard let info = createInfoFromViewModel() else { return }
        let vc = WithdrawalConfirmChangeWalletViewController.instance(from: WithdrawalConfirmChangeWalletViewController.Config(info: info))
        vc.selectNotifier.subscribe(onNext: {
            [unowned self] asset in
            self.viewModel.updateFromWallet(asset.wallet!)
        })
            .disposed(by: bag)
        
        navigationController?.pushViewController(vc)
    }
    
    private func toUpdateFeeRate() {
        //FIXME: In further if cic chainType fee could able to update, then this logic shuold change to compare the mainCoin of the fromCoin.
        switch viewModel.getFromCoin().owChainType {
        case .btc: toUpdateBTCFeeRate()
        case .cic: toUpdateCICFeeRate()
        case .eth: return errorDebug(response: ())
        case .ttn: return errorDebug(response: ())
        }
    }
    
    private func toUpdateBTCFeeRate() {
        guard let info = createInfoFromViewModel() else { return }
        
        let vc = WithdrawalBTCFeeInfoViewController.instance(from: WithdrawalBTCFeeInfoViewController.Config(
            defaultFeeOption: info.feeOption, defaultFeeRate: info.feeRate
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
            toColor: palette.application_main,
            shouldClear: true,
            size: CGSize.init(width: 44, height: 30)
        )
        
        completeBtn.set(color: palette.application_main,
                        font: UIFont.owRegular(size: 18),
                        text: dls.g_done)
        
        vc.isAllFieldsHaveValue.bind(to: completeBtn.rx.isEnabled).disposed(by: vc.bag)
        
        vc.title = dls.ltTx_minerFee_title
        vc.changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        //        vc.changeNavShadowVisibility()
    }
    
    private func toUpdateCICFeeRate() {
        //Disable action now, for right now the cic fee is free.
        return
        
        /* guard let info = createInfoFromViewModel() else { return }
        let vc = WithdrawalCICFeeInfoViewController.instance(from: WithdrawalCICFeeInfoViewController.Config(
            defaultOptions: info.feeOption, defaultGasPrice: info.feeRate.cicToCICUnit, defaultGas: info.feeAmt
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
            toColor: palette.application_main,
            shouldClear: true,
            size: CGSize.init(width: 44, height: 30)
        )
        
        completeBtn.set(color: palette.application_main,
                        font: UIFont.owRegular(size: 18),
                        text: dls.g_done)
        
        vc.viewModel.isFeeInfoCompleted.bind(to: completeBtn.rx.isEnabled).disposed(by: vc.bag)
        
        vc.title = dls.ltTx_minerFee_title
        vc.changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil) */
        //        vc.changeNavShadowVisibility()
    }
    
    @objc private func completeUpdateFee() {
        if let top = navigationController?.topViewController as? WithdrawalBTCFeeInfoViewController {
            let result = top.viewModel.getSelectedResult()
            viewModel.updateFeeOption(rate: result.1, option: result.0)
        } else if let top = navigationController?.topViewController as? WithdrawalCICFeeInfoViewController {
            if let result = top.viewModel.getFeeInfo() {
                viewModel.updateFeeOption(rate: result.rate, option: result.option)
            }
        }
        
        navigationController?.popToViewController(self, animated: true)
    }
    
    private func toChangeToAddress() {
        let nav = WithdrawalChangeToAddressViewController.navInstance(from: WithdrawalChangeToAddressViewController.Config(source: viewModel.currentSource))
        let vc = nav.viewControllers[0] as! WithdrawalChangeToAddressViewController
        vc.sourceConfirm.subscribe(onNext: { [unowned self] (source) in
            self.viewModel.updateToAddressSource(source)
        }).disposed(by: bag)
        
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func toPwdValidate(withSource source: LightningTransRecordCreateSource) {
        let vc = WithdrawalLightningPwdValidationViewController.instance(
            from: WithdrawalLightningPwdValidationViewController.Config(source: source)
        )
        navigationController?.pushViewController(vc)
    }
}
