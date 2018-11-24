//
//  UserProfileViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserProfileViewModel :KLRxViewModel {
    
    typealias InputSource = Void
    typealias OutputSource = Void
    var bag: DisposeBag = DisposeBag.init()
    
    var input: UserProfileViewModel.InputSource
    var output: UserProfileViewModel.OutputSource
    
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
}
