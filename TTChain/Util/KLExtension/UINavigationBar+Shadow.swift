//
//  UINavigationBar+Shadow.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/3/12.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit

// MARK: - EXExchange Shadow Rasterize
extension UINavigationBar {
    func renderShadow() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.init(width: 0, height: 2)
        layer.shadowRadius = 2
    }
    
    func clearShadow() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
    }
}
