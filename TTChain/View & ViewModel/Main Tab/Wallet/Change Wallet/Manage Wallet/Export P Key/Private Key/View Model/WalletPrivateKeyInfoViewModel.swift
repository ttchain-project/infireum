//
//  WalletPrivateKeyInfoViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletPrivateKeyInfoViewModel: KLRxViewModel {
    struct Input {
        let privateKey: String
        let copyPKeyInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WalletPrivateKeyInfoViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var pKey: Driver<String> {
        return Driver.just(input.privateKey)
    }
    
    public var addressCopied: Driver<Void> {
        return input.copyPKeyInput.flatMapLatest {
            [unowned self] in self.copiedAddress()
        }
    }
    
    //MARK: - Private
    private func copiedAddress() -> Driver<Void> {
        UIPasteboard.general.string = input.privateKey
        return Observable.just(()).concat(Observable.never()).asDriver(onErrorJustReturn: ())
    }
}
