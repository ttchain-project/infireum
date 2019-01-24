//
//  WithdrawalBaseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import Cartography

final class WithdrawalBaseViewController: KLModuleViewController, KLVMVC {
    struct Config {
        let asset: Asset
        let defaultToAddress: String?
    }
    
    typealias Constructor = Config
    func config(constructor: WithdrawalBaseViewController.Config) {
        view.layoutIfNeeded()
        configChildViewControllers(config: constructor)
        viewModel = ViewModel.init(
            input: WithdrawalBaseViewModel.InputSource(
                asset: constructor.asset,
                amtProvider: assetVC.viewModel,
                addressProvider: addressVC.viewModel,
                feeProvider: feeInfoProvider,
                getWithdrawalResultInput: nextStepBtn.rx.tap.asDriver(), note: remarkNoteVC.viewModel
            ),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        bindUI()
        bindViewModel()
    }
    
    typealias ViewModel = WithdrawalBaseViewModel
    var viewModel: WithdrawalBaseViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var baseScrollView: UIScrollView!
    @IBOutlet weak var nextStepBtn: UIButton!
//    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var scanButton: UIButton!
//    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK: Child View Controllers
    private var assetVC: WithdrawalAssetViewController!
    private var addressVC: WithdrawalAddressViewController!
    private var feeVC: UIViewController!
    private var remarkNoteVC : WithdrawalRemarksViewController!
    private var feeInfoProvider: WithdrawalFeeInfoProvider {
        if let btcFee = feeVC as? WithdrawalBTCFeeInputViewController {
            return btcFee.viewModel
        }else if let ethFee = feeVC as? WithdrawalETHFeeInputViewController {
            return ethFee.viewModel
        }else {
            fatalError()
        }
    }
    
    private func configChildViewControllers(config: Config) {
        let fiat = Identity.singleton!.fiat!
        assetVC = WithdrawalAssetViewController.instance(from: WithdrawalAssetViewController.Config(asset: config.asset, fiat: fiat))
        addChildViewController(assetVC)
        assetVC.didMove(toParentViewController: self)
        baseScrollView.addSubview(assetVC.view)
        
        constrain(assetVC.view, baseScrollView) { [unowned self] (view, scroll) in
            view.top == scroll.top + 25
            view.leading == scroll.leading
            view.trailing == scroll.trailing
            view.width == scroll.width
            let height = self.assetVC.preferedHeight
            view.height == height
        }
        
        addressVC = WithdrawalAddressViewController.instance(from: WithdrawalAddressViewController.Config(asset: config.asset))
        addChildViewController(addressVC)
        addressVC.didMove(toParentViewController: self)
        baseScrollView.addSubview(addressVC.view)
        
        constrain(addressVC.view, assetVC.view, baseScrollView) { [unowned self] (addr, asset, scroll) in
            addr.leading == asset.leading
            addr.trailing == asset.trailing
            addr.top == asset.bottom + 12
            let height = self.addressVC.preferedHeight
            addr.height == height
        }
        
        if let defaultAddress = config.defaultToAddress {
            addressVC.viewModel.changeToAddress(defaultAddress)
        }
        
        addressVC.onTapChangeToAddress.drive(onNext: {
            [unowned self] in
            self.toAddressbookList()
        })
        .disposed(by: bag)
        
        addressVC.onTapChangeFromWallet.drive(onNext: {
            [unowned self] in
            self.toSelectWallet()
        })
            .disposed(by: bag)
        
        var isInfoDisplayed : Observable<Bool>
        
        let type = ChainType.init(rawValue: config.asset.wallet!.chainType)!
        switch type {
        case .btc:
            let feeVC = WithdrawalBTCFeeInputViewController.instance(from: WithdrawalBTCFeeInputViewController.Config(asset:config.asset))
            addChildViewController(feeVC)
            feeVC.didMove(toParentViewController: self)
            self.feeVC = feeVC
            isInfoDisplayed = feeVC.viewModel.isInfoDisplayed
            baseScrollView.addSubview(feeVC.view)
        case .eth:
            let feeVC = WithdrawalETHFeeInputViewController.instance(from: WithdrawalETHFeeInputViewController.Config(fiat: Identity.singleton!.fiat!)
            )
            addChildViewController(feeVC)
            feeVC.didMove(toParentViewController: self)
            self.feeVC = feeVC
            isInfoDisplayed = feeVC.viewModel.isInfoDisplayed
            baseScrollView.addSubview(feeVC.view)
//            return
        case .cic:
            //This shuold not happen
            return errorDebug(response: ())
        }
        
        remarkNoteVC = WithdrawalRemarksViewController.instance(from: WithdrawalRemarksViewController.Config())
        addChildViewController(remarkNoteVC)
        remarkNoteVC.didMove(toParentViewController: self)
        baseScrollView.addSubview(remarkNoteVC.view)

        constrain(feeVC.view, addressVC.view, baseScrollView) { (fee, addr, scroll) in
            fee.leading == addr.leading
            fee.trailing == addr.trailing
            fee.top == addr.bottom + 12
            let height = (feeVC as! WithdrawalChildVC).preferedHeight
            fee.height == height
            fee.bottom == scroll.bottom - self.remarkNoteVC.preferedHeight - 12 - 60
            
        }
        
         constrain(remarkNoteVC.view, addressVC.view, baseScrollView) { [unowned self] (remark, address, scroll) in
            remark.leading == address.leading
            remark.trailing == address.trailing
            remark.width == address.width
            let height = self.remarkNoteVC.preferedHeight
            remark.height == height
        }
        let group = constrain(remarkNoteVC.view, addressVC.view, baseScrollView) { [unowned self] (remark, address, scroll) in
            remark.top == address.bottom + 56 + 12
        }
        isInfoDisplayed.subscribe(onNext: {
            [weak self] (isDisplayed) in
            self?.updateContraintsForRemark(isDisplayed: isDisplayed, group: group)
        }).disposed(by: bag)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.withdrawal_title(viewModel.input.asset.coin!.inAppName!)
        nextStepBtn.setTitleForAllStates(dls.withdrawal_btn_nextstep)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
//        view.backgroundColor = palette.bgView_main
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bg_clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        createRightBarButton(target: self, selector: #selector(toQRCode), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), title: nil, toColor: palette.nav_item_2, shouldClear: true)

        guard self.navigationController != nil else {
            changeBackBarButton(toColor:palette.nav_item_2, image:  #imageLiteral(resourceName: "arrowNavBlack"))
            return
        }
        changeLeftBarButtonToDismissToRoot(tintColor:palette.nav_item_2, image:  #imageLiteral(resourceName: "arrowNavBlack"))

//        if((self.presentingViewController) != nil) {
//        } else if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
//        }
        
//        self.backButton.rx.tap.bind {
//            self.navigationController?.popViewController(animated: true)
//            }.disposed(by: bag)
//
//        self.scanButton.rx.tap.bind {
//            self.toQRCode()
//        }.disposed(by: bag)
        
        nextStepBtn.setTitleColor(palette.btn_bgFill_enable_text, for: .normal)
        nextStepBtn.setTitleColor(palette.btn_bgFill_disable_text, for: .disabled)
        nextStepBtn.set(font: UIFont.owRegular(size: 14))
    }
    
    private func bindUI() {
        viewModel.isAbleToStartTransfer.subscribe(onNext: {
            [unowned self]
            isEnabled in
            let palette = TM.palette
            self.nextStepBtn.backgroundColor = isEnabled ? palette.btn_bgFill_enable_bg : palette.btn_bgFill_disable_bg
        })
        .disposed(by: bag)
        
        viewModel.isAbleToStartTransfer.bind(to: nextStepBtn.rx.isEnabled).disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.onStartConfirmWithdrawal.drive(onNext: {
                [unowned self] info in
                self.startConfirmWithWithdrawalInfo(info)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Route
    @objc private func toQRCode() {
        let asset = viewModel.input.asset
        let mainCoinID = asset.wallet!.walletMainCoinID!
        let vc = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .withdrawal(mainCoinID),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .address(let addr, chainType: _, coin: let coin, amt: _):
                        // Ensure the source qrcode is from the same chain
                        if let detectedCoin = coin {
                            guard detectedCoin.walletMainCoinID == asset.coin!.walletMainCoinID else {
                                return 
                            }
                        }
                        
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
                    targetMainCoinID: viewModel.input.asset.wallet!.walletMainCoinID
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

    private func toSelectWallet() {
        //TODO: Instance should has chainType, and asset type input to filtered out unwanted wallets.
        let vc = ChangeWalletViewController.instance(from: ChangeWalletViewController.Constructor(assetSupportLimit: viewModel.input.asset)
        )
        vc.onWalletSelect.take(1).subscribe(onNext: {
            [unowned self]
            wallet in
            vc.dismissRoot(sender: nil)
            if let assets = wallet.assets?.array as? [Asset] {
                let targetID = self.viewModel.input.asset.coinID!
                let targetAsset: Asset
                
                if let idx = assets.index(where: { $0.coinID! == targetID }) {
                    targetAsset = assets[idx]
                }else {
                    //if no cuurent asset found in the wallet, create a new one, with unselected state
                    guard let newAsset = wallet.createNewAsset(ofCoin: self.viewModel.input.asset.coin!) else {
                        return errorDebug(response: ())
                    }
                    
                    targetAsset = newAsset
                }
                
                self.viewModel.input.addressProvider.changeFromAsset(targetAsset)
            }
        })
        .disposed(by: bag)
        
        
        present(vc, animated: true, completion: nil)
    }

    let animator = KLTransferConfirmAnimator.init(topRevealPercentage: 0.4)
    private func startConfirmWithWithdrawalInfo(_ info: WithdrawalInfo) {
        let chainType = ChainType.init(rawValue: info.wallet.chainType)!
        switch chainType {
        case .btc:
            let nav = WithdrawalBTCInfoOverviewViewController.navInstance(from: WithdrawalBTCInfoOverviewViewController.Config(info: info))
            nav.transitioningDelegate = animator
            
            present(nav, animated: true, completion: nil)
        case .eth:
            let nav = WithdrawalETHInfoOverviewViewController.navInstance(from: WithdrawalETHInfoOverviewViewController.Config(info: info))
            nav.transitioningDelegate = animator
            
            present(nav, animated: true, completion: nil)
        case .cic:
            //THIS SHUOLD NOT HAPPEN
            return errorDebug(response: ())
        }
    }
}
