//
//  KLTagFlowLayout.swift
//  ECommerce
//
//  Created by Keith Lee on 2017/2/17.
//  Copyright © 2017年 Keith Lee. All rights reserved.
//

import UIKit

class KLTagFlowLayout: UICollectionViewFlowLayout {
    var staticLeftSpacing: CGFloat = 10.0
    var inset: UIEdgeInsets
    init(inset: UIEdgeInsets) {
        self.inset = inset
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        inset = .zero
        super.init(coder: aDecoder)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attrForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttrInRect = [UICollectionViewLayoutAttributes]()
        
        var leftMargin: CGFloat = inset.left
        var curY: CGFloat = inset.top
        for attr in attrForElementsInRect! {
            let refAttr = attr as UICollectionViewLayoutAttributes
            if refAttr.representedElementKind == UICollectionElementKindSectionHeader {
                newAttrInRect.append(refAttr)
                continue
            }
            
            if refAttr.frame.origin.x <= inset.left {
                leftMargin = inset.left
            }else if refAttr.frame.origin.y > curY {
                leftMargin = inset.left
                var newLeftAlignedFrame = refAttr.frame
                newLeftAlignedFrame.origin.x = leftMargin
                refAttr.frame = newLeftAlignedFrame
            }else {
                var newLeftAlignedFrame = refAttr.frame
                newLeftAlignedFrame.origin.x = leftMargin
                refAttr.frame = newLeftAlignedFrame
            }
            
            curY = refAttr.frame.origin.y
            leftMargin += refAttr.frame.width + staticLeftSpacing
            newAttrInRect.append(refAttr)
        }
        return newAttrInRect
    }
    
}
