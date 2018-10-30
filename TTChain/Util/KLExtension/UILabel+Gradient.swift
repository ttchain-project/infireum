//
//  UILabel+Gradient.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/2/2.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import Cartography

class KLGradientLabel: UILabel {
    fileprivate let gradientLayer = CAGradientLayer.init()
    let masklabel: UILabel
    
    var gradientColors: [UIColor] = []
    
    required init?(coder aDecoder: NSCoder) {
        self.masklabel = UILabel.init(frame: .zero)

        super.init(coder: aDecoder)
        self.masklabel.frame = self.bounds
        self.masklabel.numberOfLines = numberOfLines
        self.masklabel.minimumScaleFactor = 0.5
        self.masklabel.adjustsFontSizeToFitWidth = true

        
//        constrain(masklabel) { (label) in
//            let sup = label.superview!
//            label.top == sup.top
//            label.bottom == sup.bottom
//            label.leading == sup.leading
//            label.trailing == sup.trailing
//        }

        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)

        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
//        self.addSubview(masklabel)
        layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.frame = bounds
        masklabel.frame = bounds
        masklabel.text = text
        masklabel.font = font
        masklabel.textAlignment = textAlignment
        
        mask = masklabel
    }
}
