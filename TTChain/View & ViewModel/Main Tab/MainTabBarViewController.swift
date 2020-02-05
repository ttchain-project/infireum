//
//  MainTabBarViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/23.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftMoment

class MainTabBarViewController: UITabBarController, RxThemeRespondable, RxLangRespondable, Rx {

    var bag: DisposeBag = DisposeBag.init()
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()

    //MARK: - Wallet
    private weak var walletNav: UINavigationController?
    private var walletVC: MainWalletViewController? {
        return walletNav?.viewControllers[0] as? MainWalletViewController
    }
    
    public func toWallet() {
        self.tabBarController?.present(walletNav!, animated: true, completion: nil)
    }

    private var walletOptionNav: UINavigationController?
    private var walletOptionVC: WalletsContainerViewController? {
        return walletOptionNav?.viewControllers[0] as? WalletsContainerViewController
    }

    private lazy var walletItem: UITabBarItem = {
        let item = UITabBarItem.init(title: LM.dls.tab_wallet, image: #imageLiteral(resourceName: "wallet1").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "wallet2").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        return item
    }()

    //MARK:- Trade
    private weak var tradeNav: UINavigationController?
    private var tradeVC: LightTransMenuViewController? {
        return tradeNav?.viewControllers[0] as? LightTransMenuViewController
    }
    private lazy var tradeItem: UITabBarItem = {
        let item = UITabBarItem.init(title: "", image: #imageLiteral(resourceName: "tt_tab_icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "tt_tab_icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        return item
    }()

    private var tradeButton: UIButton!
    
    
    //MARK: = Chat
    private weak var chatNav: UINavigationController?
    private var chatVC: ChatContainerViewController? {
        return chatNav?.viewControllers[0] as? ChatContainerViewController
    }

    private lazy var chatItem: UITabBarItem = {
        let item = UITabBarItem.init(title: LM.dls.tab_chat, image: #imageLiteral(resourceName: "chat1").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "chat2").withRenderingMode(UIImageRenderingMode.alwaysOriginal))

        return item
    }()

    //MARK: = Explorer
    private weak var exploreNav: UINavigationController?
    private weak var exploreVC: ExploreViewController? {
        return exploreNav?.viewControllers[0] as? ExploreViewController
    }
    private lazy var exploreItem: UITabBarItem = {
        let item = UITabBarItem.init(title: LM.dls.tab_explorer, image: #imageLiteral(resourceName: "find1").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "find2").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        return item
    }()
    
    
    //MARK: = Setting
    private weak var settingNav: UINavigationController?
    private weak var settingVC: SettingMenuViewController? {
        return settingNav?.viewControllers[0] as? SettingMenuViewController
    }
    private lazy var settingItem: UITabBarItem = {
        let item = UITabBarItem.init(title: LM.dls.tab_setting, image: #imageLiteral(resourceName: "setup1").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "setup2").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        return item
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        let tradeNav: UINavigationController = LightTransMenuViewController.navInstance(from: LightTransMenuViewController.Config())
        let exploreNav: UINavigationController = ExploreViewController.navInstance()
        let walletOptionsNav = WalletsContainerViewController.navInstance()

        let chatNav = ChatContainerViewController.navInstance(from: ())
        let settingsNav = SettingMenuViewController.navInstance()

        walletOptionsNav.viewControllers[0].tabBarItem = walletItem
        tradeNav.viewControllers[0].tabBarItem = tradeItem
        exploreNav.viewControllers[0].tabBarItem = exploreItem

        chatNav.viewControllers[0].tabBarItem = chatItem
        settingsNav.viewControllers[0].tabBarItem = settingItem

        self.walletOptionNav = walletOptionsNav
        self.chatNav = chatNav

        self.tradeNav = tradeNav
        self.exploreNav = exploreNav
        self.settingNav = settingsNav
        viewControllers = [
            walletOptionsNav,
//            chatNav,
//            tradeNav,
            exploreNav,
            settingsNav
        ]

        observeChatNotificationTapped()

        self.tabBar.barTintColor = UIColor.white
        self.view.backgroundColor = .owCharcoalGrey

        monitorLang { [unowned self] (lang) in
            let dls = lang.dls
            self.walletItem.title = dls.tab_wallet
            self.chatItem.title = dls.tab_chat
            self.exploreItem.title = dls.tab_explorer
            self.settingItem.title = dls.tab_setting
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func addTTICon() {
        tradeButton = UIButton.init(type: .custom)
        tradeButton.setImageForAllStates(#imageLiteral(resourceName: "ttn_icon_white"))
        tradeButton.set(backgroundColor: #colorLiteral(red: 1, green: 0.7882352941, blue: 0.4196078431, alpha: 1))

        tradeButton.sizeToFit()
        tradeButton.translatesAutoresizingMaskIntoConstraints = false
        tradeButton.rx.klrx_tap.asDriver().drive(onNext: { [unowned self] _ in
            if self.selectedIndex != 2 {
                self.selectedIndex = 2
            }
        }).disposed(by: bag)

        self.tabBar.addSubview(self.tradeButton)
        tradeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)

        tradeButton.heightAnchor.constraint(equalTo: tradeButton.widthAnchor, multiplier: 1.0 / 1.0).isActive = true

        tabBar.centerXAnchor.constraint(equalTo: tradeButton.centerXAnchor).isActive = true
        let top = tabBar.topAnchor.constraint(equalTo: tradeButton.centerYAnchor)
        top.constant = -10
        top.isActive = true
        tradeButton.widthAnchor.constraint(equalToConstant: 52).isActive = true
        tradeButton.adjustsImageWhenHighlighted = false
        self.tabBar.bringSubview(toFront: self.tradeButton)
    }

    func checkForTTNWallet() {
        let predForTTN = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.ttn.rawValue))
        
        if (DB.instance.get(type: Wallet.self, predicate: predForTTN, sorts: nil)?.first) != nil {
            return
        } else {
            self.askPwdBeforTransfer().subscribe(onSuccess: { (pwd) in
                TTNWalletManager.setupTTNWallet(withPwd: pwd)
                OWRxNotificationCenter.instance.notifyTTNWalletCreated()
            }).disposed(by: bag)
        }
    }

    func askPwdBeforTransfer() -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.tab_alert_newSystemWallet_title,
                message: dls.tab_alert_newSystemWallet_content,
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
                    handler(.success(pwd))
                }
            }

            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder: LM.dls.tab_alert_placeholder_identityPwd)
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }

            alert.addAction(cancel)
            alert.addAction(confirm)
            self.selectedViewController?.present(alert, animated: true, completion: nil)

            return Disposables.create()
        }
    }

