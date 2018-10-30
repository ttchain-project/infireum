//
//  ChangeAssetViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/25.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChangeAssetViewModel: KLRxViewModel {
    struct Input {
        let wallet: Wallet
        let selectedCoin: Coin
        let selectRowInput: Driver<Int>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    
    var input: ChangeAssetViewModel.Input
    
    struct Output {
        let handleAssetSelect: (Asset) -> Void
    }
    
    var output: ChangeAssetViewModel.Output
    
    var bag: DisposeBag = DisposeBag.init()
    
    lazy var assets: BehaviorRelay<[Asset]> = {
        let pred = Asset.genPredicate(fromIdentifierType:
            IdentifierUnit.str(
                keyPath: #keyPath(Asset.walletEPKey),
                value: input.wallet.encryptedPKey!
            )
        )
        
        let _assets = Asset.getAllWalletAssetsUnderCurrenIdentity(wallet: input.wallet, selectedOnly: true)
        guard _assets.count > 0 else {
            return errorDebug(response: BehaviorRelay.init(value: []))
        }
        
        return BehaviorRelay.init(value: _assets)
    }()
    
    fileprivate var amtSourceMap: [String : BehaviorRelay<BehaviorRelay<Decimal?>>] = [:]
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.selectedCoin = input.selectedCoin
        self.output = output
        self.concatInput()
        self.concatOutput()
        bindInternalLogic()
    }
    
    private var selectedCoin: Coin
    public func isCoinSelected(_ coin: Coin) -> Bool {
        return coin.identifier == selectedCoin.identifier
    }
    
    func concatInput() {
        input.selectRowInput
            .map {
                [unowned self] row -> Asset? in
                guard row < self.assets.value.count else {
                    return nil
                }
                
                return self.assets.value[row]
            }
            .filter { $0 != nil }
            .drive(onNext: {
                [unowned self]
                asset in
                self.output.handleAssetSelect(asset!)
                self.selectedCoin = asset!.coin!
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        assets
            .subscribe(onNext: {
                [unowned self]
                _assets in
                self.createSourceMap(of: _assets)
            })
            .disposed(by: bag)
    }
    
    func amtSource(of asset: Asset) -> BehaviorRelay<BehaviorRelay<Decimal?>> {
        if let source = amtSourceMap[asset.coinID!] {
            return source
        }else {
            amtSourceMap[asset.coinID!] = BehaviorRelay.init(value: createSourceMap(of: asset))
            return amtSource(of: asset)
        }
    }
    
    private func createSourceMap(of assets: [Asset]) {
        amtSourceMap = [:]
        guard !assets.isEmpty else { return }
        for asset in assets {
            amtSourceMap[asset.coinID!] = BehaviorRelay.init(value: createSourceMap(of: asset))
        }
    }
    
    private func createSourceMap(of asset: Asset) -> BehaviorRelay<Decimal?> {
        let source = BehaviorRelay.init(value: asset.amount as Decimal?)
        
        updateAssetAmt(asset).subscribe(onNext: {
            amt in
            source.accept(amt)
            if let _amt = amt {
                asset.updateAmt(_amt)
            }
        })
        .disposed(by: bag)
        
        return source
    }
    
    fileprivate func updateAssetAmt(_ asset: Asset) -> Observable<Decimal?> {
        return asset.getAmtFromServerIfPossible().asObservable()
    }
}
