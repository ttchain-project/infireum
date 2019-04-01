//
//  InviteFriendViewModel.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class InviteFriendViewModel: KLRxViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    
    
    required init(input: Input, output: Output) {
        self.input = input
        self.output = output
    }
    
    func concatInput() { }
    
    func concatOutput() { }
}
