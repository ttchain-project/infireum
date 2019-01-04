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
    
    
    private weak var walletNav: UINavigationController?
    private var walletVC: MainWalletViewController? {
        return walletNav?.viewControllers[0] as? MainWalletViewController
    }
    
    private var walletOptionNav: UINavigationController?
    private var walletOptionVC: WalletOptionsViewController? {
        return walletOptionNav?.viewControllers[0] as? WalletOptionsViewController
    }
    

    private lazy var walletItem: UITabBarItem = {
        let item = UITabBarItem.init(title: "", image: #imageLiteral(resourceName: "WalletIcon"), selectedImage: #imageLiteral(resourceName: "WalletIconSelected").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        item.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0)

        return item
    }()
    
    private weak var tradeNav: UINavigationController?
    private var tradeVC: MainWalletViewController? {
        return tradeNav?.viewControllers[0] as? MainWalletViewController
    }
    
    private weak var chatNav: UINavigationController?
    private var chatVC: ChatListViewController? {
        return chatNav?.viewControllers[0] as? ChatListViewController
    }
    
    private lazy var chatItem: UITabBarItem = {
        let item = UITabBarItem.init(title: "", image: #imageLiteral(resourceName: "chatIcon"), selectedImage: #imageLiteral(resourceName: "chatIconSelected").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        item.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0)
        
        return item
    }()
    
//    ExploreViewController
    private weak var exploreNav: UINavigationController?
    private weak var exploreVC: ExploreViewController?{
        return exploreNav?.viewControllers[0] as? ExploreViewController
    }
    private lazy var exploreItem: UITabBarItem = {
            let item = UITabBarItem.init(title: "", image: #imageLiteral(resourceName: "profileIcon"), selectedImage: #imageLiteral(resourceName: "profileIconSelected").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        item.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0)
        return item
    }()
    
    private lazy var tradeItem: UITabBarItem = {
        let item = UITabBarItem.init(title: "", image: #imageLiteral(resourceName: "lightningTransactionIcon"), selectedImage: #imageLiteral(resourceName: "lightningTransactionIconSelected").withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        item.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0)
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //        let walletNav = MainWalletViewController.navInstance()
        let configForMainWallet = MainWalletViewController.Config.init(entryPoint: .MainTab, wallet: WalletFinder.getWallet(), source:.ETH)
        let tradeNav: UINavigationController = MainWalletViewController.navInstance(from: configForMainWallet)
//        let meVC: MeViewController = MeViewController.instance()
        let exploreNav : UINavigationController = ExploreViewController.navInstance()
        let walletOptionsNav = WalletOptionsViewController.navInstance()
        let chatNav = ChatListViewController.navInstance(from: ())
        
        
        walletOptionsNav.viewControllers[0].tabBarItem = walletItem
        tradeNav.viewControllers[0].tabBarItem = tradeItem
//        meVC.tabBarItem = meItem
                exploreNav.tabBarItem = exploreItem
        chatNav.viewControllers[0].tabBarItem = chatItem
        
        
        self.walletOptionNav = walletOptionsNav
        self.chatNav = chatNav
        
        self.tradeNav = tradeNav
//        self.meVC = meVC
        self.exploreNav = exploreNav
        //        viewControllers = [walletNav, tradeNav, meVC]
        //        viewControllers = [meVC]
        viewControllers = [
            walletOptionsNav,
            tradeNav,
            chatNav,
            exploreNav
        ]
        
        //        monitorLang { [unowned self] (lang) in
        //            let dls = lang.dls
        //            self.walletItem.title = dls.tab_wallet
        //            self.tradeItem.title = dls.tab_trade
        //            self.meItem.title = dls.tab_me
        //        }
        
        //        monitorTheme { [unowned self] (theme) in
        //            self.tabBar.unselectedItemTintColor = theme.palette.tab_unselected
        //            self.tabBar.tintColor = theme.palette.tab_selected
        //        }
        //        observeLightningSwitchWithCoin()
        self.tabBar.backgroundImage = UIImage.init(named: "tabBarBackgroundImage")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch)
        self.view.backgroundColor = .owCharcoalGrey
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Notification
//    private func observeLightningSwitchWithCoin() {
//        OWRxNotificationCenter
//            .instance
//            .onLightningTradeSwitchWithCoin
//            .subscribe(
//                onNext: {
//                [unowned self, trade = self.tradeVC] coin in
//                    self.selectedIndex = 1
//                    trade?.changeFromCoin(coin)
//            })
//            .disposed(by: bag)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private var systemWalletSyncedFlag: Bool = false
    private var systemWalletSyncHandler : SystemMainWalletSyncHandler?
    
    private var flow: IdentityQRCodeEncryptionFlow?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        #if DEBUG
//        if flow == nil,
//            let id = Identity.singleton {
//            flow = IdentityQRCodeEncryptionFlow.start(
//                launchType: .create,
//                identity: id,
//                onViewController: self) { [weak self] (result) in
//                    print("Get result: \(result)")
//                    self?.flow = nil
//            }
//        }
//
//        return
//        #endif
        
        guard VersionChecker.sharedInstance.isVersionValid else {
            self.showAPIErrorResponsePopUp(from: GTServerAPIError.invalidVerision,
                                           cancelTitle: LM.dls.g_cancel)
            return
        }
        
        if !systemWalletSyncedFlag {
            attempSyncSystemWallets() {
                [weak self] in
                self?.displayAgreementIfNeeded()
            }
        }else {
            displayAgreementIfNeeded()
        }
    }
    
    private func attempSyncSystemWallets(onComplete: @escaping () -> Void) {
        //onSynced will send an event as the sync from remote is finished or it will instantly send event if has been finished.
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
                
                self.systemWalletSyncHandler?.startSyncMainWalletIfNeeded()
                self.systemWalletSyncedFlag = true
            })
            .disposed(by: bag)
        
    }
    
    private func displayAgreementIfNeeded() {
        guard !AgreementViewController.displayFlagOfTheLaunch else {
            return
        }
        
        if let lastDisplayDate =  AgreementViewController.lastDisplayDate {
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
