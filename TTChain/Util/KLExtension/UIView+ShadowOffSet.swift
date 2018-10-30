//
//  UIView+ShadowOffSet.swift
//  wddouble
//
//  Created by Keith Lee on 2016/12/26.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit

extension UIView {
    func setupShadow(offset: CGSize, cornerRadius: CGFloat, radius: CGFloat, color: UIColor){
        clipsToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath.init(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
