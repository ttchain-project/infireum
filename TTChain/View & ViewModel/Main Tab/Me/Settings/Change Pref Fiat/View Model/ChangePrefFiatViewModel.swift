//
//  ChangePrefFiatViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChangePrefFiatViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let identity: Identity
        let fiatSelectInput: Driver<Fiat>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        input.fiatSelectInput.drive(_selectedFiat).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var selectedFiat: Observable<Fiat> {
        return _selectedFiat.asObservable()
    }
    
    public var fiats: Observable<[Fiat]> {
        return _fiats.asObservable()
    }
    
    public func isFiatSelected(_ fiat: Fiat) -> Bool {
        return _selectedFiat.value == fiat
    }
    
    public func save() {
        input.identity.fiat = _selectedFiat.value
        input.identity.prefFiatID = _selectedFiat.value.id
        if DB.instance.update() {
            OWRxNotificationCenter.instance.notifyPrefFiatUpdate(fiat: _selectedFiat.value)
        }
    }
    
    //MARK: - Private
    private lazy var _selectedFiat: BehaviorRelay<Fiat> = {
        return BehaviorRelay.init(value: input.identity.fiat!)
    }()
    
    private lazy var _fiats: BehaviorRelay<[Fiat]> = {
        let fiats = DB.instance.get(type: Fiat.self, predicate: nil, sorts: nil)!.sorted(by: { $0.name! < $1.name! })
        
        return BehaviorRelay.init(value: fiats)
    }()
}
