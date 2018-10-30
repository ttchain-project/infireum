//
//  AddressBookViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddressBookViewModel: KLRxViewModel {
    struct Input {
        let identity: Identity
        let mainCoinIDLimit: String?
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: AddressBookViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
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
    public var units: Observable<[AddressBookUnit]> {
        return _units.asObservable()
    }
    
    //MARK: - Private
    private lazy var _units: BehaviorRelay<[AddressBookUnit]> = {
        let units: [AddressBookUnit] =
            (input.identity.addressbookUnits?.array as? [AddressBookUnit]) ?? []
        let relay = BehaviorRelay.init(value: units)
        Server.instance.getAddressbook(identity: input.identity).map {
            result -> [AddressBookUnit] in
            switch result {
            case .success(let model):
                return model.abUnitResources.syncToDatabase()
            case .failed(let error):
                //TODO: error shuold be sent to view controller here.
                return []
            }
        }
        .asObservable()
        .bind(to: relay)
        .disposed(by: bag)
    
        return relay
    }()
    
    private func refresh() {
        guard let dbUnits = DB.instance.get(type: AddressBookUnit.self, predicate: nil, sorts: nil) else {
            return
        }
        
        _units.accept(dbUnits)
    }
    
    public func isUnitSelectable(_ unit: AddressBookUnit) -> Bool {
        guard let limitID = input.mainCoinIDLimit else { return true }
        return unit.mainCoinID == limitID
    }
}
