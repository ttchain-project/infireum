//
//  WindowOrientaionLocker.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/2/12.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
class WindowOrientationLocker {
    static let locker = WindowOrientationLocker.init()
    var orientation: UIInterfaceOrientationMask = .portrait
    func lockOrientation(to orientation: UIInterfaceOrientationMask) {
        self.orientation = orientation
    }
    
    func lockOrientation(to orientation: UIInterfaceOrientationMask, andRotate rotateOrientation: UIInterfaceOrientation) {
        lockOrientation(to: orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}
