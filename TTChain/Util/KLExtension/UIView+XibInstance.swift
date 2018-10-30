//
//  UIView+XibInstance.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/11/9.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    static func xibInstance() -> UIView? {
        let xibView = UINib.init(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil).first
        if let view = xibView as? UIView {
            return view
        }else{
            return nil
        }
    }
}
