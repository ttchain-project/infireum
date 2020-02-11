//
//  QRCodeGenerator.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/5/3.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import CoreImage
import GZIP

class QRCodeGenerator {
    static func generateQRCode(from string: String) -> CIImage? {
        
        let data = string.data(using: String.Encoding.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            let transform = CGAffineTransform(scaleX: 4, y: 4)
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0") // Foreground
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1") // background
            if let output = colorFilter.outputImage?.transformed(by: transform) {
                return output
            }
        }
        return nil
    }
    
    static func gZipAndgenerateQRCode(from string: String) -> CIImage? {
        let data = string.data(using: String.Encoding.utf8)
        let base64String = (data! as NSData).gzippedData(withCompressionLevel: 1)?.base64EncodedString()
                
//        let data = string.data(using: String.Encoding.utf8)
//        let compressedData:Data = try! data?.gzipped(level: .bestCompression) ?? data!
//        let base64String = compressedData.base64EncodedString()
        
        
        let base64Data = base64String?.data(using: .utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }

            filter.setValue(base64Data, forKey: "inputMessage")
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0") // Foreground
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1") // background
            if let output = colorFilter.outputImage?.transformed(by: transform) {
                return output
            }
        }
        return nil
    }
 

}
