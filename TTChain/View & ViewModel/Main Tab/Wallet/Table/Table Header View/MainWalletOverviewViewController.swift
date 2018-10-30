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
        let ratio: CGFloat = 250/375
        let min: CGFloat = 200
        return CGSize.init(width: screenWidth, height: max(min, screenWidth * ratio))
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
            walletAddressLabel.text = wallet.address
            walletColorImg.image = self.img(ofMainCoinID: wallet.walletMainCoinID!)
            manageAssetBtn.isEnabled = (wallet.owChainType != .btc)
        }
    }
    
    private var total: Decimal? {
        didSet {
            if let f = fiat {
                let symbol = f.fullSymbol
                DispatchQueue.main.async {
                    if let t = self.total {
                        self.totalFiatValueLabel.text = symbol + t.asString(digits: 2).disguiseIfNeeded()
                    }else {
                        self.totalFiatValueLabel.text = symbol + "--"
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
                    if let t = self.total {
                        self.totalFiatValueLabel.text = symbol + t.asString(digits: 2, force: true).disguiseIfNeeded()
                    }else {
                        self.totalFiatValueLabel.text = symbol + "--"
                    }
                }
            }
        }
    }
    private(set) lazy var onDeposit: Driver<Wallet> = {
        return depositBtn.rx.tap.asDriver().map {
            [unowned self] in self.wallet
        }
    }()
    
    private(set) lazy var onManageAsset: Driver<Wallet> = {
        return manageAssetBtn.rx.tap.asDriver()
            .filter {
                [unowned self] in
                return ChainType.init(rawValue: self.wallet.chainType) != .btc
            }
            .map {
                [unowned self] in self.wallet
            }
    }()
    private(set) lazy var onAddressCopied: Driver<String> = {
        
        return Driver.merge(
            walletNameLabel.rx.tapGesture().skip(1).map { _ in () }.asDriver(onErrorJustReturn: ()),
            walletCopyBtn.rx.tap.asDriver()
        ).map {
                [unowned self] _ -> String in
                self.copyAddress()
                return self.wallet.address!
        }
    
    }()
    
    private(set) var onSwitchWallet: Driver<Void>!
    
    @IBOutlet weak var mainBG: UIView!
    @IBOutlet weak var walletBase: UIView!
    @IBOutlet weak var walletColorImg: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var walletCopyBtn: UIButton!
    @IBOutlet weak var totalFiatValueLabel: UILabel!
    @IBOutlet weak var depositBtn: UIButton!
    @IBOutlet weak var manageAssetBtn: UIButton!
    @IBOutlet weak var switchWalletBtn: UIButton!
    
    
    
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
        bindWalletSwitchEvent()
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
        let renderShadow: (UIButton) -> Void = {
            btn in
            btn.shadowColor = UIColor.init(white: 203.0/256.0, alpha: 0.5)
            btn.shadowOffset = CGSize.init(width: 2, height: 2)
            btn.shadowRadius = 0
            btn.shadowOpacity = 1
            btn.backgroundColor = .white
        }
        
        renderShadow(depositBtn)
        renderShadow(manageAssetBtn)
        
        walletCopyBtn.setImageForAllStates(#imageLiteral(resourceName: "btnListCopyNormal"))
        walletCopyBtn.setTitle(nil, for: .normal)
//        walletColorImg.clipsToBounds = false
        walletColorImg.addShadow(ofColor: UIColor.init(red: 31,
                                                       green: 49,
                                                       blue: 74)!
                                                 .withAlphaComponent(0.12),
                                 radius: 2,
                                 offset: CGSize.init(width: 0, height: 2),
                                 opacity: 1)
        
        walletBase.addShadow(ofColor: UIColor.init(red: 31,
                                                   green: 49,
                                                   blue: 74)!
                                              .withAlphaComponent(0.12),
                             radius: 2,
                             offset: CGSize.init(width: 0, height: 2),
                             opacity: 1)
    }
    
    private func bindWalletSwitchEvent() {
        onSwitchWallet = switchWalletBtn.rx.tap.asDriver()
    }
    
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
        depositBtn.setTitleForAllStates(dls.walletOverview_btn_deposit)
        manageAssetBtn.setTitleForAllStates(dls.walletOverview_btn_manageAsset)
        
        switchWalletBtn.setTitleForAllStates(dls.walletOverview_btn_switchWallet)
    }
    
    override func renderTheme(_ theme: Theme) {
        view.backgroundColor = theme.palette.bgView_sub
        mainBG.backgroundColor = theme.palette.bgView_main
        
        walletNameLabel.set(textColor: theme.palette.label_main_2, font: .owMedium(size: 16.3))
        walletAddressLabel.set(textColor: theme.palette.label_main_2, font: .owRegular(size: 12))
        totalFiatValueLabel.set(textColor: theme.palette.label_main_2, font: .owMedium(size: 21.7))
        
        walletBase.set(borderInfo: (color: theme.palette.bgView_border, width: 1))
        walletCopyBtn.set(color: theme.palette.label_main_2)
        
        depositBtn.set(
            color: theme.palette.btn_borderFill_enable_text,
            font: UIFont.owRegular(size: 12.7),
            borderInfo: (color: theme.palette.btn_borderFill_border_2nd, width: 1)
        )
        
        manageAssetBtn.set(
            color: theme.palette.btn_borderFill_enable_text,
            font: UIFont.owRegular(size: 12.7),
            borderInfo: (color: theme.palette.btn_borderFill_border_2nd, width: 1)
        )
        
        switchWalletBtn.set(
            color: theme.palette.specific(color: .owWhite),
            font: UIFont.owRegular(size: 12.7),
            borderInfo: (color: theme.palette.specific(color: .owWhite), width: 1)
        )
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
