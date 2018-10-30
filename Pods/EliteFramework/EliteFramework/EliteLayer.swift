//
//  EliteLayer.swift
//  Transformer
//
//  Created by Lifelong-Study on 2016/1/19.
//  Copyright © 2016年 Lifelong-Study. All rights reserved.
//

import UIKit

public enum EliteDirection {
    case fromTopToBottom  // Top    -> Bottom
    case fromBottomToTop  // Bottom -> Top
    case fromLeftToRight  // Left   -> Right
    case fromRightToLeft  // Right  -> Left
}

public enum RenderDirection {
    case top
    case bottom
    case left
    case right
}

public extension CALayer {
    
    
    
    public func renderGradient(from: RenderDirection, to: RenderDirection, colors: [UIColor]) {
        
        var cgColorsArray: [CGColor] = Array()
        
        for color in colors {
            cgColorsArray.append(color.cgColor)
        }
        
        // 初始化漸層效果
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = getPoint(direction: from)
        gradientLayer.endPoint   = getPoint(direction: to)
        gradientLayer.frame      = bounds
        gradientLayer.colors     = cgColorsArray
        gradientLayer.name       = "GradientEffectsLayer"
        
        // 套用漸層效果
        if sublayers != nil && sublayers![0].name == "GradientEffectsLayer" {
            replaceSublayer(sublayers![0], with: gradientLayer)
        } else {
            insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func getPoint(direction: RenderDirection) -> CGPoint {
        switch (direction) {
            case .top:          return CGPoint(x: 0.5, y: 0)
            case .bottom:       return CGPoint(x: 0.5, y: 1)
            case .left:         return CGPoint(x: 0, y: 0.5)
            case .right:        return CGPoint(x: 1, y: 0.5)
        }
    }
    
    func getStartPoint(withDirection direction: EliteDirection) -> CGPoint {
        switch (direction) {
            case .fromTopToBottom:      return CGPoint(x: 0.5, y: 0)
            case .fromBottomToTop:      return CGPoint(x: 0.5, y: 1)
            case .fromLeftToRight:      return CGPoint(x: 0, y: 0.5)
            case .fromRightToLeft:      return CGPoint(x: 1, y: 0.5)
        }
    }
    
    func getEndPoint(withDirection direction: EliteDirection) -> CGPoint {
        switch (direction) {
            case .fromTopToBottom:      return CGPoint(x: 0.5, y: 1)
            case .fromBottomToTop:      return CGPoint(x: 0.5, y: 0)
            case .fromLeftToRight:      return CGPoint(x: 1, y: 0.5)
            case .fromRightToLeft:      return CGPoint(x: 0, y: 0.5)
        }
    }
}
