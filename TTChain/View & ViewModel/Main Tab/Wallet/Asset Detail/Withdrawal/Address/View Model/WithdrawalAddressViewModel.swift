//
//  WithdrawalAddressViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum WithdrawalAddressValidity {
    case emptyToAddress
    case valid
}

protocol WithdrawalAddressInfoProvider {
    var hasValidInfo: Observable<Bool> { get }
    func checkInfoValidity() -> WithdrawalAddressValidity
    func getFromAsset() -> Asset
    func getToAddress() -> String?
    func changeFromAsset(_ asset: Asset)
    func changeToAddress(_ addr: String)
    
}

class WithdrawalAddressViewModel: KLRxViewModel, WithdrawalAddressInfoProvider {
    struct Input {
        let asset: Asset
        let toAddressInout: ControlProperty<String?>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: WithdrawalAddressViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        (input.toAddressInout <-> _toAddress).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - WithdrawalAddressInfoProvider
    public var hasValidInfo: Observable<Bool> {
        return _toAddress.map { $0?.count ?? 0 > 0 }
    }
    
    func checkInfoValidity() -> WithdrawalAddressValidity {
        guard let addr = _toAddress.value, addr.count > 0 else { return .emptyToAddress }
        return .valid
    }
    
    func getFromAsset() -> Asset {
        return _asset.value
    }
    
    func getToAddress() -> String? {
        return _toAddress.value
    }
    
    //MARK: - Public
    public var fromAsset: Observable<Asset> {
        return _asset.asObservable()
    }
    
    public func changeFromAsset(_ asset: Asset) {
        _asset.accept(asset)
    }
    
    public func changeToAddress(_ addr: String) {
        _toAddress.accept(addr)
    }
    
    //MARK: - Private
    private lazy var _asset: BehaviorRelay<Asset> = {
        return BehaviorRelay.init(value: input.asset)
    }()
    
    private lazy var _toAddress: BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: nil)
    }()
}
