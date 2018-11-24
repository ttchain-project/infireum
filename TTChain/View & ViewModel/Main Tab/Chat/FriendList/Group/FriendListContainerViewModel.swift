//
//  FriendListContainerViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FriendListContainerViewModel: KLRxViewModel {
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
    }
    
    var input: Void
    
    var output: Void
    var searchStatus : BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    
}
