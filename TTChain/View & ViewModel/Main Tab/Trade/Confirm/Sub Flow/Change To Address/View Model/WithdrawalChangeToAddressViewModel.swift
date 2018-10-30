//
//  WithdrawalChangeToAddressViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithdrawalChangeToAddressViewModel: KLRxViewModel {
    struct Input {
        let source: LightningTransRecordCreateSource
        let walletSelect: Driver<Wallet>
        let addressInout: ControlProperty<String?>
        let toAddressBookInput: Driver<Void>
        let toQRCodeScannerInput: Driver<Void>
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: WithdrawalChangeToAddressViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        
        bindInternalLogic()
    }
    
    func concatInput() {
        input.walletSelect.map { .local(wallet: $0) }.drive(_selectedSource).disposed(by: bag)
        (input.addressInout <-> _remoteAddress).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _remoteAddress.distinctUntilChanged()
            .map {
                str -> ToAddressSource? in
                if let _str = str, _str.count > 0 {
                    return .remote(addr: _str)
                }else {
                    return nil
                }
            }
            .bind(to: _selectedSource)
            .disposed(by: bag)
    }
    
    //MARK: Public
    public var wallets: Observable<[Wallet]> {
        return _wallets.asObservable()
    }
    
    public var selectedSource: Observable<ToAddressSource> {
        return _selectedSource.filter { $0 != nil }.map { $0! }
    }
    
    public func isWalletSelected(_ wallet: Wallet) -> Bool {
        if let source = _selectedSource.value {
            switch source {
            case .local(wallet: let w): return wallet == w
            case .remote: return false
            }
        }else {
            return false
        }
    }
    
    //Element is mainCoinID
    public var onChooseAddressFromAddressbook: Driver<String> {
        return input.toAddressBookInput.map { [unowned self] in self.input.source.to.toCoin!.walletMainCoinID! }
    }
    
    public var onScanningAddressQRCodeScanner: Driver<ChainType> {
        return input.toQRCodeScannerInput.map { [unowned self] in self.input.source.to.toCoin!.owChainType }
    }
    
    public func updateRemoteAddress(_ address: String) {
        _selectedSource.accept(.remote(addr: address))
        _remoteAddress.accept(address)
    }

    public func getSelectedSource() -> ToAddressSource? {
        return _selectedSource.value
    }
    
    public func getAssetToDisplayFromWallet(_ wallet: Wallet) -> Asset? {
        let toCoin = input.source.to.toCoin
        guard let assets = wallet.assets?.array as? [Asset],
            let assetIdx = assets.index(where: { (asset) -> Bool in
                return asset.coinID! == toCoin!.identifier!
            }) else {
            return wallet.createNewAsset(ofCoin: toCoin!)
        }
        
        return assets[assetIdx]
    }
    
    //MARK: Private
    private lazy var _wallets: BehaviorRelay<[Wallet]> = {
        return BehaviorRelay.init(value: Wallet.getWallets(ofMainCoinID:  input.source.to.toCoin!.walletMainCoinID!))
    }()
    
    private lazy var _selectedSource: BehaviorRelay<ToAddressSource?> = {
       return BehaviorRelay.init(value: input.source.to.addressSource)
    }()
    
    private lazy var _remoteAddress: BehaviorRelay<String?> = {
        var addr: String?
        switch input.source.to.addressSource {
        case .remote(let _addr): addr = _addr
        default: break
        }
        
        return BehaviorRelay.init(value: addr)
    }()
}
