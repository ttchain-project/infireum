//
//  OWInputTextField.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import Cartography

class OWInputTextField: UITextField {
    
    var sepInset: CGFloat = 1 {
        didSet {
            layoutSubviews()
        }
    }
    
    lazy var sepline: UIView = {
        var frame = self.bounds
        frame.size.height = sepInset
        frame.origin.y = self.bounds.height - sepInset
        let sep = UIView.init()
        sep.frame = frame
        return sep
    }()
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.textRect(forBounds: bounds)
        bounds.size.height -= sepInset
        return bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.editingRect(forBounds: bounds)
        bounds.size.height -= sepInset
        return bounds
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if sepline.superview == nil {
            addSubview(sepline)
            constrain(sepline) { (line) in
                let sup = line.superview!
                line.leading == sup.leading
                line.trailing == sup.trailing
                line.height == 1
                line.bottom == sup.bottom
            }
        }
    }
 

}
