//
//  DepositViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/24.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DepositViewController: KLModuleViewController, KLVMVC{
    
    struct Setup {
        let wallet: Wallet
        let asset: Asset
    }
    
    typealias Constructor = Setup
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias ViewModel = DepositViewModel
    var viewModel: DepositViewModel!
    
    
    @IBOutlet weak var shareQRCodeButton: UIButton!
    @IBOutlet weak var qrCodeBorderImageVew: UIImageView!
    //    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var headerView: UIView!
//    fileprivate lazy var gradient: CAGradientLayer = {
//        let layer = CAGradientLayer.init()
//
//        headerView.layer.insertSublayer(layer, at: 0)
//        return layer
//    }()
    
//    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var walletAddressCopyBtn: UIButton!
    @IBOutlet weak var qrCodeImgView: UIImageView!
    
    /// Use to control visibility of change asset btn and sepline
//    @IBOutlet weak var qrCodeToBottom: NSLayoutConstraint!
//    @IBOutlet weak var qrCodeToSepline: NSLayoutConstraint!
    
//    @IBOutlet weak var qrCodeTitleLabel: UILabel!
    
//    @IBOutlet weak var sepline: UIView!
    @IBOutlet weak var changeAssetBtn: UIButton!
    
    fileprivate var isSelectingAsset: Bool = false
    fileprivate lazy var mask: UIView = {
        let v = UIView.init(frame: UIScreen.main.bounds)
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.isHidden = true
        navigationController!.view.insertSubview(v, belowSubview: changeAssetVC.view)
        return v
    }()
    
    fileprivate lazy var changeAssetVC: ChangeAssetViewController! = {
        let vc = ChangeAssetViewController.instance(from: ChangeAssetViewController.Config(
            wallet: wallet,
            selectedCoin: defaultAsset.coin!
            )
        )
        
        vc.onAssetSelect.drive(onNext: {
            [unowned self] _ in
            self.hideAssetChooseVC(animated: true)
        })
        .disposed(by: bag)
        
        vc.view.frame = assetVCHiddenFrame
        
//        vc.willMove(toParentViewController: self.navigationController!)
//        self.navigationController!.addChildViewController(vc)
        navigationController!.view.addSubview(vc.view)
//        vc.didMove(toParentViewController: self.navigationController!)
        
        return vc
    }()
    
    fileprivate var wallet: Wallet!
    fileprivate var defaultAsset: Asset!
    func config(constructor: DepositViewController.Setup) {
        self.wallet = constructor.wallet
        self.defaultAsset = constructor.asset
        
        view.layoutIfNeeded()
        let changeable = (constructor.wallet.chainType != ChainType.btc.rawValue)
        switchLayoutOnAssetChangeable(changeable)
        
        viewModel = ViewModel.init(
            input: DepositViewModel.InputSource(
                wallet: constructor.wallet,
                asset: constructor.asset,
                selectAssetInput: changeAssetVC.onAssetSelect
            ),
            output: ()
        )
        
        setupWallet(constructor.wallet)
        bindViewModel()
        bindLayer()
        bindChangeAssetDisplay()
        
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func setupWallet(_ wallet: Wallet) {
        
        self.navigationItem.title = wallet.mainCoin?.chainName
       
        walletAddressLabel.text = wallet.address

        
        
        let theme = TM.instance.theme.value
        
        changeAssetBtn.set(
            color: mainColor(ofMainCoinID: wallet.walletMainCoinID!, inTheme: theme),
            font: UIFont.owMedium(size: 18),
            image: #imageLiteral(resourceName: "btnChangeAssetsNormal")
        )
        
        walletAddressCopyBtn.rx.tap
            .asDriver()
            .throttle(1)
            .drive(onNext: {
                [unowned self] in
                self.copyAddress(address: wallet.address!)
            })
            .disposed(by: bag)
        
    }
    
    private func bindViewModel() {
        viewModel.qrCode.bind(to: qrCodeImgView.rx.image).disposed(by: bag)
        viewModel.selectedAsset
            .map {
                LM.dls.deposit_label_depositAddress($0.coin!.inAppName!)
            }
            .bind(to: coinNameLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func bindChangeAssetDisplay() {
        changeAssetVC.onCancel.drive(onNext: {
            [unowned self] in self.hideAssetChooseVC(animated: true)
        })
        .disposed(by: bag)
        
        changeAssetBtn.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self]
                _ in
                if !self.isSelectingAsset {
                    self.showAssetChooseVC(animated: true)
                }
            })
            .disposed(by: bag)
        
        viewModel.input.selectAssetInput.drive(onNext: {
            [unowned self]
            _ in
            if self.isSelectingAsset {
                self.hideAssetChooseVC(animated: true)
            }
        })
        .disposed(by: bag)
    }
    
    private func bindLayer() {
//        headerView.rx.observe(CGRect.self, "bounds").filter { $0 != nil }.map { $0! }
//            .subscribe(onNext: {
//                [unowned self]
//                bs in
//                self.gradient.frame = bs
//            })
//            .disposed(by: bag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        changeAssetBtn.setTitleForAllStates(dls.deposit_btn_changeAsset)
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_2, barTint: theme.palette.nav_bar_tint)
        renderNavTitle(color: theme.palette.nav_item_2, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor:theme.palette.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
//        createRightBarButton(target: self, selector: #selector(settingsButton), image: #imageLiteral(resourceName: "settings"), title: nil, toColor: theme.palette.nav_item_2, shouldClear: true)
        
//        view.backgroundColor = theme.palette.specific(color: .owMarineBlue)
//        walletAddressCopyBtn.tintColor = theme.palette.label_main_2
        
//        walletNameLabel.set(
//            textColor: theme.palette.label_main_2,
//            font: .owMedium(size: 16.3)
//        )
        
        createRightBarButton(target: self, selector: #selector(startSharing), image: #imageLiteral(resourceName: "btnNavShareNormal"), title: nil, toColor: theme.palette.nav_item_2, shouldClear: true)

        walletAddressLabel.set(
            textColor: theme.palette.label_main_1,
            font: .owRegular(size: 14)
        )
        
//        sepline.backgroundColor = theme.palette.sepline
//        contentView.backgroundColor = theme.palette.bgView_main
        
        if let vm = viewModel {
            let mainCoinID = vm.input.wallet.walletMainCoinID!
            renderGradient(ofMainCoinID: mainCoinID, inTheme: theme)
//            qrCodeTitleLabel.set(
//                textColor: mainColor(ofMainCoinID: mainCoinID, inTheme: theme),
//                font: .owMedium(size: 18)
//            )
            changeAssetBtn.set(
                textColor: mainColor(ofMainCoinID: mainCoinID, inTheme: theme),
                font: UIFont.owMedium(size: 18)
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func copyAddress(address: String) {
        UIPasteboard.general.string = address
        view.makeToast(LM.dls.g_toast_addr_copied)
    }
    
    @objc private func startSharing() {
        let img = screenshot()
        let activityVC = UIActivityViewController.init(activityItems: [img], applicationActivities: nil)

        present(activityVC, animated: true, completion: nil)
    }
    
    //MARK: - Helper
    private func mainColor(ofMainCoinID mainCoinID: String, inTheme theme: Theme) -> UIColor {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        switch coin.owChainType {
        case .eth:
            return theme.palette.wallet_1_gradient_to
        case .btc:
            return theme.palette.wallet_2_gradient_to
        case .cic:
            if mainCoinID == Coin.cic_identifier {
                return theme.palette.wallet_3_gradient_to
            }else if mainCoinID == Coin.guc_identifier {
                return theme.palette.specific(color: .owWindowsBlue)
            }else {
                return theme.palette.specific(color: .owWindowsBlue)
            }
        case .ttn:
            return theme.palette.wallet_3_gradient_to
        case .ifrc:
            return theme.palette.wallet_3_gradient_to
        }
    }
    
    private func renderGradient(ofMainCoinID mainCoinID: String, inTheme theme: Theme) {
//        gradient.startPoint = CGPoint.init(x: 1, y: 0.5)
//        gradient.endPoint = CGPoint.init(x: 0, y: 0.5)
//        gradient.colors = gradientColors(ofMainCoinID: mainCoinID, inTheme: theme)
    }
    
    private func gradientColors(ofMainCoinID mainCoinID: String, inTheme theme: Theme) -> [CGColor] {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        switch coin.owChainType {
        case .eth:
            return [
                theme.palette.wallet_1_gradient_from.cgColor,
                theme.palette.wallet_1_gradient_to.cgColor
            ]
        case .btc:
            return [
                theme.palette.wallet_2_gradient_from.cgColor,
                theme.palette.wallet_2_gradient_to.cgColor
            ]
        case .cic:
            if mainCoinID == Coin.cic_identifier {
                return [
                    theme.palette.wallet_3_gradient_from.cgColor,
                    theme.palette.wallet_3_gradient_to.cgColor
                ]
            }else if mainCoinID == Coin.guc_identifier {
                return [
                    theme.palette.specific(color: .owWindowsBlue).cgColor,
                    theme.palette.specific(color: .owDarkSlateBlue).cgColor
                ]
            }else {
                return [
                    theme.palette.specific(color: .owWindowsBlue).cgColor,
                    theme.palette.specific(color: .owDarkSlateBlue).cgColor
                ]
            }
        case .ttn:
            return [
                theme.palette.wallet_3_gradient_from.cgColor,
                theme.palette.wallet_3_gradient_to.cgColor
            ]
        case .ifrc:
            return [
                theme.palette.wallet_3_gradient_from.cgColor,
                theme.palette.wallet_3_gradient_to.cgColor
            ]
        }
    }
    
    private func switchLayoutOnAssetChangeable(_ changeable: Bool) {
        if !changeable {
//            sepline.removeSubviews()
            changeAssetBtn.removeFromSuperview()
//            qrCodeToBottom.isActive = true
//            qrCodeToSepline.isActive = false
//        }else {
//            qrCodeToBottom.isActive = false
//            qrCodeToSepline.isActive = true
        }
    }
    
    private func screenshot() -> UIImage {
        UIGraphicsBeginImageContext(qrCodeBorderImageVew.size)
        qrCodeBorderImageVew.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }

}

//MARK: - Change Asset VC Animation
extension DepositViewController {
    
    fileprivate var assetVCDisplayFrame: CGRect {
        let bounds = UIScreen.main.bounds
        //This is a test value
        let ratio: CGFloat = 0.4
        let width = bounds.width
        let height = bounds.height * ratio
        let originY = bounds.height - height
        let originX: CGFloat = 0
        
        return CGRect.init(x: originX, y: originY, width: width, height: height)
    }
    
    fileprivate var assetVCHiddenFrame: CGRect {
        var frame = assetVCDisplayFrame
        frame.origin.y += frame.height
        
        return frame
    }
    
    fileprivate func showAssetChooseVC(animated: Bool) {
        mask.isHidden = false
//        mask.frame = UIScreen.main.bounds
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.changeAssetVC.view.frame = self.assetVCDisplayFrame
            }) { (_) in
                self.isSelectingAsset = true
            }
        }else {
            self.changeAssetVC.view.frame = self.assetVCDisplayFrame
        }
    }
    
    fileprivate func hideAssetChooseVC(animated: Bool) {
        mask.isHidden = true
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.changeAssetVC.view.frame = self.assetVCHiddenFrame
            }) { (_) in
                self.isSelectingAsset = false
            }
        }else {
            self.changeAssetVC.view.frame = self.assetVCHiddenFrame
        }
    }
}
