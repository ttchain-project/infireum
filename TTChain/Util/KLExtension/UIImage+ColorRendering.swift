//
//  UIImage+ColorRendering.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/14.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit
extension UIImage {
    func filled(with fillColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        
        
        fillColor.setFill()
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x:0, y:0, width:self.size.width, height:self.size.height)
        context.draw(self.cgImage!, in: rect)
        context.setBlendMode(.sourceIn)
        context.addRect(rect)
        context.drawPath(using: .fill)
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return coloredImg
    }
}
