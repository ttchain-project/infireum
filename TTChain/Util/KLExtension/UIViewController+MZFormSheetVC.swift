//
//  UIViewController+MZFormSheetVC.swift
//  wddouble
//
//  Created by keith.lee on 2016/12/19.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

extension UIViewController {
    func formSheetVC(size: CGSize) -> MZFormSheetPresentationViewController {
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: self)
        formSheetController.presentationController?.contentViewSize = size
        // or pass in UILayoutFittingCompressedSize to size automatically with auto-layout
        formSheetController.presentationController?.shouldCenterHorizontally = true
        formSheetController.presentationController?.shouldCenterVertically = true

        return formSheetController
    }

}