    private func observeChatNotificationTapped() {
        OWRxNotificationCenter.instance.notificationForChatTapped.subscribe(onNext: {
            config in
            guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            let chatVC = ChatViewController.navInstance(from: config)

            if var vc = rootVC.presentedViewController {
                if vc.isKind(of: UINavigationController.self) {
                    let nav: UINavigationController = vc as! UINavigationController
                    vc = nav.viewControllers[0]
                }
                vc.present(chatVC, animated: true, completion: nil)
            } else {
                rootVC.present(chatVC, animated: true, completion: nil)
            }
        }).disposed(by: bag)
    }

    private var systemWalletSyncedFlag: Bool = false
    private var systemWalletSyncHandler: SystemMainWalletSyncHandler?

    private var flow: IdentityQRCodeEncryptionFlow?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard VersionChecker.sharedInstance.isVersionValid else {
            self.showAPIErrorResponsePopUp(from: GTServerAPIError.invalidVerision,
                cancelTitle: LM.dls.g_cancel)
            return
        }

//        if !systemWalletSyncedFlag {
//            attempSyncSystemWallets() {
//                [weak self] in
//                self?.displayAgreementIfNeeded()
//            }
//        } else {
//            displayAgreementIfNeeded()
//        }

//        checkForTTNWallet()

    }

    private func attempSyncSystemWallets(onComplete: @escaping () -> Void) {
        MainCoinTypStorage.onSynced
            .take(1)
            .subscribe(onNext: {
                [unowned self] in
                self.systemWalletSyncHandler = SystemMainWalletSyncHandler.init(config: SystemMainWalletSyncHandler.Config(presentingVC: self))

                self.systemWalletSyncHandler?.onFinish
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: {
                        [unowned self] in
                        onComplete()
                        self.systemWalletSyncHandler = nil
                    })
                    .disposed(by: self.bag)

                self.systemWalletSyncedFlag = true
            })
            .disposed(by: bag)

    }

    private func displayAgreementIfNeeded() {
        guard !AgreementViewController.displayFlagOfTheLaunch else {
            return
        }

        if let lastDisplayDate = AgreementViewController.lastDisplayDate {
            let now = moment().startOf(.Days)
            let last = moment(lastDisplayDate).startOf(.Days)
            if now.intervalSince(last).days < 1 {
                return
            }
        }

        let vc = xib(vc: AgreementViewController.self)
        let screen = UIScreen.main.bounds
        let width = screen.width - 40
        let height = screen.height * 0.7
        let form = vc.formSheetVC(
            size: CGSize.init(width: width,
                height: height)
        )

        present(form, animated: true, completion: nil)
        AgreementViewController.displayFlagOfTheLaunch = true
    }

}
