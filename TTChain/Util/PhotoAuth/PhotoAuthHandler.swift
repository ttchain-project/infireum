//
//  PhotoAuthHandler.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/12.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import Photos

class PhotoAuthHandler {
    
    class var hasAuthedCamera: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized, .notDetermined:
            return true
        default:
            return false
        }
    }
    
    class var hasAuthedPhotoLibrary: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .notDetermined:
            return true
        default:
            return false
        }
    }

}
