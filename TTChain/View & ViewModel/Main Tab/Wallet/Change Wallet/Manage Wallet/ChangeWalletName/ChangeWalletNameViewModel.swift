//
//  ChangeWalletNameViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/18.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChangeWalletNameViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        var wallet:Wallet
    }
    let messageSubject = PublishSubject<String>()
    let walletNameUpdated = PublishRelay<Void>()
    typealias InputSource = Input
    var input: ChangeWalletNameViewModel.Input
    typealias OutputSource = Void
    var output: Void
   
    func concatInput() {
        
    }
    func concatOutput() {
        
    }
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
    }
    
    func walletType() -> String {
        return (self.input.wallet.mainCoin?.fullname)!
    }
    
    func validateWalletName(name:String) -> Bool {
        switch name.ow_isValidWalletName {
        case .valid:
            return true
        case .incorrectFormat(desc: let desc):
            DLogInfo(desc)
            messageSubject.onNext(desc)
            return false
        }
    }
    func updateWalletName(name:String) {
        if !self.validateWalletName(name:name) {
            return
        }
        self.input.wallet.name = name
        DB.instance.update()
        OWRxNotificationCenter.instance.notifyWalletNameUpdate(of: self.input.wallet)
        walletNameUpdated.accept(())
    }
}
