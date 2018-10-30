//
//  GTQuickLogExtensions.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/12.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
import UIKit

func warning(_ content:String){
    let message = "Warning : \(content)"
    print(message)
}

func notice(_ content:String){
    let message = "Notice : \(content)"
    print(message)
}

func printNoViewControllerWarningMessage(of controllerName:String){
    let message = "No View Controller Found Of Class \(controllerName)"
    warning(message)
}

func printNoPlistWarningMessage(of plistName:String){
    let message = "No Plist Found Of Name \(plistName)"
    warning(message)
}

//MARK: - Global
func printRect(rect:CGRect){
    print("x: \(rect.origin.x), y: \(rect.origin.y), w: \(rect.size.width), h: \(rect.size.height)")
}

//MARK: - Server Side
//func printServerError(error:Error, request:SWGObject){
//    warning("Find  \(request.nameOfClass)")
//    print("Error Message Is : \(error)")
//}
//
//func printNoDataServerError(forRequest request:SWGObject){
//    warning("\(request.nameOfClass) Response Data is nil")
//}
//
//func printRequestSuccessMessage(of request:SWGObject){
//    notice("\(request.nameOfClass) finished in success.")
//}
