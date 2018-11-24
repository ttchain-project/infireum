//
//  UIView+UIImage.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/16.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
