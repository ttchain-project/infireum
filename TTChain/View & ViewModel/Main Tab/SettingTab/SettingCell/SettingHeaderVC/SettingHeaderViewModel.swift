//
//  SettingHeaderViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/26.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SettingHeaderViewModel:KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
    }
    var input: Void
    var output: Void
    
    var bag:DisposeBag = DisposeBag()
    typealias InputSource = Void
    typealias OutputSource = Void
    
    func concatInput() {}
    func concatOutput() {}
    
    
}
