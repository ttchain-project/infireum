//
//  EliteLayoutConstraint.swift
//  EliteFramework
//
//  Created by Lifelong-Study on 2016/5/28.
//  Copyright © 2016年 Lifelong-Study. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    
    //
    class func constraint(item: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return constraint(item: item, attribute: attribute, offset: 0.0)
    }
    
    //
    class func constraint(item: UIView, attribute: NSLayoutAttribute, offset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: item.superview, attribute: attribute, multiplier: 1.0, constant: offset)
    }
    
    //
    class func constraints(withVisualFormat format: String, views: [String : AnyObject]) -> [NSLayoutConstraint] {
        return constraints(withVisualFormat: format, options: .directionLeadingToTrailing, metrics: nil, views: views)
    }
    
    //
    class func constraints(withVisualFormat format: String, metrics: [String : Any]?, views: [String : AnyObject]) -> [NSLayoutConstraint] {
        return constraints(withVisualFormat: format, options: .directionLeadingToTrailing, metrics: metrics, views: views)
    }
    
    //
    class func equal(item: UIView, toItem: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return equal(item: item, toItem: toItem, attribute: attribute, offset: 0.0)
    }
    
    //
    class func equal(item: UIView, toItem: UIView, attribute: NSLayoutAttribute, offset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: attribute, multiplier: 1.0, constant: offset)
    }
    
    //
    class func equal(item: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return equal(item: item, toItem: item.superview!, attribute: attribute, offset: 0.0)
    }
    
    //
    class func equal(item: UIView, attribute: NSLayoutAttribute, offset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: item.superview!, attribute: attribute, multiplier: 1.0, constant: offset)
    }
    
    //
    class func equal(item: UIView, attribute: NSLayoutAttribute, toAttribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return equal(item: item, attribute: attribute, toAttribute: toAttribute, multiplier: 1.0)
    }
    
    //
    class func equal(item: UIView, attribute: NSLayoutAttribute, toAttribute: NSLayoutAttribute, multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: item.superview!, attribute: toAttribute, multiplier: multiplier, constant: 0.0)
    }
    
    //
    class func equal(item: UIView, toItem: UIView) -> [NSLayoutConstraint] {
        return [equal(item: item, toItem: toItem, attribute: .width),
                equal(item: item, toItem: toItem, attribute: .height),
                equal(item: item, toItem: toItem, attribute: .centerX),
                equal(item: item, toItem: toItem, attribute: .centerY)]
    }
    
    //
    class func constraint(item: UIView, attribute: NSLayoutAttribute, equalAttribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: item, attribute: equalAttribute, multiplier: 1.0, constant: 0.0)
    }
    
    //
    class func constraint(item: UIView, attribute: NSLayoutAttribute, equalAttribute: NSLayoutAttribute, offset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal, toItem: item, attribute: equalAttribute, multiplier: 1.0, constant: offset)
    }
    
    //
    class func constraint(item: UIView, width: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: width)
    }
    
    //
    class func constraint(item: UIView, height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: height)
    }
}
