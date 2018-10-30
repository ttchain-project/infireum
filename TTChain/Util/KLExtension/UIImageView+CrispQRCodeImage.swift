//
//  UIImageView+CrispQRCodeImage.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/3.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func createCrispQRCodeImage(from ciImage:CIImage) {
        
        let frame = ciImage.extent
        let extent = frame.integral
        let size = self.size
        let scale = min(size.width / extent.width, size.height / extent.height);
        
        let (height, width) = (extent.height * scale, extent.width * scale)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return }
        
        
        bitmapContext.interpolationQuality = CGInterpolationQuality.none
        bitmapContext.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: extent)
        bitmapContext.draw(cgImage!, in: extent, byTiling: true)
        
        //        CGContextDrawImage(bitmapContext, extent, img.cgImage)
        let scaledImage = bitmapContext.makeImage().flatMap { return UIImage(cgImage: $0) }
        self.image = scaledImage
    }
}
