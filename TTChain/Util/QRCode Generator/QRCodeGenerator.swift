//
//  QRCodeGenerator.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/5/3.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import CoreImage
import Gzip

class QRCodeGenerator {
    static func generateQRCode(from string: String) -> CIImage? {
        
        let data = string.data(using: String.Encoding.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0") // Foreground
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1") // background
            if let output = colorFilter.outputImage {
                return output
            }
        }
        return nil
    }
    
    static func gZipAndgenerateQRCode(from string: String) -> CIImage? {
        
        let data = string.data(using: String.Encoding.utf8)
        let compressedData:Data = try! data?.gzipped(level: .bestCompression) ?? data!
        let base64String = compressedData.base64EncodedString()
        let base64Data = base64String.data(using: .utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }

            filter.setValue(base64Data, forKey: "inputMessage")
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0.08, green: 0.55, blue: 0.27), forKey: "inputColor0") // Foreground
            colorFilter.setValue(CIColor(red: 0.98, green: 0.98, blue: 0.98), forKey: "inputColor1") // background
            if let output = colorFilter.outputImage {
                return output
            }
        }
        return nil
    }
 

}
