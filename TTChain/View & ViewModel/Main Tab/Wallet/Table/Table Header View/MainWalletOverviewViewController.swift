//
//  MainWalletOverviewViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class MainWalletOverviewViewController: KLModuleViewController {
    
    static var prefSize: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let ratio: CGFloat = 0.25 * UIScreen.main.bounds.height
        let min: CGFloat = 200
        return CGSize.init(width: screenWidth, height: max(min, ratio))
        
//        return CGSize.init(width: screenWidth, height: 320)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.view.frame = CGRect.init(origin: .zero, size: MainWalletOverviewViewController.prefSize)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.frame = CGRect.init(origin: .zero, size: MainWalletOverviewViewController.prefSize)
    }
    
    private let bag = DisposeBag.init()
    
    private var wallet: Wallet! {
        didSet {
            walletNameLabel.text = wallet.name!
//            walletAddressLabel.text = wallet.address
//            walletColorImg.image = self.img(ofMainCoinID: wallet.walletMainCoinID!)
//            shareAddress.isEnabled = (wallet.owChainType != .btc)
        }
    }
    
    private var total: Decimal? {
        didSet {
            if let f = fiat {
                let symbol = f.fullSymbol
                DispatchQueue.main.async {
                    if let t = self.total {
                        self.totalFiatValueLabel.text = t.asString(digits: 2).disguiseIfNeeded()
                    }else {
                        self.totalFiatValueLabel.text = "--"
                    }
                }
            }
        }
    }
    
    
    private var fiat: Fiat! {
        didSet {
            if let f = fiat {
                let symbol = f.fullSymbol
                DispatchQueue.main.async {
                    self.fiatCurrencyLabel.text = symbol
                }
            }
        }
    }
    
//    private(set) lazy var onManageAsset: Driver<Wallet> = {
//        return shareAddress.rx.tap.asDriver()
//            .filter {
//                [unowned self] in
//                return ChainType.init(rawValue: self.wallet.chainType) != .btc
//            }
//            .map {
//                [unowned self] in self.wallet
//            }
//    }()
    
//    private (set) lazy var onTransactionHistory: Driver<Void> = {
//        return self.transactionRecordButton.rx.tap.asDriver()
//    }()
    
//    private(set) lazy var onAddressCopied: Driver<String> = {
    
//        return Driver.merge(
//            walletNameLabel.rx.tapGesture().skip(1).map { _ in () }.asDriver(onErrorJustReturn: ()),
////            walletCopyBtn.rx.tap.asDriver()
//        ).map {
//                [unowned self] _ -> String in
//                self.copyAddress()
//                return self.wallet.address!
//        }
//
//    }()
    
//    private(set) var onSwitchWallet: Driver<Void>!
    
//    @IBOutlet weak var mainBG: UIView!
//    @IBOutlet weak var walletBase: UIView!
//    @IBOutlet weak var walletColorImg: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
//    @IBOutlet weak var walletAddressLabel: UILabel!
//    @IBOutlet weak var walletCopyBtn: UIButton!
    @IBOutlet weak var totalFiatValueLabel: UILabel!
    @IBOutlet weak var fiatCurrencyLabel: UILabel!
//    @IBOutlet weak var manageLabel: UILabel!
//    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var mainChainTotlAssetLabel: UILabel!
    //    @IBOutlet weak var transactionRecordButton: UIButton!
//    @IBOutlet weak var shareAddress: UIButton!
//    @IBOutlet weak var switchWalletBtn: UIButton!
    @IBOutlet weak var manageAssetsButton: UIButton!
    
    
    
    static func instance(of wallet: Wallet, total: Decimal?, fiat: Fiat) -> MainWalletOverviewViewController {
        let vc = xib(vc: self)
        vc.config(of: wallet, total: total, fiat: fiat)
        return vc
    }
    
    private func config(of wallet: Wallet, total: Decimal?, fiat: Fiat) {
        view.layoutIfNeeded()
        
        self.wallet = wallet
        self.total = total
        self.fiat = fiat
        
        setupUI()
        
//        startMonitorNetworkStatusIfNeeded()
//        bindWalletSwitchEvent()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        observeWalletUpdateEvent()
        observPrivateModeUpdateEvent()
    }
    
    func update(wallet: Wallet, total: Decimal?, fiat: Fiat) {
        self.wallet = wallet
        self.total = total
        self.fiat = fiat
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        
        //        walletCopyBtn.setImageForAllStates(#imageLiteral(resourceName: "copyAddressButtonCircle"))
//        walletCopyBtn.setTitle(nil, for: .normal)
//        walletColorImg.clipsToBounds = false
//        walletColorImg.addShadow(ofColor: UIColor.init(red: 31,
//                                                       green: 49,
//                                                       blue: 74)!
//                                                 .withAlphaComponent(0.12),
//                                 radius: 2,
//                                 offset: CGSize.init(width: 0, height: 2),
//                                 opacity: 1)
        

        self.view.backgroundColor = UIColor.white
    }
    
//    private func bindWalletSwitchEvent() {
//        onSwitchWallet = switchWalletBtn.rx.tap.asDriver()
//    }
    
    private func observPrivateModeUpdateEvent() {
        OWRxNotificationCenter.instance
            .onChangePrivateMode
            .subscribe(onNext: { [unowned self] _ in
                //Force didSet called, will update the string.
                let t = self.total
                self.total = t
                let f = self.fiat
                self.fiat = f
            })
            .disposed(by: bag)
    }
    
    private func observeWalletUpdateEvent() {
        OWRxNotificationCenter.instance
            .walletNameUpdate
            .subscribe(onNext: { [unowned self] _ in
                self.wallet = self.wallet
            })
            .disposed(by: bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        self.manageAssetsButton.setTitle(dls.asset_management_btn_title, for: .normal)
        mainChainTotlAssetLabel.text = "\(self.wallet.mainCoin?.fullname ?? "") 主鏈總資產"
    }
    
    override func renderTheme(_ theme: Theme) {
//        view.backgroundColor = thesme.palette.bgView_sub
//        mainBG.backgroundColor = theme.palette.bgView_main
        
        walletNameLabel.set(textColor: theme.palette.label_sub, font: .owMedium(size: 12))
//        walletAddressLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 12))
        totalFiatValueLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 22))
        
        mainChainTotlAssetLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 12))
        manageAssetsButton.set(textColor: theme.palette.bg_fill_new, font: .owRegular(size: 14),  backgroundColor: .white)

        

        
    }
    
    private func copyAddress() {
        UIPasteboard.general.string = wallet.address!
    }
    
    private func img(ofMainCoinID mainCoinID: String) -> UIImage {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        switch coin.owChainType {
        case .btc:
            return #imageLiteral(resourceName: "bgBtcWalletColor")
        case .eth:
            return #imageLiteral(resourceName: "bgEthWalletColor")
        case .cic:
            if mainCoinID == Coin.cic_identifier {
                return #imageLiteral(resourceName: "bgCicWalletColor")
            }else if mainCoinID == Coin.guc_identifier {
                return #imageLiteral(resourceName: "bgGuCwalletColor")
            }else {
                return #imageLiteral(resourceName: "bgGuCwalletColor")
            }
        case .ttn:
            return #imageLiteral(resourceName: "bgBtcWalletColor")
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
