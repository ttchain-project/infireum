//
//  EditABUnitViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditABUnitViewModel: KLRxViewModel {
    struct Input {
        let source: ABEditSourceType
        let nameInout: ControlProperty<String?>
        let noteInout: ControlProperty<String?>
        let addressInput: Observable<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: EditABUnitViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        //TODO: Accept name and note.
        switch input.source {
        case .abUnit(let unit):
            _name.accept(unit.name!)
            _note.accept(unit.note!)
        case .plain: break
        case .scannedSource(addr: let addr, mainCoinID: let id):
            break
        }
        
        (input.nameInout <-> _name).disposed(by: bag)
        (input.noteInout <-> _note).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }

    public var isAllFieldsHasValue: Observable<Bool> {
        let addressValid = input.addressInput.map { $0?.count ?? 0 }.map { $0 > 0 }
        let nameValid = _name.map { $0?.count ?? 0 }.map { $0 > 0 }
        return Observable.combineLatest(addressValid, nameValid).map { $0 && $1 }
    }
    
    public func save(mainCoinID: String, address: String) -> RxAPIResponse<AddressBookUnit> {
        
        let chainType = Coin.getCoin(ofIdentifier: mainCoinID)!.owChainType
        let name = _name.value
        let note = _note.value
        switch input.source {
        case .abUnit(let unit):
            //TODO: Send start indicator event
            if let sameInfoUnit = AddressBookUnit.findUnit(
                identity: Identity.singleton!,
                addr: address,
                mainCoinID: mainCoinID
                ) {
                guard sameInfoUnit.id! == unit.id! else {
                    let dls = LM.dls
                    let error = GTServerAPIError.incorrectResult(
                        dls.ab_update_error_unable_update_title,
                        dls.ab_update_error_already_has_same_unit_content
                    )
                    
                    return RxAPIResponse.just(.failed(error: error))
                }
            }
            
            return Server.instance.updateAddressBookUnit(
                identity: unit.identity!,
                unitID: unit.id!,
                chainType: chainType,
                mainCoinID: mainCoinID,
                address: address,
                name: name!,
                note: note
                )
                .map {
                    result in
                    switch result {
                    case .failed(let error):
                        return RxAPIResponse.ElementType.failed(error: error)
                    case .success(_):
                        unit.name = name
                        unit.address = address
                        unit.chainType = chainType.rawValue
                        unit.note = note
                        unit.mainCoinID = mainCoinID
                        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
                        unit.mainCoin = coin
                        coin.addToAsMainInAddressbookUnits(unit)
                        
                        DB.instance.update()
                        
                        OWRxNotificationCenter.instance.notifyAddressBookUpdate()
                        return RxAPIResponse.ElementType.success(unit)
                    }
            }
            
        case .plain, .scannedSource:
            //TODO: Send start indicator event
            guard AddressBookUnit.findUnit(
                identity: Identity.singleton!,
                addr: address,
                mainCoinID: mainCoinID
                ) == nil
                else {
                    let dls = LM.dls
                    let error = GTServerAPIError.incorrectResult(
                        dls.ab_update_error_unable_create_title,
                        dls.ab_update_error_already_has_same_unit_content
                    )
                    
                    return RxAPIResponse.just(.failed(error: error))
                }
            
            let identity = Identity.singleton!
            let unitID = UUID.init().uuidString
            return Server.instance.createAddressBookUnit(
                identity: identity,
                unitID: unitID,
                chainType: chainType,
                mainCoinID: mainCoinID,
                address: address,
                name: name!,
                note: note
                )
                .map {
                    result in
                    switch result {
                    case .success:
                        guard let newUnit = DB.instance.create(type: AddressBookUnit.self, setup: { (unit) in
                            unit.id = unitID
                            unit.name = name
                            unit.address = address
                            unit.chainType = chainType.rawValue
                            unit.identity = identity
                            unit.identityID = identity.id
                            unit.note = note
                            unit.mainCoinID = mainCoinID
                            let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
                            unit.mainCoin = coin
                            coin.addToAsMainInAddressbookUnits(unit)
                            identity.addToAddressbookUnits(unit)
                        }) else {
                            return errorDebug(response: .failed(error: GTServerAPIError.noData))
                        }
                    OWRxNotificationCenter.instance.notifyAddressBookUpdate()
                        
                        return RxAPIResponse.ElementType.success(newUnit)
                    case .failed(error: let error):
                        return RxAPIResponse.ElementType.failed(error: error)
                    }
                }
        }
    }
    
    public func delete() -> RxAPIVoidResponse {
        switch input.source {
        case .abUnit(let unit):
        //TODO: Send start indicator event
            return Server.instance.deleteAddressBookUnit(
                identity: unit.identity!,
                unitID: unit.id!,
                chainType: ChainType.init(rawValue: unit.chainType)!,
                mainCoinID: unit.mainCoinID!
                ).map {
                    result in
                    switch result {
                    case .failed(error: let err):
                        return RxAPIVoidResponse.ElementType.failed(error: err)
                    case .success:
                        guard DB.instance.delete(type: AddressBookUnit.self, predicate: AddressBookUnit.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(AddressBookUnit.id), value: unit.id!))) else {
                            return errorDebug(response: .success(()))
                        }
                        
                        OWRxNotificationCenter.instance.notifyAddressBookUpdate()
                        return RxAPIVoidResponse.ElementType.success(())
                    }
                }
        case .plain, .scannedSource:
            //Becuase plain type means there's no unit now, should not call the delete() function.
            return errorDebug(response: RxAPIVoidResponse.just(.success(())))
        }
    }
    
    private lazy var _name: BehaviorRelay<String?> = {
       return BehaviorRelay.init(value: nil)
    }()
    
    private lazy var _note: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
}
