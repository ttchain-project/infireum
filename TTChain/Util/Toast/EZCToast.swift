//
//  EZCToast.swift
//  TradingP
//
//  Created by Keith Lee on 2017/12/26.
//  Copyright © 2017年 daniel.lin. All rights reserved.
//

import UIKit
import Toast_Swift

class EZToastInitializer {
    static func defineToastStyle() {
        var style = ToastManager.shared.style
        style.backgroundColor = UIColor.owBlack.withAlphaComponent(0.6)
        style.titleFont = UIFont.init(name: "PingFangTC-Medium", size: 17)!
        style.messageFont = UIFont.init(name: "PingFangTC-Medium", size: 17)!
        style.titleColor = .owWhite
        style.messageColor = .owWhite
        
        ToastManager.shared.style = style
        ToastManager.shared.position = .center
    }
}

class EZToast {
    static func present(on vc: UIViewController, content: String) {
        vc.view.makeToast(content)
    }
}



