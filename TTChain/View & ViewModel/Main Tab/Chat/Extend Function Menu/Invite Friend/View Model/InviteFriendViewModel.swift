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
    
    
    
//    func invite(person: Person, successed: (String) -> Void, failed: (String) -> Void) {
//        let status: Bool = true
//
//        // to do something
//
//        status ? successed("已送出交友邀请") : failed("错误提示讯息")
//    }
    
//    func invite(person: Person, result: (_ status: Bool, _ message: String) -> Void) {
//        let status: Bool = true
//        
//        // to do something
//        
//        result(status, status ? "Invite is successed" : "Invite is failed")
//    }
}
