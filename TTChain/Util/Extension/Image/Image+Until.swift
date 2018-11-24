//
//  Image+Until.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/29.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import EliteFramework

class ImageUntil: NSObject {
    static func drawAvatar(text: String) -> UIImage {
        let colors: [UIColor] = [UIColor.init(hex: 0x33A6B8),
                                 UIColor.init(hex: 0x7BA23F),
                                 UIColor.init(hex: 0xF28821),
                                 UIColor.init(hex: 0x8A6BBE),
                                 UIColor.init(hex: 0xA07829)]
        let color = colors[Int.random(in: 0...4)]
        
        var image = UIImage.init(color: color)
        
        image = image.scaleToSize(size: CGSize.init(width: 90, height: 90))
        
        return drawText(String.init(text[0]), onImage: image)
    }
    
    static func drawText(_ text: String, onImage image: UIImage, textColor: UIColor = .white, font: UIFont = UIFont(name: "PingFangTC-Regular", size: 60)!) -> UIImage {
        let textHeight = font.lineHeight
        let imageSize = image.size
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let textFontAttributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraph
        ]
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        image.draw(in: CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        text.draw(in: CGRect(x: 0, y: 0.5 * (imageSize.height - textHeight), width: imageSize.width, height: textHeight), withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
}
