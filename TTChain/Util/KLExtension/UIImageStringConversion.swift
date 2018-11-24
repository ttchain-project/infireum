//
//  UIImageStringConversion.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/25.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var imageFromBase64EncodedString: UIImage? {
        let stringNew = self.replacingOccurrences(of: "data:image/png;base64,", with: "")
        if let data = Data(base64Encoded: stringNew, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
}

extension UIImage {
    
    var base64EncodedString: String {
        if let data = UIImagePNGRepresentation(self) {
            return data.base64EncodedString(options: [])
        }
        return ""
    }
}
