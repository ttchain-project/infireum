//
//  WithdrawalConfirmChangeWalletViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalConfirmChangeWalletViewModel: KLRxViewModel {
    struct Input {
        let rowSelect: Driver<Int>
        let info: WithdrawalInfo
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WithdrawalConfirmChangeWalletViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
    }
    
    func concatInput() {
        input.rowSelect
            .map {
                [unowned self] in self._assets.value[$0]
            }
            .filter {
                [unowned self] in return self.isAssetUsable($0)
            }
            .drive(_selectedAsset)
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var assets: Observable<[Asset]> {
        return _assets.asObservable()
    }
    
    public func isAssetUsable(_ asset: Asset) -> Bool {
        let targetAmt = input.info.withdrawalAmt
        return asset.amount! as Decimal >= targetAmt
    }
    
    public func isAssetSelected(_ asset: Asset) -> Bool {
        return asset == _selectedAsset.value
    }
    
    public var selectedAsset: Observable<Asset> {
        return _selectedAsset.asObservable()
    }
    
    //MARK: - Private
    private lazy var _assets: BehaviorRelay<[Asset]> = {
        return BehaviorRelay.init(value: getAllAvaiableAssets())
    }()
    
    private lazy var _selectedAsset: BehaviorRelay<Asset> = {
        return BehaviorRelay.init(value: input.info.asset)
    }()
    
    private func getAllAvaiableAssets() -> [Asset] {
        let asset = input.info.asset
        guard let allAssetsHasTheSameCoin = asset.coin!.assets?.array as? [Asset] else {
            return [asset]
        }
        
        return allAssetsHasTheSameCoin
    }
    
    
}
