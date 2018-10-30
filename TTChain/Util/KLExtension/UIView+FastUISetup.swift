//
//  UIView+FastUISetup.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/4/9.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import SwifterSwift


extension UIView {
    func set(backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        }
        
        if let border = borderInfo {
            borderColor = border.color
            borderWidth = border.width
        }
    }
}

protocol KLUIFastSetup {
    func set(
        textColor: UIColor?,
        font: UIFont?,
        text: String?,
        attrText: NSAttributedString?,
        backgroundColor: UIColor?,
        borderInfo: (color: UIColor, width: CGFloat)?
    )
}

extension UILabel: KLUIFastSetup {
    func set(textColor: UIColor? = nil, font: UIFont? = nil, text: String? = nil,
             attrText: NSAttributedString? = nil, backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        if let attrT = attrText {
            self.attributedText = attrT
        }else {
            if let t = text {
                self.text = t
            }
            
            if let tc = textColor {
                self.textColor = tc
            }
            
            if let f = font {
                self.font = f
            }
        }
        
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        }
        
        if let border = borderInfo {
            borderColor = border.color
            borderWidth = border.width
        }
    }
    
    func set(textColor: UIColor, font: UIFont) {
        let color: UIColor? = textColor
        let font: UIFont? = font
        set(textColor: color, font: font)
    }
}

extension UITextField {
    func set(placeholder: String) {
        if let originAttrs = attributedPlaceholder?.attributes {
            self.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: originAttrs)
        } else {
            self.placeholder = placeholder
        }
    }
    
    func set(textColor: UIColor, font: UIFont, placeHolderColor: UIColor) {
        self.textColor = textColor
        self.tintColor = textColor
        self.font = font
        self.placeHolderColor = placeHolderColor
    }
}

extension UIButton: KLUIFastSetup {
    func set(color: UIColor, font: UIFont? = nil, image: UIImage? = nil, text: String? = nil, attrText: NSAttributedString? = nil, backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        
        set(textColor: color, font: font, text: text, attrText: attrText, backgroundColor: backgroundColor, borderInfo: borderInfo)
        
        if let img = image {
            setImageForAllStates(img)
            if buttonType == .system {
                tintColor = color
            }
        }
    }
    
    func setPureImage(color: UIColor, image: UIImage, backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        set(color: color, image: image, text: "", backgroundColor: backgroundColor, borderInfo: borderInfo)
    }
    
    func setPureText(color: UIColor, font: UIFont, text: String? = nil, attrText: NSAttributedString? = nil, backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        set(color: color, font: font, image: nil, text: text, attrText: attrText, backgroundColor: backgroundColor, borderInfo: borderInfo)
    }
    
    func set(textColor: UIColor? = nil, font: UIFont? = nil, text: String? = nil,
             attrText: NSAttributedString? = nil, backgroundColor: UIColor? = nil, borderInfo: (color: UIColor, width: CGFloat)? = nil) {
        
        
        if let attrT = attrText {
            self.setAttributedTitle(attrT, for: .normal)
            self.setAttributedTitle(attrT, for: .selected)
            self.setAttributedTitle(attrT, for: .highlighted)
            self.setAttributedTitle(attrT, for: .disabled)
        }else {
            if let t = text {
                self.setTitleForAllStates(t)
            }
            
            if let tc = textColor {
                if buttonType == .custom {
                    self.setTitleColorForAllStates(tc)
                }
                
                tintColor = tc
            }
            
            if let f = font {
                self.titleLabel?.font = f
            }
        }
    
        
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        }
        
        if let border = borderInfo {
            borderColor = border.color
            borderWidth = border.width
        }
    }
    
    func roundBothSides() {
        cornerRadius = height * 0.5
    }
}
