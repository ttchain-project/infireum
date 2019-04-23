//
//  AppDelegate.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import IQKeyboardManagerSwift
import RxCocoa
import Flurry_iOS_SDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bag: DisposeBag = DisposeBag.init()
    private let shouldResetInDebugMode: Bool = false
    
    /// Flag to check if there's an identity in the DB.
    private var hasLoggedIn: Bool {
        guard let ids = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil), !ids.isEmpty else {
            return false
        }
        
        guard ids.count == 1 else {
            return errorDebug(response: false)
        }
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //3rd part libs inits
        startKeyboardManaging()
        initalizeHockey()
        initializeFlurry()
        
        //This is for fixing bugs in the previous version, it's fine to comment out if this func cause any undesired side effects.
        inactiveGUCinETH()

        #if DEBUG
        DB.instance.debugWholeDatabaseCount()
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        #if DEBUG
        //Helpful if you want to reset the DB at the start of each new compilation.
        if shouldResetInDebugMode {
            DB.instance.drop()
            DB.instance.markUnconfiged()
        }
        #endif
    
        //Start to config the database with default settings. (if needed).
        configDBIfNeeded()
        
        //Start to config the fee rate in the app. (if needed)
        FeeManager.configIfNeeded()
        window?.rootViewController = xib(vc: LaunchViewController.self)
        
        //To let the gif show in the LaunchViewController display for 4 sec
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
            //Start to define the root vc for current status.
            if let dict = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
                // Launched from push notification
                self.start(launchOption: dict)
            }else {
                self.start()
            }
            
            //Start version checking flow, prohobit further using if found current version is below required version.
            self.versionChecker()
        }


        window?.makeKeyAndVisible()
        
        
        
        manageThemeUpdate()
        startObserveIdentityClearEvent()
        
        #if DEBUG
        DB.instance.debugWholeDatabaseCount()
        #endif
        
        self.setupNotification(for: launchOptions)

        return true
    }
    
    /// Define the root view controller of current app status.
    private func start(launchOption : [AnyHashable : Any]? = nil) {
        if hasLoggedIn {
            //Check if user has turned on the local auth feature.
            if SettingsManager.isIDAuthEnabled {
                let authVC = LocalAuthViewController.instance()
                window?.rootViewController = authVC
                
                //On auth finished, switch the root vc to main tab vc.
                authVC.onSuccess
                    .take(1)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: {
                        [unowned self] in
                        self.window?.rootViewController = xib(vc: MainTabBarViewController.self)
                        
                        IMUserManager.launch()
                        self.setupSetting()
                    })
                    .disposed(by: bag)
                
            } else {
                window?.rootViewController = xib(vc: MainTabBarViewController.self)
                IMUserManager.launch()
                self.setupSetting()
                if launchOption != nil {
                    TTNotificationHandler.shared.parseNotification(userInfo: launchOption!)
                }
            }
        } else {
            window?.rootViewController = IdentitySetupViewController.instance()
        }
        
    }
    func setupSetting()  {
//        Server.instance.getMarketTest().subscribe().disposed(by: bag)
        MarketTestHandler.shared.launch()
//        Server.instance.getQuotesTest().subscribe().disposed(by: bag)
    }
    
    
    func versionChecker() {
        let versionCheck = VersionChecker.sharedInstance
            .checkVersion()
        
        versionCheck
            .subscribe(onSuccess: {
                [weak self]
                result in
                switch result {
                //Might encounter some error
                case .failed(error: let err):
                    if let vc = self?.window?.rootViewController {
                        vc.showAPIErrorResponsePopUp(from: err,
                                                     cancelTitle: LM.dls.g_confirm)
                    }
                case .success(let checkResult):
                    switch checkResult {
                    case .localVersionIsNewer, .localVersionIsSupported: return
                    case .localVersionIsTooOld:
                        if let vc = self?.window?.rootViewController {
                            vc.showAPIErrorResponsePopUp(
                                from: GTServerAPIError.invalidVerision,
                                cancelTitle: LM.dls.g_confirm)
                            
                        }
                    }
                }
            })
            .disposed(by: bag)
    }
    
    private func syncLocalDefaultInfoIfNeverSyncBefore() {
        //If unable to find the sync date, try to create default coin entities.
        if CoinSyncHandler.getSyncDateOfCurrentVersion() == nil {
            Coin.createDefaultEntities()
        }
    }
    
    /// Calling configDBIfNeeded() will try to create default entity of DB one time only.
    private func configDBIfNeeded() {
        //Config DB is a one-time only behavior, so if the user update the version, db won't config again in case refresh some user data.
        //So, if the db has been configed, we only check if there's any default constructor change of each entity
        //and more, sync the coins basic information as it is likely to change from api
        if !DB.instance.hasConfiged {
//            DB.instance.debugWholeDatabaseCount()
            
            DB.instance.defaultConfigure()
                .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
                .observeOn(ConcurrentMainScheduler.instance)
                .subscribe(
                    onSuccess: {
                        result in
                        guard result else { return errorDebug(response: ()) }
                        
                    }
                )
                .disposed(by: bag)
        }else {
            syncLocalDefaultInfoIfNeverSyncBefore()
            
            //Now we force coin sync each time the app launched
            CoinSyncHandler
                .syncCoins(forVersion: C.Application.version)
                .subscribe(onSuccess: {
                    _ in
                    OWRxNotificationCenter.instance
                        .didFinishLaunchSync()
                })
                .disposed(by: bag)
        }
    }
    
    private func manageThemeUpdate() {
        TM.instance.theme.asDriver().drive(onNext: {
            [unowned self]
            theme in
            self.changeApplicationAppearance(ofTheme: theme)
        })
        .disposed(by: bag)
    }
    
    private func changeApplicationAppearance(ofTheme theme: Theme) {
        let palette = theme.palette
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor : palette.tab_selected],
            for: .selected
        )
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor : palette.tab_unselected],
            for: .normal
        )

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        do { try DB.instance.save() }
        catch let error {
            warning("Cannot save db before application terminated!, error: \(error)")
        }
    }
    
    func startKeyboardManaging() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = LM.dls.g_done
    }

    
    func startObserveIdentityClearEvent() {
        OWRxNotificationCenter.instance
            .identityCleared.subscribe(onNext: {
                [unowned self] in self.resetToIdentityCreateRoot()
            })
            .disposed(by: bag)
    }
    
    private func resetToIdentityCreateRoot() {
        
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        newWindow.rootViewController = IdentitySetupViewController.instance()
        
        UIWindow.transition(with: window!, duration: 0.3, options: .transitionFlipFromRight, animations: {
            let oldWindow = self.window
            
            self.window = newWindow
            newWindow.makeKeyAndVisible()
            
            oldWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            
        }, completion: nil)
        
//        window = UIWindow(frame: UIScreen.main.bounds)
        
        ///SO WHY DOES THE ROOT VIEW CONTROLLER WILL HOLD A STRONG REF EVEN THOUGH IT IS CHANGED??????????????????
//        window?.rootViewController?.dismiss(animated: false, completion: nil)
//        window?.rootViewController =
//        window?.makeKeyAndVisible()
    }
}

