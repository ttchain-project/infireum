//
//  KLMVVM.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
protocol KLViewModel {
    associatedtype InputSource
    associatedtype OutputSource
    init(input: InputSource, output: OutputSource)
    var input: InputSource { get }
    var output: OutputSource { get }
    
    func concatInput()
    func concatOutput()
}
