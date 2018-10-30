//
//  UITableViewCell+CellIdentifier.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/28.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class func cellIdentifier() -> String {
        return self.nameOfClass
    }
}

extension UICollectionViewCell {
    class func cellIdentifier() -> String {
        return self.nameOfClass
    }
}