import HockeySDK
// MARK: - 3rd party lib update
extension AppDelegate {
    func initalizeHockey() {
        let identifier: String
        switch env() {
        case .prd: identifier = C.Hockey.Identifier.PRD
        case .uat: identifier = C.Hockey.Identifier.UAT
        case .sit: identifier = C.Hockey.Identifier.SIT
        }
        
        BITHockeyManager.shared().configure(withIdentifier: identifier)
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
    }
    
    func initializeFlurry() {
        Flurry.startSession("ZTRMQTPY8CDVY79N47TT", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
    }
}


//MARK: - 1.0.4 specific
extension AppDelegate {
    private func inactiveGUCinETH() {
        let id = "0x694c559c70f966a630fa22547bd4c56a9fe3677f"
        guard let guc_eth = Coin.getCoin(ofIdentifier: id) else {
            return
        }
        
        guc_eth.isActive = false
        guc_eth.isDefaultSelected = false
        guc_eth.isDefault = false
    
        let idPred = CoinSelection.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(CoinSelection.coinIdentifier), value: id))
        DB.instance.batchDelete(type: CoinSelection.self, predicates: [idPred], saveImmediately: true)
    }
}

// MARK: - Test
extension AppDelegate {
    func testQRCodeParsing() {
        let validtor = OWStringValidator.init(sourceTypes: [.mnemonic(id: nil)])
        let scanner = QRCodeImgScanner.init()
        if let results = scanner.detectQRCodeMsgContents(#imageLiteral(resourceName: "i_m_1")) {
            print(results)
            validtor.validate(source: results[0])
                .subscribe(onSuccess: {
                    result in
                    print("validate result\n\(result)")
                })
                .disposed(by: bag)
        }else {
            print("nil")
        }
    }
    
    func testIdentityQRCode() {
        let content = IdentityQRCodeContent.init(identity: Identity.singleton!, pwd: "aaaa4321", pwdHint: "oh ya pwd hint")!
        let qrCodeContent = content.generateQRCodeContent(withPwd: "aaaa4321")!
        print("First qrcodeContent\n \(qrCodeContent)\n")
        let newContent = IdentityQRCodeContent.init(qrCodeRawContent: qrCodeContent, pwd: "aaaa4321")!
        let newQRCodeContent = newContent.generateQRCodeContent(withPwd: "aaaa4321")!
        print("Secod qrcodeContent\n \(newQRCodeContent)\n")
        
        if newQRCodeContent != qrCodeContent {
            fatalError()
        }
        
    }
}


extension AppDelegate {
    
    func setupNotification (for launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        
        JPUSHService.register(forRemoteNotificationTypes: UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.alert.rawValue , categories: nil)
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: "b4526b7273b4bfc188148713", channel: "DEV", apsForProduction: false)
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: "b4526b7273b4bfc188148713", channel: "Hockey", apsForProduction: true)
        #endif
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        
        DLogDebug("didRegisterForRemoteNotificationsWithDeviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DLogError("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DLogDebug("Notification received \(userInfo)")
        TTNotificationHandler.shared.parseNotification(userInfo: userInfo)
    }
}
