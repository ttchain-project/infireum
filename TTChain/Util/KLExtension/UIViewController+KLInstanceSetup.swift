//
//  UIViewController+KLRx.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
protocol KLInstanceSetupViewController {
    associatedtype Constructor
    static func instance(from constructor: Constructor) -> Self
    static func navInstance(from constructor: Constructor) -> UINavigationController
    func config(constructor: Constructor)
}

extension KLInstanceSetupViewController where Self: UIViewController {
    static func instance(from constructor: Constructor) -> Self {
        let vc = xib(vc: self)
        vc.config(constructor: constructor)
        return vc
    }
    
    static func navInstance(from constructor: Constructor) -> UINavigationController {
        let vc = xib(vc: self)
        let nav = UINavigationController.init(rootViewController: vc)
        vc.config(constructor: constructor)
        
        return nav
    }
}

extension KLInstanceSetupViewController where Self: UIViewController, Constructor == Void {
    static func instance() -> Self {
        return instance(from: ())
    }
    
    static func navInstance() -> UINavigationController {
        return navInstance(from: ())
    }
    
    static func AJNavInstance() -> AJNavigationController {
        let vc = xib(vc: self)
        let nav = AJNavigationController.init(rootViewController: vc)
        vc.config(constructor: ())
        return nav
    }
}


