//
//  LocalAuthViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LocalAuthViewModel: KLRxViewModel {
    
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: InputSource
    var output: OutputSource
    
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
    
    //MARK: - Public Function
    func validatePwd(input: String) -> Bool {
        return Identity.singleton!.isIdentityRawPwd(pwd: input)
    }
}
