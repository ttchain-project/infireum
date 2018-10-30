//
//  UIViewController+StoryboardInstance.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/11.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit
extension UIViewController {
    public class var storybordName: String {
        return self.nameOfClass
    }
    
//    static func storyboardInstance(from name:String? = nil) -> UIViewController? {
//        let sb = UIStoryboard.init(name: name ?? self.storybordName, bundle: nil)
//        guard let initialVC = sb.instantiateInitialViewController() else{
//            printNoViewControllerWarningMessage(of: name ?? self.storybordName)
//            return nil
//        }
//        return initialVC
//    }
    
//    static func storyboard<VC: UIViewController>() -> VC? {
//        let sb = UIStoryboard.init(name: VC.storybordName, bundle: nil)
//        guard let initialVC = sb.instantiateInitialViewController() else{
//            printNoViewControllerWarningMessage(of: self.storybordName)
//            return nil
//        }
//        return initialVC as? VC
//    }
}

func sb<VC: UIViewController>(vc: VC.Type, name: String? = nil) -> VC? {
    let nameToUse = name ?? vc.storybordName
    let _sb = UIStoryboard.init(name: nameToUse, bundle: nil)
    guard let initialVC = _sb.instantiateInitialViewController() else{
        printNoViewControllerWarningMessage(of: nameToUse)
        return nil
    }
    
    return initialVC as? VC
}
