//
//  ForwarMessageViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/29.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

class ForwarMessageViewModel: KLRxViewModel {
    var input: ForwarMessageViewModel.Input
    var output: ForwarMessageViewModel.Output
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let messages:[MessageModel]
        let roomId:String
        let avatarImage:String?
        var memberAvatarMapping: [String:String?]? = nil
        
    }
    
    struct Output {
        
    }
    
    private lazy var _messages: BehaviorRelay<[MessageModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    public var messages: Observable<[MessageModel]> {
        return _messages.asObservable().share()
    }
    
    var selectedMessages = [MessageModel]()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self._messages.accept(input.messages)
        
    }
    
}
