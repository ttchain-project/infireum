//
//  TransRecord+Comments.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/15.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import ObjectiveC

extension TransRecord {
    
    private struct AssociatedKeys {
        static var kTransComments = "kTransComments"
    }
    private var comment: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kTransComments) as? String
        }set {
            objc_setAssociatedObject(self, &AssociatedKeys.kTransComments, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var remarkComment :String? {
        get {
            return self.comment
        }
        set {
            self.comment = newValue
        }
    }
}
