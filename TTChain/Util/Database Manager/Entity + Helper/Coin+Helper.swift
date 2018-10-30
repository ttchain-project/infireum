//
//  Coin+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
import AlamofireImage

import RxSwift
import RxCocoa
import RxOptional
class CoinSyncHandler {
    typealias CoinSyncMap = [String : Date]
    static private let kSyncKey = "CoinSyncDicrionary"
    static func getSyncDateOfCurrentVersion() -> Date? {
        return getSyncDate(ofVersion: C.Application.version)
    }
    
    static func getSyncDate(ofVersion version: String) -> Date? {
        return getSyncMap()?[version]
    }
    
    static func syncCoinsIfNeeded(forVersion version: String) -> RxAPIVoidResponse {
        guard let map = getSyncMap(),
            let date = map[version] else {
                #if DEBUG
                print("Detect empty syns date for version: \(version)")
                print("Now will start to sync coins")
                #endif
                return syncCoins(forVersion: version)
        }
        
        #if DEBUG
        print("Detect syns date: \(date) for version: \(version)")
        print("Now will skip the sync coins step")
        #endif
        
        //Can add some extra date inverval chech in here.
        return RxAPIVoidResponse.just(.success(()))
    }
    
    static func syncCoins(forVersion version: String) -> RxAPIVoidResponse {
        let req = Server.instance.getCoins(queryString: nil, chainType: nil, defaultOnly: true, mainCoinID: nil)
        let currentCoins = DB.instance.get(type: Coin.self, predicate: nil, sorts: nil) ?? []
        
        return req
            .map {
            result in
            switch result {
            case .failed(error: let err): return .failed(error: err)
            case .success(let model):
                let newCoinSources = model.sources 
                let findLocalCoinWithCoinIdentifier: (String) -> Coin? = {
                    identifier in
                    guard !currentCoins.isEmpty else { return nil }
                    if let idx = currentCoins.index(where: { (coin) -> Bool in
                        return coin.identifier == identifier
                    }) {
                        return currentCoins[idx]
                    }else {
                        return nil
                    }
                }
                
                var insertNeededCoinSources: [CoinsAPIModel.CoinSource] = []
                var updateFlag: Bool = false
                for newSource in newCoinSources {
                    if let coin = findLocalCoinWithCoinIdentifier(newSource.identifier) {
                        coin.inAppName = newSource.inAppName
                        coin.chainName = newSource.chainName
                        coin.walletMainCoinID = newSource.walletMainCoinID
                        coin.fullname = newSource.fullName
                        coin.contract = newSource.contract
                        coin.digit = Int16(newSource.digit)
                        coin.isDefaultSelected = newSource.isDefaultSelected
                        coin.isActive = newSource.isActive
                        coin.isDefault = newSource.isDefault
                        if let url = URL.init(string: newSource.iconUrlStr) {
                          KLRxImageDownloader
                            .instance
                            .download(
                                source: url,
                                onComplete: { result in
                                    switch result {
                                    case .success(let img):
                                        coin.icon = UIImagePNGRepresentation(img) as NSData?
                                    default: break
                                    }
                            })
                        }
                        
                        updateFlag = true
                    }else {
                        insertNeededCoinSources.append(newSource)
                    }
                }
                
                
                
                if updateFlag {
                    DB.instance.update()
                }
                
                if !insertNeededCoinSources.isEmpty {
                    #if DEBUG
                    print("Now will start to insert new coins to local database, including:\n")
                    print(insertNeededCoinSources.map { $0.fullName })
                    #endif
                    
                    let constructors = Coin.createConstructorsFromServerAPIModelSources(
                        insertNeededCoinSources
                    )
                    
                    //After get the all insert-needed coins,
                    //Should also create selections for every default selected one.
                    Coin.syncEntities(constructors: constructors)
                }
                
                DB.instance.update()
                let allCoins = DB.instance.get(type: Coin.self, predicate: nil, sorts: nil)
                
                if let _allCoins = allCoins {
                    if getSyncDateOfCurrentVersion() == nil {
                        for coin in _allCoins where coin.isDefaultSelected {
                            let wallets = Wallet.getWallets(ofMainCoinID: coin.walletMainCoinID!)
                            for wallet in wallets {
                                print("Mark wallet: \(wallet.name!), of coin: \(coin.inAppName!)")
                                _ = CoinSelection
                                    .markSelection(
                                        of: wallet,
                                        coin: coin,
                                        isSelected: true
                                )
                            }
                        }
                    }
                    
                    //Sync main coins
                    let mainCoins = _allCoins.reduce([], { (coinIDs, coin) -> [String] in
                        if coinIDs.contains(coin.walletMainCoinID!) {
                            return coinIDs
                        }else {
                            return coinIDs + [coin.walletMainCoinID!]
                        }
                    })
                    
                    MainCoinTypStorage
                        .syncRemoteMainCoinIDs(mainCoins)
                }
                
                self.mark(version: version, toDate: Date())
                return .success(())
            }
        }
        
    }
    
