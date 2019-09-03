//
//  ImportSuccessViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/8/27.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ImportSuccessViewModel: KLRxViewModel {
    required init(input: Void, output: Void) {
        
    }
    
    var input: Void
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    typealias OutputSource = Void
    var bag: DisposeBag = DisposeBag()
    
}
