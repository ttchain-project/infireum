//
//  Any+RxLangRespondable.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol RxLangRespondable {
    var langBag: DisposeBag { get set }
    func monitorLang(handler: @escaping LangResponder, inBag bag: DisposeBag)
    func monitorLang(handler: @escaping LangResponder)
}

extension RxLangRespondable {
    func monitorLang(handler: @escaping LangResponder, inBag bag: DisposeBag) {
        LangManager.instance.lang.subscribe(onNext: {
            lang in
            handler(lang)
        })
        .disposed(by: bag)
    }
    
    func monitorLang(handler: @escaping LangResponder) {
        monitorLang(handler: handler, inBag: langBag)
    }
}
