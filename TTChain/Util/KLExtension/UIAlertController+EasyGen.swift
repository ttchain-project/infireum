//
//  UIAlertController+SimplePopUp.swift
//  KLTreeDrawerModel
//
//  Created by keith.lee on 2016/10/7.
//  Copyright © 2016年 Keith. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func simplePopUp(with title:String, contents:String, cancelTitle: String, cancelHandler: ((_ action:UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController.init(title: title, message: contents, preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: cancelHandler)
        
        alert.addAction(cancel)
        
        return alert
    }

}
