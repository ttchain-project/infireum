//
//  UITextField+PlaceholderColors.swift
//  wddouble
//
//  Created by keith.lee on 2016/12/15.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            if let attr = self.attributedPlaceholder?.attributes,
                let color = attr[NSAttributedStringKey.foregroundColor] as? UIColor {
                return color
            }else {
                return nil
            }
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? " ", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
