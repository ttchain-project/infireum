//
//  AddressBookUnitBrowseViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddressBookUnitBrowseViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let unit: AddressBookUnit
        let copyAddrInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: AddressBookUnitBrowseViewModel.Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        OWRxNotificationCenter.instance.addressBookUpdate.subscribe(onNext: {
            [unowned self] in self.refresh()
        })
        .disposed(by: bag)
    }
    
    //MARK: - Public
    public var unit: Observable<AddressBookUnit> {
        return _unit.asObservable()
    }
    
    public func getUnit() -> AddressBookUnit {
        return _unit.value
    }
    
    public func updateUnit(_ unit: AddressBookUnit) {
        _unit.accept(unit)
    }
    
    public var onAddressCopied: Driver<Void> {
        return input.copyAddrInput.map {
            [unowned self] in
            self.copyAddr()
        }
    }
    
    
    
    //MARK: - Private
    private lazy var _unit: BehaviorRelay<AddressBookUnit> = {
       return BehaviorRelay.init(value: input.unit)
    }()
    
    private func copyAddr() {
        UIPasteboard.general.string = _unit.value.address!
    }
    
    private func refresh() {
        _unit.accept(_unit.value)
    }
}
