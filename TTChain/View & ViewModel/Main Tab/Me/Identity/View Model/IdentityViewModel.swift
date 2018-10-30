//
//  IdentityViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IdentityViewModel: KLRxViewModel {
    struct Input {
        let identity: Identity
        let backupIdentityInput: Driver<Void>
        let clearIdentityInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: IdentityViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
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
    
    //MARK: - Public
    public var name: Observable<String> {
        return _name.asObservable()
    }
    
    public func updateName(to name: String) {
        input.identity.name = name
        if DB.instance.update() {
            _name.accept(name)
            OWRxNotificationCenter.instance.updateIdentity(input.identity)
        }
    }
    
    public var id: Observable<String> {
        return Observable.just(input.identity.id!)
    }
    
    public var onStartBackupIdentity: Driver<Identity> {
        return input.backupIdentityInput.map { [unowned self] in self.input.identity }
    }
    
    public var onStartClearIdentity: Driver<Identity> {
        return input.clearIdentityInput.map { [unowned self] in self.input.identity }
    }
    
    //MARK: - Private
    private lazy var _name: BehaviorRelay<String> = {
        return BehaviorRelay.init(value: input.identity.name!)
    }()
}
