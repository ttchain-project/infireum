//
//  Reactive+UITextView.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/28.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base : UITextView {
    var isEditable: Binder<Bool> {
        return Binder(base) { textView, value in
            textView.isEditable = value
        }
    }
}

extension Reactive where Base: UIButton {
    func titleColor(for controlState: UIControl.State = []) -> Binder<UIColor> {
        return Binder(base) { button, value in
            button.setTitleColor(value, for: controlState)
        }
    }
}
