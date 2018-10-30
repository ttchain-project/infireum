//
//  NVActivityExtension.swift
//  TradingP
//
//  Created by daniel.lin on 2017/5/11.
//  Copyright © 2017年 daniel.lin. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
    func animateIndicatorImmediately(message: String? = nil) {
        animateIndicator(message: message, threshold: 0)
    }
    
    
    func animateIndicator(message: String? = nil, threshold: Int = 500) {
        hideIndicator()
        
        let data = ActivityData.init(
            message: message,
            displayTimeThreshold: threshold
        )
        
        DispatchQueue.main.async (execute: {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
        })
    }
    
    func hideIndicator() {
        DispatchQueue.main.async (execute: {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        })
    }
}

