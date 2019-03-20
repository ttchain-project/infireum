//
//  ChangeWalletViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/30.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct WalletSectionModel: SectionModelType {
    typealias Item = Wallet
    var items: [Wallet]
    init(wallets: [Wallet]) {
        self.items = wallets
    }
    
    init(original: WalletSectionModel, items: [Wallet]) {
        self = original
        self.items = items
    }
}

class ChangeWalletViewModel: KLRxViewModel, RxNetworkReachabilityRespondable {
    var bag: DisposeBag = DisposeBag.init()
    var networkBag: DisposeBag = DisposeBag.init()
    
    struct Input {
        /** This instance determine if the view model
            should enable only wallets with specific
            asset to be selected. */
        let assetSupportLimit: Asset?
        let walletSelectIdxPathInput: Driver<IndexPath>
    }
    
    typealias InputSource = Input
    var input: ChangeWalletViewModel.Input
    
    typealias OutputSource = Void
    var output: Void
    
    let systemWalletSection: Int = 0
    let importedWalletSection: Int = 1
    private(set) lazy var assets: BehaviorRelay<[Asset]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    lazy var onWalletSelect: Observable<Wallet> = {
        return input.walletSelectIdxPathInput.debug("Select Wallet: Row selected").asObservable().flatMapLatest {
            [unowned self] idxPath -> Observable<Wallet> in
//            if idxPath.section == self.systemWalletSection  {
//                source = self.systemWallets.asObservable()
//            }else {
//                source = self.importedWallets.asObservable()
//            }
            
            return self.assets
                .map { $0[idxPath.row] }
                .filter {
                    [unowned self] in self.isAbleToSelectWallet(withAsset:$0)
                }.map {
                    $0.wallet!
                }
                .debug("Select Wallet: Event Sent to view controller")
                .take(1)
                .concat(Observable.never())
        }
    }()
    
    lazy var onAssetSelected: Observable<Asset> = {
        return input.walletSelectIdxPathInput.debug("Select Wallet: Row selected").asObservable().flatMapLatest {
            [unowned self] idxPath -> Observable<Asset> in
            return self.assets
                .map { $0[idxPath.row] }
                .filter {
                    [unowned self] in self.isAbleToSelectWallet(withAsset:$0)
                }
                .debug("Select Wallet: Event Sent to view controller")
                .take(1)
                .concat(Observable.never())
        }
    }()
    
    lazy var sectionModelSources: Observable<[WalletSectionModel]> = {
        Observable.combineLatest(
            systemWallets.asObservable(), importedWallets.asObservable()
            )
            .map {
                sysWallets, impWallets -> [WalletSectionModel] in
                return [
                    WalletSectionModel(wallets: sysWallets),
                    WalletSectionModel(wallets: impWallets)
                ]
            }
    }()
    
    lazy var datasource: RxTableViewSectionedReloadDataSource<WalletSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<WalletSectionModel>.init(configureCell: { (source, tv, idxPath, wallet) -> UITableViewCell in
            fatalError()
        })
        
        return source
    }()
    
    private(set) lazy var systemWallets: BehaviorRelay<[Wallet]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    private(set) lazy var importedWallets: BehaviorRelay<[Wallet]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    lazy var isNetworkReachable: PublishRelay<Bool> = {
        return PublishRelay.init()
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        
        refreshWallets()
        
        monitorLocalWalletsUpdate()
        monitorNetwork { [unowned self] (status) in
            self.isNetworkReachable.accept(status.hasNetwork)
        }
    }
    
    private func monitorLocalWalletsUpdate() {
        let imported = OWRxNotificationCenter.instance.walletsImported
            .map { _ in () }
        let deleted = OWRxNotificationCenter.instance.walletDeleted
            .map { _ in () }
    
        Observable.merge(imported, deleted)
            .subscribe(onNext: {
                [weak self]
                _ in
                self?.refreshWallets()
            })
            .disposed(by: bag)
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    func refreshWallets() {
        
//        guard let wallets = DB.instance.get(type: Wallet.self, predicate: nil, sorts: nil) else {
//            return errorDebug(response: ())
//        }
        let predicate = Asset.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Asset.coinID), value: (self.input.assetSupportLimit?.coinID)!))
      
        guard let assets = DB.instance.get(type: Asset.self, predicate: predicate, sorts: nil) else {
            return errorDebug(response: ())
        }
        
//        var sysWallets: [Wallet] = []
//        var impWallets: [Wallet] = []
//
        self.assets.accept(assets.sorted { $0.wallet!.name! <= $1.wallet!.name!  } )
//        systemWallets.accept(wallets.sorted { $0.name! <= $1.name! })
//        importedWallets.accept(impWallets.sorted { $0.name! <= $1.name! })
    }
    
    public func isAbleToSelectWallet(withAsset asset:Asset) -> Bool {
        return (asset.amount! as Decimal) != 0
    }
    
    //MARK: - Helper
    public func isAbleToSelectWallet(_ wallet: Wallet) -> Bool {
        guard let assetLimit = input.assetSupportLimit else { return true }
        guard let assets = wallet.assets?.array as? [Asset] else { return false }
        
        return assets.contains(where: { (asset) -> Bool in
            asset.coinID == assetLimit.coinID
        })
    }
}
