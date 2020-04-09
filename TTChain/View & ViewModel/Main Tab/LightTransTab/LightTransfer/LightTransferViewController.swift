//
//  LightTransferViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class LightTransferViewController: KLModuleViewController, KLVMVC {
    var viewModel: WithdrawalBaseViewModel!
    
    func config(constructor: LightTransferViewController.Config) {
        view.layoutIfNeeded()
        self.purpose = constructor.purpose
        
        configChildViewControllers(config: constructor)
        viewModel = ViewModel.init(
            input: WithdrawalBaseViewModel.InputSource(
                asset: constructor.asset,
                amtProvider: assetVC.viewModel,
                addressProvider: addressVC.viewModel,
                feeProvider: feeInfoProvider,
                getWithdrawalResultInput: nextStepBtn.rx.tap.asDriver(),
                note: remarkNoteVC.viewModel
            ),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        bindUI()
        bindViewModel()
        
    }
    
    
    typealias ViewModel = WithdrawalBaseViewModel
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Config

    enum Purpose {
        case ifrcTransfer
        case btcnWithdrawal
    }
    struct Config {
        let asset:Asset
        let purpose:Purpose
    }
    
    private var assetVC: WithdrawalAssetViewController!
    private var addressVC: LightWithdrawalAddressViewController!
    private var feeVC: UIViewController!
    private var remarkNoteVC : WithdrawalRemarksViewController!
    private var feeInfoProvider:LightWithdrawalFeeViewModel!
    var feeVCHeightConstraint : NSLayoutConstraint?

    private var purpose:Purpose!
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    private func configChildViewControllers(config: Config) {
        let fiat = Identity.singleton!.fiat!
        assetVC = WithdrawalAssetViewController.instance(from: WithdrawalAssetViewController.Config(asset:config.asset, fiat: fiat))
        addChildViewController(assetVC)
        assetVC.didMove(toParentViewController: self)
        scrollView.addSubview(assetVC.view)
        
        assetVC.transferAllButton.rx.klrx_tap.asDriver().drive(onNext: {
            let feeInfo = self.viewModel.input.feeProvider.getFeeInfo()
            self.assetVC.viewModel.transferAll(withFee:feeInfo)
        }).disposed(by:bag)
        
       
        let toAddressCoinID = self.purpose == .ifrcTransfer ? config.asset.coinID! : Coin.btc_identifier
        
        addressVC = LightWithdrawalAddressViewController.instance(from: LightWithdrawalAddressViewController.Config(asset: config.asset, toAddressCoinID: toAddressCoinID))
        addChildViewController(addressVC)
        addressVC.didMove(toParentViewController: self)
        scrollView.addSubview(addressVC.view)
//        addressVC.addrbookBtn.isHidden = self.purpose == .ifrcTransfer
        
        
        addressVC.onTapChangeToAddress.drive(onNext: {
            [unowned self] in
            self.toAddressbookList()
        }).disposed(by: bag)
       
        let feeVC = LightWithdrawalFeeViewController.instance(from: LightWithdrawalFeeViewController.Config(asset:config.asset, purpose: config.purpose))
        addChildViewController(feeVC)
        feeVC.didMove(toParentViewController: self)
        self.feeVC = feeVC
        self.feeInfoProvider = feeVC.viewModel
        scrollView.addSubview(feeVC.view)

        remarkNoteVC = WithdrawalRemarksViewController.instance(from: WithdrawalRemarksViewController.Config())

        if self.purpose == .ifrcTransfer {
            addChildViewController(remarkNoteVC)
            remarkNoteVC.didMove(toParentViewController: self)
            scrollView.addSubview(remarkNoteVC.view)
            
        }
        self.setupConstraints()
    }
    
    private func setupConstraints () {
        
        constrain(assetVC.view, scrollView) { [unowned self] (view, scroll) in
            view.top == scroll.top + 25
            view.leading == scroll.leading
            view.trailing == scroll.trailing
            view.width == scroll.width
            let height = self.assetVC.preferedHeight
            view.height == height
        }
        
        constrain(feeVC.view, assetVC.view, scrollView) {[unowned self] (fee, asset, scroll) in
            fee.leading == asset.leading
            fee.trailing == asset.trailing
            fee.top == asset.bottom
            let height = (self.feeVC as! WithdrawalChildVC).preferedHeight
            self.feeVCHeightConstraint = (fee.height == height)
        }
//        constrain(addressVC.view, assetVC.view, scrollView) { [unowned self] (addr, asset, scroll) in
//            addr.leading == asset.leading
//            addr.trailing == asset.trailing
//            addr.top == asset.bottom + 12
//            let height = self.addressVC.preferedHeight
//            addr.height == height
//        }
//
        
        constrain(addressVC.view, feeVC.view, scrollView) { (address, fee, scroll) in
            address.leading == fee.leading
            address.trailing == fee.trailing
            address.top == fee.bottom + 12
            let height = self.addressVC.preferedHeight
            address.height == height
            if self.purpose == .btcnWithdrawal {
                address.bottom == scroll.bottom - 10
            }
        }
        
//        constrain(feeVC.view, addressVC.view, scrollView) { (fee, addr, scroll) in
//            fee.leading == addr.leading
//            fee.trailing == addr.trailing
//            fee.top == addr.bottom + 12
//            let height = (feeVC as! WithdrawalChildVC).preferedHeight
//            fee.height == height
//            if self.purpose == .btcnWithdrawal {
//                fee.bottom == scroll.bottom - 10
//
//            }
//        }

        if self.purpose == .ifrcTransfer {
            constrain(remarkNoteVC.view, addressVC.view, scrollView) { [unowned self] (remark, address, scroll) in
                remark.leading == address.leading
                remark.trailing == address.trailing
                remark.width == address.width
                let height = self.remarkNoteVC.preferedHeight
                remark.height == height
                remark.top == address.bottom + 10
                remark.bottom == scroll.bottom - 10
            }
        }
    }
    
    private func updateContraintsForRemark(isDisplayed: Bool, group: ConstraintGroup) {
        if isDisplayed {
            constrain(self.remarkNoteVC.view,self.feeVC.view, replace: group) { (remark,fee) in
                remark.top == fee.bottom + 12
            }
        } else {
            constrain(self.remarkNoteVC.view,self.addressVC.view, replace: group) { (remark,address) in
                remark.top == address.bottom + 56 + 12
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        self.navigationItem.title = dls.withdrawal_title(viewModel.input.asset.coin!.inAppName!)
        nextStepBtn.setTitleForAllStates(dls.withdrawal_btn_nextstep)
        backButton.setTitleForAllStates(dls.g_cancel)

    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: UIColor.init(hexString: "2C3C4E")!, barTint: UIColor.init(hexString: "2C3C4E")!)
        self.navigationController?.navigationBar.isTranslucent = false;

        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString: "2C3C4E")!
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        createRightBarButton(target: self, selector: #selector(toQRCode), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), title: nil, toColor: palette.nav_item_2, shouldClear: true)
        if self.purpose == .ifrcTransfer {
            changeBackBarButton(toColor:palette.nav_item_2, image:  #imageLiteral(resourceName: "btn_previous_light"))
        }else {
            changeLeftBarButtonToDismissToRoot(tintColor:palette.nav_item_2, image:  #imageLiteral(resourceName: "btn_previous_light"))
        }

        nextStepBtn.setTitleColor(palette.btn_bgFill_enable_text, for: .normal)
        nextStepBtn.setTitleColor(palette.btn_bgFill_disable_text, for: .disabled)
        nextStepBtn.set(font: UIFont.owRegular(size: 14))
        self.scrollView.backgroundColor = .clear
        self.view.backgroundColor = palette.bgView_main
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.view.setGradientColor(color1: UIColor.init(red: 44, green: 60, blue: 78)?.cgColor, color2: UIColor.init(red: 24, green: 34, blue: 39)?.cgColor)
//    }
    
    private func bindUI() {
        viewModel.isAbleToStartTransfer.subscribe(onNext: {
            [unowned self]
            isEnabled in
            let palette = TM.palette
          self.nextStepBtn.backgroundColor = isEnabled ? palette.btn_bgFill_enable_bg : palette.btn_bgFill_disable_bg
        })
            .disposed(by: bag)
        
        viewModel.isAbleToStartTransfer.bind(to: nextStepBtn.rx.isEnabled).disposed(by: bag)
        
        self.backButton.rx.klrx_tap.drive(onNext:{ _ in
            if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.onStartConfirmWithdrawal.drive(onNext: {
            [unowned self] info in
            
            self.start(withInfo:info)
        })
            .disposed(by: bag)
        
        viewModel.onFindingUnableToTransferResult.drive(onNext: {
            [unowned self] err in
            self.showSimplePopUp(
                with: "",
                contents: err.localizedFailedDesciption,
                cancelTitle: LM.dls.g_confirm,
                cancelHandler: nil
            )
        })
            .disposed(by: bag)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!

    
    @objc private func toQRCode() {
        let asset = viewModel.input.asset
        let mainCoinID = self.purpose == .btcnWithdrawal ? Coin.btc_identifier : asset.wallet!.walletMainCoinID!
        
        let vc = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .withdrawal(mainCoinID),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .address(let addr, chainType: _, coin:  _, amt: _):
                        // Ensure the source qrcode is from the same chain
                        
                        self.addressVC.viewModel.changeToAddress(addr)
                        self.navigationController?
                            .presentedViewController?
                            .dismiss(animated: true, completion: nil)
                        
                    default: break
                    }
                },
                isTypeLocked: true
            )
        )
        
        present(vc, animated: true, completion: nil)
    }
    
    private func toAddressbookList() {
        let nav = AddressBookViewController.navInstance(from: AddressBookViewController.Config(
            identity: Identity.singleton!,
            purpose: .select(
            targetMainCoinID: self.purpose == .ifrcTransfer ? viewModel.input.asset.wallet!.walletMainCoinID : Coin.btc_identifier
            )
            )
        )
        
        if let vc = nav.viewControllers[0] as? AddressBookViewController  {
            vc.onSelect.subscribe(onNext: {
                [unowned self] unit in
                nav.dismiss(animated: true, completion: nil)
                self.addressVC.viewModel.changeToAddress(unit.address!)
            })
                .disposed(by: bag)
        }
        present(nav, animated: true, completion: nil)
    }

    func start(withInfo info:WithdrawalInfo) {
        self.askPwdBeforTransfer().subscribe(onSuccess: { (status) in
            if status {
                if self.purpose == .btcnWithdrawal {
                    self.startBTCNWithdrawal(info: info).bind(onNext: self.handleTransferState).disposed(by: self.bag)
                }else {
                    self.startTransfer(info: info).bind(onNext: self.handleTransferState).disposed(by: self.bag)
                }

            }
        }).disposed(by: bag)
    }
    
    func askPwdBeforTransfer() -> Single<Bool>{
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.withdrawal_title(self.viewModel.input.asset.coin!.inAppName!),
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
                tf.set(placeholder:dls.qrCodeImport_alert_placeholder_pwd(self.viewModel.input.asset.wallet?.pwdHint ?? "") )
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

    private func handleTransferState(_ state: LightTransferFlowState) {
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
            case .success(_):
                hud.updateType(.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")), text: dls.g_success)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                   
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.hud.stopAnimating()
                }
            }
        }
    }
    
    private func startTransfer(info : WithdrawalInfo) -> Observable<LightTransferFlowState> {
        //TODO: Complete with two concated observable, signing and broadcasting
        return Observable.create({ (observer) -> Disposable in
            LightTransferManager.manager.startTTNTransfer(fromInfo: info, progressObserver: observer,isWithdrawal: false)
            return Disposables.create()
        })
    }
    
    private func startBTCNWithdrawal(info: WithdrawalInfo) -> Observable<LightTransferFlowState> {
        
        return Observable.create({ (observer) -> Disposable in
            LightTransferManager.manager.startTTNTransfer(fromInfo: info, progressObserver: observer,isWithdrawal: true)
            return Disposables.create()
        })
    }
    
    
}

