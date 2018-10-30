//
//  UpdatetABUnitAddressViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ABEditSourceType {
    case abUnit(AddressBookUnit)
    case plain(mainCoinID: String)
    case scannedSource(addr: String, mainCoinID: String)
    
    var mainCoinID: String {
        switch self {
        case .abUnit(let unit): return unit.mainCoinID!
        case .plain(let id), .scannedSource(addr: _, mainCoinID: let id):
            return id
        }
    }
    
    var chainType: ChainType {
        switch self {
        case .abUnit(let unit): return ChainType.init(rawValue: unit.chainType)!
        case .plain(let id), .scannedSource(addr: _, mainCoinID: let id):
            let coin = Coin.getCoin(ofIdentifier: id)!
            return coin.owChainType
        }
    }
    
    var address: String? {
        switch self {
        case .abUnit(let unit):
            return unit.address
        case .plain:
            return nil
        case .scannedSource(addr: let addr, mainCoinID: _):
            return addr
        }
    }
}

class UpdatetABUnitAddressViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    struct Input {
        let sourceType: ABEditSourceType
        let addressInout: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: UpdatetABUnitAddressViewModel.Input
    var output: Void
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        (input.addressInout <-> _address).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var isInfoValid: Observable<Bool> {
        return _address.map { $0?.count ?? 0 }.map { $0 > 0 }
    }
    
    public var mainCoin: Observable<Coin> {
        return _mainCoinID.map { Coin.getCoin(ofIdentifier: $0)! }
    }
    
    public var mainCoinID: Observable<String> {
        return _mainCoinID.asObservable()
    }
    
    public func deleteAddressInfo() {
        switchSourceType(to: .plain(mainCoinID: _mainCoinID.value))
    }
    
    public var address: Observable<String?> {
        return _address.asObservable()
    }
    
    public func updateAddress(to addr: String) {
        _address.accept(addr)
    }
    
    public func updateMainCoinID(to id: String) {
        _mainCoinID.accept(id)
    }
    
    public func getMainCoinID() -> String {
        return _mainCoinID.value
    }
    
    public func getAddressInfo() -> (addr: String, mainCoinID: String)? {
        guard let _addr = _address.value, _addr.count > 0 else { return nil }
        return (addr: _addr, mainCoinID: _mainCoinID.value)
    }
    
    
    //MARK: - Private
    private lazy var _mainCoinID: BehaviorRelay<String> = {
       return BehaviorRelay.init(value: input.sourceType.mainCoinID)
    }()
    
    private lazy var _address: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: input.sourceType.address)
    }()
    
    private func switchSourceType(to type: ABEditSourceType) {
        _mainCoinID.accept(type.mainCoinID)
        _address.accept(type.address)
    }
}
