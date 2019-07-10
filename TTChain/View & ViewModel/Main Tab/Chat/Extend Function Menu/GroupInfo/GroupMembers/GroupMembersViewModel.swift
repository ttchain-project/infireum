//
//  GroupMembersViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/9.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GroupMembersViewModel:KLRxViewModel {
    
    struct Input {
        let groupId:String
        let groupMembers:[GroupMemberModel]
    }
    
    required init(input: Input, output: Void) {
        self.input = input
        self.output = output
    }
    
    lazy var groupMembers:BehaviorRelay<[GroupMemberModel]> = { BehaviorRelay.init(value:input.groupMembers) }()
    var input: Input
    var output: Void
    
    func concatInput() {
        
    }
    func concatOutput() {
        
    }
    
    var bag: DisposeBag = DisposeBag()
    
    typealias InputSource = Input
    typealias OutputSource =  Void

}
