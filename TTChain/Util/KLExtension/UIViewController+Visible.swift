//
//  UIViewController+Visible.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/12/6.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func isVisible() -> Bool {
        return self.isViewLoaded && (self.view.window != nil)
    }
}
