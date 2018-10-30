//
//  IdentityQRCodeImportViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import RxDataSources

struct QRCodeWalletUnitSectionModel: SectionModelType {
    typealias Item = IdentityQRCodeContentWalletUnit
    var items: [Item]
    init(walletUnits: [Item]) {
        self.items = walletUnits
    }
    
    init(original: QRCodeWalletUnitSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

class IdentityQRCodeImportViewModel: KLRxViewModel {
    struct Input {
        let infoContent: IdentityQRCodeContent
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    var input: IdentityQRCodeImportViewModel.InputSource
    var output: IdentityQRCodeImportViewModel.OutputSource
    
    let systemWalletSection: Int = 0
    let importedWalletSection: Int = 1
    
    private(set) lazy var systemWallets: BehaviorRelay<[IdentityQRCodeContentWalletUnit]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    private(set) lazy var importedWallets: BehaviorRelay<[IdentityQRCodeContentWalletUnit]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    lazy var datasource: RxTableViewSectionedReloadDataSource<QRCodeWalletUnitSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<QRCodeWalletUnitSectionModel>.init(configureCell: { (source, tv, idxPath, wallet) -> UITableViewCell in
            fatalError()
        })
        
        return source
    }()
    
    lazy var sectionModelSources: Observable<[QRCodeWalletUnitSectionModel]> = {
        Observable.combineLatest(
            systemWallets.asObservable(), importedWallets.asObservable()
            )
            .map {
                (arg) -> [QRCodeWalletUnitSectionModel] in
                let (sysWallets, impWallets) = arg
                return [
                    QRCodeWalletUnitSectionModel(walletUnits: sysWallets),
                    QRCodeWalletUnitSectionModel(walletUnits: impWallets)
                ]
        }
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        systemWallets.accept(input.infoContent.systemWallets)
        importedWallets.accept(input.infoContent.importedWallets)
    }
    
    func concatOutput() {
        
    }
    
    private(set) lazy var currentLocalWallets: [Wallet] = {
        guard let identity = Identity.singleton else { return [] }
        guard let wallets = identity.wallets?.array as? [Wallet] else {
            return []
        }
        
        return wallets
    }()
    
    public func isWalletUnitExistInLocal(_ unit: IdentityQRCodeContentWalletUnit) -> Bool {
        guard !currentLocalWallets.isEmpty else { return false }
        
        for wallet in currentLocalWallets {
            if wallet.address == unit.address {
                return true
            }
        }
        
        return false
    }
}
