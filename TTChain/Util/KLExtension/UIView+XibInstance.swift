//
//  UIView+XibInstance.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/11/9.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    static func xibInstance() -> UIView? {
        let xibView = UINib.init(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil).first
        if let view = xibView as? UIView {
            return view
        }else{
            return nil
        }
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension UIView {
    
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        
        contentView.backgroundColor = backgroundColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(contentView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": contentView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": contentView]))
        
        
        return contentView
    }
}

class XIBView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
}