    @discardableResult static func mark(version: String, toDate date: Date) -> Bool {
        var map = getSyncMap() ?? [:]
        map[version] = date
        return saveSyncMap(map)
    }
    
    static private func saveSyncMap(_ map: CoinSyncMap) -> Bool {
        guard let data = try? JSONEncoder.init().encode(map) else {
            return false
        }
        
        UserDefaults.standard.set(data, forKey: kSyncKey)
        UserDefaults.standard.synchronize()
        return true
    }
    
    static private func getSyncMap() -> CoinSyncMap? {
        guard let data = UserDefaults.standard.data(forKey: kSyncKey),
            let map = try? JSONDecoder.init().decode(CoinSyncMap.self, from: data) else {
                return nil
        }
        
        return map
    }
}

extension Coin {
    
    var isDeletable: Bool {
        let type = ChainType.init(rawValue: chainType)!
        return !type.undeletableCoinIds.contains(identifier!)
    }
    
    var iconImg: UIImage? {
        guard let _icon = icon as Data? else { return #imageLiteral(resourceName: "iconListNoimage") }
        return UIImage.init(data: _icon, scale: 1)
    }
    
    static func createConstructorsFromServerAPIModelSources(_ sources: [CoinsAPIModel.CoinSource]) -> [ManagedObejctConstructor<Coin>] {
        return sources.map {
            source -> ManagedObejctConstructor<Coin> in
            ManagedObejctConstructor<Coin>(
                idUnits: [
                    .str(keyPath: #keyPath(identifier), value: source.identifier)
                ],
                setup: {
                    coin in
                    coin.identifier = source.identifier
                    coin.contract = source.contract
                    coin.inAppName = source.inAppName
                    coin.chainName = source.chainName
                    coin.walletMainCoinID = source.walletMainCoinID
                    coin.fullname = source.fullName
                    coin.chainType = source.chainType.rawValue
                    coin.isDefault = source.isDefault
                    coin.isDefaultSelected = source.isDefaultSelected
                    coin.isActive = source.isActive
                    coin.digit = Int16(source.digit)
                    if let url = URL.init(string: source.iconUrlStr) {
                        KLRxImageDownloader.instance.download(source: url) {
                            result in
                            switch result {
                            case .failed: warning("Cannot download img from url \(source.iconUrlStr)")
                            case .success(let img):
                                coin.icon = UIImagePNGRepresentation(img) as NSData?
                                DB.instance.update()
                            }
                        }
                    }
                }
            )
        }
    }
    
    static func getAllCoinsHasSelectionInfo(of wallet: Wallet, filterUnselected: Bool) -> [Coin] {
        let sels = CoinSelection.getAllSelections(of: wallet, filterIsSelected: filterUnselected)
        let coins = sels.compactMap { $0.coin }
        if sels.count == coins.count {
            return coins
        }else {
            let preds = sels
                .map {
                    return IdentifierUnit.str(keyPath: #keyPath(Coin.identifier), value: $0.coinIdentifier!)
                }
                .map {
                    Coin.genPredicate(fromIdentifierType: $0)
                }
            
            let compoundOrPred = NSCompoundPredicate.init(orPredicateWithSubpredicates: preds)
            
            guard let dbCoins = DB.instance.get(type: Coin.self, predicate: compoundOrPred, sorts: nil) else {
                return errorDebug(response: [])
            }
            
            return dbCoins
        }
    }
    
    static func getAllCoins(of mainCoin: Coin) -> [Coin] {
        let pred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.walletMainCoinID), value: mainCoin.identifier!))
        guard let coins = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil),
            !coins.isEmpty else {
            return errorDebug(response: [])
        }
        
