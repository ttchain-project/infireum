//
//  UIViewController+RxThemeRespondable.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
protocol RxThemeRespondable {
    var themeBag: DisposeBag { get set }
    func monitorTheme(handler: @escaping ThemeResponder, inBag bag: DisposeBag)
    func monitorTheme(handler: @escaping ThemeResponder)
}

extension RxThemeRespondable {
    func monitorTheme(handler: @escaping ThemeResponder, inBag bag: DisposeBag) {
        ThemeManager.instance.theme.subscribe(onNext: {
            theme in
            handler(theme)
        })
        .disposed(by: bag)
    }
    
    func monitorTheme(handler: @escaping ThemeResponder) {
        monitorTheme(handler: handler, inBag: themeBag)
    }
}
