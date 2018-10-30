//
//  KLTextField.swift
//  wddouble
//
//  Created by keith.lee on 2016/12/15.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit

@IBDesignable
class KLTextField: UITextField {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
 

    @IBInspectable var leftTextPadding: CGFloat = 0
    @IBInspectable var rightTextPadding: CGFloat = 0
    @IBInspectable var topTextPadding: CGFloat = 0
    @IBInspectable var bottomTextPadding: CGFloat = 0
    
    @IBInspectable var leftRightViewPadding: CGFloat = 0
    @IBInspectable var rightRightViewPadding: CGFloat = 0
    @IBInspectable var topRightViewPadding: CGFloat = 0
    @IBInspectable var bottomRightViewPadding: CGFloat = 0
    
    @IBInspectable var leftLeftViewPadding: CGFloat = 0
    @IBInspectable var rightLeftViewPadding: CGFloat = 0
    @IBInspectable var topLeftViewPadding: CGFloat = 0
    @IBInspectable var bottomLeftViewPadding: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        let top =  max(topLeftViewPadding, topRightViewPadding, topTextPadding)
        let bottom = max(bottomLeftViewPadding, bottomRightViewPadding, bottomTextPadding)
        let left = leftLeftViewPadding + leftRightViewPadding + leftTextPadding
        let right = rightLeftViewPadding + rightRightViewPadding + rightTextPadding
        size.width += (left + right)
        size.height += (top + bottom)

        return size
    }

    var textInsets: UIEdgeInsets {
        let top = topTextPadding
        let bottom = bottomTextPadding
        let left = leftTextPadding
        let right = rightTextPadding
        return UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
    }
//
    var rightViewInsets: UIEdgeInsets {
        let top = topRightViewPadding
        let bottom = bottomRightViewPadding
        let left = leftRightViewPadding
        let right = rightRightViewPadding
        return UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
    }

    var leftViewInsets: UIEdgeInsets {
        let top = topLeftViewPadding
        let bottom = bottomLeftViewPadding
        let left = leftLeftViewPadding
        let right = rightLeftViewPadding
        return UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
    }
//
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        let newRect = UIEdgeInsetsInsetRect(rect, textInsets)
        return newRect
    }
//
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let newRect = UIEdgeInsetsInsetRect(rect, textInsets)
//        print("editingRect of text: \(text)")
//        print(newRect)
        return newRect
    }
//
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        let newRect = UIEdgeInsetsInsetRect(rect, rightViewInsets)
//        print("rightViewRect of text: \(text)")
//        print(newRect)
        return newRect
    }
//
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        let newRect = UIEdgeInsetsInsetRect(rect, leftViewInsets)
        return newRect
    }
}