        return coins
    }
    
    static func getAllCoins(of chainType: ChainType) -> [Coin] {
        let pred = Coin.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Coin.chainType), value: chainType.rawValue))
        guard let coins = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil),
            !coins.isEmpty else {
                return errorDebug(response: [])
        }
        
        return coins
    }
    
    static func getCoin(ofIdentifier id: String) -> Coin? {
        let pred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.identifier), value: id))
        guard let coins = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil),
            coins.count == 1 else {
            return nil
//            return errorDebug(response: nil)
        }
        
        return coins[0]
    }
    
    static func getCoin(ofChainName name: String, chainType: ChainType) -> Coin? {
        let upperCaseName = name.uppercased()
        let pred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.chainName), value: upperCaseName))
        let chainTypePred = Coin.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Coin.chainType), value: chainType.rawValue))
        
        let compoundPred = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pred, chainTypePred])
        
        guard let coins = DB.instance.get(type: Coin.self, predicate: compoundPred, sorts: nil),
            coins.count == 1 else {
                return nil
                //            return errorDebug(response: nil)
        }
        
        return coins[0]
    }
    
    static func getCoin(ofInAppName name: String) -> Coin? {
        let pred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.inAppName), value: name))
        guard let coins = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil),
            coins.count == 1 else {
                return errorDebug(response: nil)
        }
        
        return coins[0]
    }
    
    static func getCoin(ofContractAddress address: String) -> Coin? {
        let pred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.contract), value: address))
        guard let coins = DB.instance.get(type: Coin.self, predicate: pred, sorts: nil),
            coins.count == 1 else {
                return nil
        }
        
        return coins[0]
    }
}

//MAKR: - System Quick Coin Finder
extension Coin {
    static var btc: Coin {
        guard let _btc = getCoin(ofIdentifier: Coin.btc_identifier) else {
            fatalError()
        }
        
        return _btc
    }

    static var eth: Coin {
        guard let _eth = getCoin(ofIdentifier: Coin.eth_identifier) else {
            fatalError()
        }
        
        return _eth
    }
    
    static var cic: Coin {
        guard let _cic = getCoin(ofIdentifier: Coin.cic_identifier) else {
            fatalError()
        }
        
        return _cic
    }
    
    static var btcRelay: Coin {
        guard let _cic = getCoin(ofIdentifier: Coin.btcRelay_identifier) else {
            fatalError()
        }
        
        return _cic
    }

}

// MARK: - Coin Static ID Definition
extension Coin {
    static var btc_identifier: String {
        return "Identifier_BTC"
    }
    
    static var eth_identifier: String {
        return "0x0000000000000000000000000000000000000000"
    }
    
    static var cic_identifier: String {
        return "0x29dc5ea777ff2bbfe14866f368b5ccc5e9fad99e"
    }
    
    static var btcRelay_identifier: String {
        return "Identifier_BTCRelay"
    }
    
    static var guc_identifier: String {
        return "0x43ccb7d0f229f96488b7f963d2cf25434efbe611b9e7c8ff28176e761c5f7944"
    }
}

//MARK: - Lightning Transaction Support
extension Coin {
    var owChainType: ChainType {
        return ChainType.init(rawValue: chainType)!
    }
    
    static var lightningTransactionFromCoins: [Coin] {
        let allCICCoins = Coin.getAllCoins(of: ChainType.cic)
        
        return [Coin.btc] + allCICCoins
//        return [Coin.btc, Coin.btcRelay, Coin.cic]
    }
    
    static func lightningTransactionFromCoins(ofMainCoin coin: Coin) -> [Coin] {
        return lightningTransactionFromCoins.filter {
            $0.walletMainCoinID == coin.identifier
        }
    }
    
    static func lightningTransactionToCoins(withFromCoin fCoin: Coin) -> [Coin] {
        switch fCoin.owChainType {
        case .btc:
            if fCoin.identifier == Coin.btc_identifier {
                return [Coin.btcRelay]
            }else {
                return []
            }
        case .eth:
            return []
        case .cic:
            return [fCoin]
        }
    }
}


// MARK: - Blockchain API params
extension Coin {
    var blockchainAPI_identifier: String {
//        switch identifier! {
//        case Coin.btcRelay_identifier:
//            return "btr".uppercased()
//        default:
            return chainName!
//        }
    }
    
//    static func localIdentifier(fromRemoteAPIIdentifier remoteID: String) -> String {
//        switch remoteID.lowercased() {
//        case "btr":
//            return Coin.btcRelay_identifier
//        default:
//            return remoteID.uppercased()
//        }
//    }
}
