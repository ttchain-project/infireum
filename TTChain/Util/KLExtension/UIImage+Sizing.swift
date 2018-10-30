//
//  UIImage+Sizing.swift
//  TradingP
//
//  Created by Keith Lee on 2017/7/3.
//  Copyright © 2017年 daniel.lin. All rights reserved.
//

import UIKit
extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
//        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect.init(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scaleImage(rate: CGFloat) -> UIImage? {
        let data = UIImageJPEGRepresentation(self, rate)!
        return UIImage.init(data: data)
    }
}
