//
//  QRCodeImgScanner.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/3.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import CoreImage

class QRCodeImgScanner {
    public func detectQRCodeMsgContents(_ image: UIImage) -> [String]? {
        guard let features = detectQRCode(image) else {
            return nil
        }
        
        let qrCodeMsgs = features.compactMap { (feature) -> String? in
            guard let str =  (feature as? CIQRCodeFeature)?.messageString else { return nil }
            guard IdentityQRCodeContent.isSourceHasValidIdentityQRCodeFormat(str) else { return nil }
            
            return str
        }
        
        
        return qrCodeMsgs
    }
    
    private func detectQRCode(_ image: UIImage) -> [CIFeature]? {
        guard let ciImage = CIImage.init(image: image) else { return nil }
        
        var options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let context = CIContext()
        
        guard let qrDetector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: context,
            options: options
            ) else {
            return nil
        }
        
        var orientation: Any = 1
        let orientationKey = kCGImagePropertyOrientation as String
        let isImgHasOrientationProperty = ciImage.properties.keys.contains(orientationKey)
        
        if isImgHasOrientationProperty {
            let orientationKey = kCGImagePropertyOrientation as String
            orientation = ciImage.properties[orientationKey] ?? 1
        }
        
        options = [CIDetectorImageOrientation : orientation]
        
        let features = qrDetector.features(in: ciImage)
        
        return features
    }
}
