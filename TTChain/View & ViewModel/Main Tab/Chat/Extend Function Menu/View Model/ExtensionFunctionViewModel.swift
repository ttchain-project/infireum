//
//  ExtensionFunctionViewModel.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/23.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

struct ChatExtensionFunction {
    var image: UIImage? = nil
    var title: String = ""
    
    init() {}
    
    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
    }
}

struct ChatExtensionFunctions: SectionModelType {
    typealias Item = ChatExtensionFunction
    
    var title: String
    var items: [Item]
    
    init(original: ChatExtensionFunctions, items: [ChatExtensionFunction]) {
        self = original
        self.title = ""
        self.items = items
    }
    
    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}

class ExtensionFunctionViewModel: KLRxViewModel {
    required init(input: ExtensionFunctionViewModel.Input, output: ExtensionFunctionViewModel.Output) {
        
        self.input = input
        self.output = output
    }
    
    var input: ExtensionFunctionViewModel.Input
    
    var output: ExtensionFunctionViewModel.Output
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Output
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {

    }
    
    struct Output {
        
    }
}
