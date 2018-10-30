//
//  EliteImage.swift
//  EliteFramework
//
//  Created by Lifelong-Study on 2016/3/9.
//  Copyright © 2016年 Lifelong-Study. All rights reserved.
//

import UIKit

public extension UIImage {
    
    //
    fileprivate convenience init(image: UIImage?) {
        if let cgimage = image?.cgImage {
            self.init(cgImage: cgimage)
        } else {
            self.init()
        }
    }
    
    // initialization
    convenience init(color: UIColor) {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        color.setFill()
        
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.init(image: image)
    }
    
    convenience init(layer: CALayer) {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.init(image: image)
    }
    
    
    convenience init(render view: UIView, from: RenderDirection, to: RenderDirection, colors: [UIColor]) {
        let layer = CALayer()
        
        layer.bounds = view.bounds
        
        layer.renderGradient(from: from, to: to, colors: colors)
        
        self.init(layer: layer)
    }
    
    // function
    func radians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * Double.pi / 180.0)
    }
    
    /*! 影像剪裁 */
    func trimImageWithMask(_ maskFrame: CGRect) -> UIImage? {
        if let cgimage = self.cgImage {
            if let imageRef = cgimage.cropping(to: maskFrame) {
                return UIImage(cgImage: imageRef)
            }
        }
        
        return nil
    }
    
    //!
    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size);
        
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image!;
    }
    
    //!
    func compress(maxWidth: Double, maxHeight: Double, quality: Double) -> UIImage? {
        
        var actualWidth  = Double(self.size.width)
        var actualHeight = Double(self.size.height)
        let maxRatio     = maxWidth / maxHeight;
        var imgRatio     = actualWidth / actualHeight;
        
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if false {
            } else if imgRatio < maxRatio {
                // 根據  maxHeight 調節影像寬度
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            } else if imgRatio > maxRatio {
                // 根據  maxWidth 調節影像高度
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            } else {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(image!, CGFloat(quality))
        UIGraphicsEndImageContext()
        
        
        return UIImage(data: imageData!)
    }
    
    //!
    func rotate(orientation: UIImageOrientation) -> UIImage? {
        
        if orientation != .right && orientation != .left {
            return self
        }
        
        UIGraphicsBeginImageContext(self.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        if false {
        } else if orientation == .right {
            context!.rotate(by: radians(90))
        } else if orientation == .left {
            context!.rotate(by: radians(-90))
        }
        
        draw(at: CGPoint(x: 0, y: 0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    
}
