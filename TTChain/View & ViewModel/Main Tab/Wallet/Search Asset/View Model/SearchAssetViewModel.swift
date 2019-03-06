//
//  SearchAssetViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/28.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchAssetViewModel: KLRxViewModel, RxNetworkReachabilityRespondable {
    
    class CoinSource {
        var type: CoinSourceType
        var selection: CoinSelection?
        
        init(type: CoinSourceType, selection: CoinSelection?) {
            self.type = type
            self.selection = selection
        }
    }
    
    enum CoinSourceType {
        case remote(CoinsAPIModel.CoinSource)
        case local(Coin)
        
        var name: String {
            switch self {
            case .local(let c): return c.inAppName!
            case .remote(let s): return s.inAppName
            }
        }
        
        var fullname: String {
            switch self {
            case .local(let c): return c.fullname!
            case .remote(let s): return s.fullName
            }
        }
        
        var contract: String? {
            switch self {
            case .local(let c): return c.contract
            case .remote(let s): return s.contract
            }
        }
    }
    
    typealias InputSource = Input
    struct Input {
        let wallet: Wallet
    }
    
    var input: Input
    
    typealias OutputSource = Void
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    var networkBag: DisposeBag = DisposeBag.init()
    
    private(set) var isNetworkReachableNow: Bool = true
    
    lazy var results: BehaviorRelay<[CoinSource]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        bindInternalLogic()
        monitorNetwork { [unowned self] (status) in
            self.isNetworkReachableNow = status.hasNetwork
        }
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        searchString
            .throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .debug("Update content")
            .flatMapLatest {
                [unowned self] in
                return self.updateResult(forSearchString: $0)
            }
            .bind(to: results)
            .disposed(by: bag)
    }
    
    private let searchString: BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    //MARK: - Public Request Fetcher
    public func update(searchString text: String?) {
        searchString.accept(text)
    }
    
    //MARK: - Network Request
    private func updateResult(forSearchString text: String?) -> Observable<[CoinSource]> {
        guard let _text = text?.lowercased(), _text.count > 0 else {
            return Observable.just([]).concat(Observable.never())
        }
        
        let localCoins = Coin.getAllCoins(of: input.wallet.mainCoin!)
        
        let localMatchedPatternsCoins = localCoins.filter { (coin) -> Bool in
            let name = coin.inAppName!.lowercased()
            let fullName = coin.fullname!.lowercased()
            if name.contains(_text) {
                return true
            }else if fullName.contains(_text) {
                return true
            }else if let contract = coin.contract?.lowercased(), contract.contains(_text) {
                return true
            }else {
                return false
            }
        }
        
        let localSources = localMatchedPatternsCoins.map {
            coin -> CoinSource in
            if let sels = coin.coinSelections?.array as? [CoinSelection],
                let selIdx = sels.index(where: { (sel) -> Bool in
                    return sel.wallet! == input.wallet
                }) {
                //Means local db contains a selection of this coin in this wallet
                let sel = sels[selIdx]
                return CoinSource(type: .local(coin), selection: sel)
            }else {
                //Means there's no selection record of this coin in this wallet in local db.
                return CoinSource(type: .local(coin), selection: nil)
            }
        }
        
        if isNetworkReachableNow {
            //Get the data via api
            //Second, map the remote source with local selection (optional).
            return Server.instance.getCoins(
                queryString: _text,
                chainType: self.input.wallet.owChainType,
                defaultOnly: false,
                mainCoinID: self.input.wallet.walletMainCoinID!
                )
                .asObservable()
                .map({ (result) in
                    switch result {
                    case .failed(error: let err):
                        warning(err.descString)
                        return localSources
                    case .success(let model):
                        return model.sources.map {
                            source in
                            //Try to find if there's same source from local,
                            //if so, use the local source, as it has the selection state
                            //if not, use remote source.
                            if let localIdx = localSources.index(where: { (localSource) -> Bool in
                                switch localSource.type {
                                case .local(let c): return c.identifier! == source.identifier
                                case .remote: return false
                                }
                            }) {
                                return localSources[localIdx]
                            } else {
                                return CoinSource(type: .remote(source), selection: nil)
                            }
                        }
                    }
                })
        }else {
            //Get the data via local database.
            return Observable.just(localSources).concat(Observable.never())
        }
    }
    
    //MARK: - Publis Insert/Delete API
    func changeCoinInSelectionDatabase(coinIdx idx: Int, isInSelection: Bool) -> Bool {
        guard idx < results.value.count else {
            return errorDebug(response: false)
        }
        
        let newSources = results.value
        let targetSource = newSources[idx]
        if isInSelection {
            guard let sel = addCoinIntoDBSelectionList(fromIdx: idx) else {
                return errorDebug(response: false)
            }
            
            targetSource.type = .local(sel.coin!)
            targetSource.selection = sel
        }else {
            guard deleteCoin(fromIdx: idx) else {
                return errorDebug(response: false)
            }
            
            targetSource.selection = nil
        }
        
        return true
    }
    
    //MARK: - CoinSelection Insertion
    private func addCoinIntoDBSelectionList(fromIdx idx: Int) -> CoinSelection? {
        
        // IMPORTANT: The coin to add should checked already exist in local DB.
        //
        // Fist, "CREATE" the CoinSelection,
        // second, "SYNC" the Asset (db might has the asset of this coin before.)
        // Deletion works in vice versa.
        guard idx < results.value.count else {
            return errorDebug(response: nil)
        }
        
        let source = results.value[idx]
        guard source.selection == nil else {
            return errorDebug(response: nil)
        }
        
        let coin: Coin
        switch source.type {
        case .local(let c):
            //Means this coin is already in database
            coin = c
        case .remote(let s):
            //Means this coin is not in databse, create the coin first
            guard let c = Coin.syncEntities(
                constructors:  Coin.createConstructorsFromServerAPIModelSources([s]),
                returnNewEntitiesOnly: true
            )?.first else {
                return errorDebug(response: nil)
            }
            
            coin = c
        }
        
        // Attempt to mark the CoinSelection selected to the db.
        let wallet = input.wallet
        guard let sel = CoinSelection.markSelection(
            of: wallet, coin: coin, isSelected: true
        ) else {
            return errorDebug(response: nil)
        }
        
        OWRxNotificationCenter.instance.didInsertCoinSelection(sel)
        print("Finish mark selectino of coin: \(coin.inAppName ?? "")")
        print("The sel we get is in coin: \(sel.coin?.inAppName ?? "")")
        return sel
    }
    
    //MARK: - CoinSelection Deletion
    private func deleteCoin(fromIdx idx: Int) -> Bool {
        guard idx < results.value.count else {
            return errorDebug(response: false)
        }
        
        let source = results.value[idx]
        guard let sel = source.selection else {
            return errorDebug(response: false)
        }
        
        if let _asset = sel.findAsset() {
            DB.instance.managedObjectContext.delete(_asset)
        }
        
        OWRxNotificationCenter.instance.willDeleteCoinSelection(sel)
        DB.instance.managedObjectContext.delete(sel)
        DB.instance.update()
        
        return true
    }
    
//    //MARK: - Helper
//    func getLocalCoinSelectionFromSourceIfPossible(_ source: CoinSource) -> CoinSelection? {
//        if let sel = source.selection {
//            return sel
//        }
//
//        let identifier: String
//        switch source.type {
//        case .local(let coin): identifier = coin.identifier!
//        case .remote(let coinSource): identifier = coinSource.identifier
//        }
//
//        let sels = CoinSelection.getAllSelections(of: input.wallet, filterIsSelected: false)
//        if let idx = sels.index(where: { (sel) -> Bool in
//            return sel.coin!.identifier! == identifier
//        }) {
//            return sels[idx]
//        }else {
//            return nil
//        }
//    }
}
