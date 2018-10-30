//
//  EliteColor.swift
//  EliteFramework
//
//  Created by Lifelong-Study on 2015/12/17.
//  Copyright © 2015年 Lifelong-Study. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(hex: UInt64) {
        self.init(  red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
                  green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0,
                   blue: ((CGFloat) (hex & 0xFF)) / 255.0,
                  alpha: 1.0)
    }
    
    public convenience init(hex: UInt64, alpha: CGFloat) {
        self.init(  red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
                  green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0,
                   blue: ((CGFloat) (hex & 0xFF)) / 255.0,
                  alpha: alpha)
    }
}

public func blackColor2() -> UIColor {
    return UIColor.black
}

public let blackColor: UIColor = UIColor.black
