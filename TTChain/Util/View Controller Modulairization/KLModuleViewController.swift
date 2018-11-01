//
//  KLModuleViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

class KLModuleViewController: UIViewController,
                              RxNetworkReachabilityRespondable,
                              RxThemeRespondable,
                              RxLangRespondable {
    
    var themeBag: DisposeBag = DisposeBag.init()
    var networkBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        startMonitorNetworkStatusIfNeeded()
//        startMonitorThemeIfNeeded()
//        startMonitorLangIfNeeded()
    }
    
    deinit {
        stopMonitorNetworkStatus()
        stopMonitorTheme()
        stopMonitorLang()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideDefaultNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = .clear
    }
    
    //MARK: - Network Reachability Responder
    /// Optional network responder, if has value it will auto subscribe to reflect network status change.
    var networkResponder: NetworkStatusReponder? {
        return {
            [weak self]
            status in
            self?.handleNetworkStatusChange(status)
        }
    }

    func startMonitorNetworkStatusIfNeeded() {
        guard let responder = networkResponder else { return }
        monitorNetwork(handler: responder)
    }
    
    func stopMonitorNetworkStatus() {
        networkBag = DisposeBag.init()
    }
    
    //MARK: - Theme Responder
    var themeResponder: ThemeResponder? {
        return {
            [weak self]
            theme in
            self?.renderTheme(theme)
        }
    }
    
    func startMonitorThemeIfNeeded() {
        guard let responder = themeResponder else { return }
        monitorTheme(handler: responder)
    }
    
    func stopMonitorTheme() {
        themeBag = DisposeBag.init()
    }
    
    
    //MARK: - Lang Responder
    var langResponder: LangResponder? {
        return {
            [weak self]
            lang in
            self?.renderLang(lang)
        }
    }
    
    func startMonitorLangIfNeeded() {
        guard let responder = langResponder else { return }
        monitorLang(handler: responder)
    }
    
    func stopMonitorLang() {
        langBag = DisposeBag.init()
    }
    
    
    
    //MARK: - Must Override

    func renderLang(_ lang: Lang) {
        warning("Please override \(#function) to determine the lang of the vc")
    }
    
    func renderTheme(_ theme: Theme) {
        warning("Please override \(#function) to determine the color of the vc")
    }
    
    func handleNetworkStatusChange(_ status: NetworkStatus) {
        warning("Please override \(#function) to define the network respond logic of the vc")
    }
}

extension UINavigationController {
    
//    func setupNavBar() {
//        navigationBar.isTranslucent = true
//        navigationBar.barStyle = .blackTranslucent
//        
//        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "navTitleImage"))
//        logoImageView.contentMode = .scaleAspectFill
//        logoImageView.clipsToBounds = true
//        logoImageView.translatesAutoresizingMaskIntoConstraints = false
//
////        logoImageView.frame = (navigationController?.navigationBar.frame)!
//        view.insertSubview(logoImageView, belowSubview: navigationBar)
//        
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()
//        view.backgroundColor = .clear
//        NSLayoutConstraint.activate([
//            logoImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            logoImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            logoImageView.topAnchor.constraint(equalTo: view.topAnchor),
//            logoImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
//            ])
//        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navTitleImage"),
//        //                                                                    for: .default)
//    }
}
