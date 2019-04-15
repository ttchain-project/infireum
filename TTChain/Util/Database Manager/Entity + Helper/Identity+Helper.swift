//
//  Identity+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

extension Identity {
    static var singleton: Identity? {
        guard let id = DB.instance.get(type: Identity.self, predicate: nil, sorts: nil)?.first else {
            return nil
        }
        
        return id
    }
    
    static func create(mnemonic: String, name: String, pwd: String, hint: String) -> Identity? {
        guard let id = OWDatabaseEntityCrypter.hashIdentityIDFromMnemonic(mnemonic) else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        let cnyID = SystemDefaultFiat.CNY.rawValue
        let pred = Fiat.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Fiat.id), value: cnyID))
        
        guard let fiatID = DB.instance.get(type: Fiat.self, predicate: pred, sorts: nil)?.first?.id else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        let langID = LM.instance.lang.value.rawValue
        let identity = DB.instance.create(type: self, setup: { (identity) in
            identity.id = id
            identity.name = name
            identity.ePwd = OWDatabaseEntityCrypter.encryptPwd(pwd)
            identity.pwdHint = hint
            identity.prefLangID = langID
            identity.prefFiatID = fiatID
        })
        
        if let _identity = identity {
            Fiat.markIdToIdentity(fiatId: fiatID, identity: _identity)
            Language.markIdToIdentity(langId: langID, identity: _identity)
        }
        
        return identity
    }
}

//MARK: - Helper
extension Identity {
    var owLang: Lang {
        return Lang.init(rawValue: prefLangID)!
    }
    
    var owFiat: Fiat {
        return fiat!
    }
    
    /// Check if the pwd is origin raw pwd of the identity.
    ///
    /// - Parameter pwd:
    /// - Returns:
    func isIdentityRawPwd(pwd: String) -> Bool {
        guard let inputEPwd = OWDatabaseEntityCrypter.encryptPwd(pwd) else {
            return false
        }
        
        return ePwd == inputEPwd
    }
}

// MARK: - Clear
extension Identity {
    func clear() {
        DB.instance.deleteAll(type: Identity.self)
        DB.instance.deleteAll(type: Wallet.self)
        DB.instance.deleteAll(type: Asset.self)
        DB.instance.deleteAll(type: TransRecord.self)
        DB.instance.deleteAll(type: LightningTransRecord.self)
        DB.instance.deleteAll(type: AddressBookUnit.self)
        DB.instance.deleteAll(type: SubAddress.self)
        DB.instance.deleteAll(type: CoinSelection.self)
        DB.instance.deleteAll(type: ServerSyncRecord.self)
        
        DB.instance.debugWholeDatabaseCount()
    }
}

// MARK: - Asset Finder
extension Identity {
    func getAllAssets(of coin: Coin) -> [Asset] {
        guard let wallets = wallets?.array as? [Wallet] else { return [] }
        let assets = wallets.filter { $0.owChainType == coin.owChainType } .compactMap { wallet -> [Asset]? in
                return wallet.assets?.array as? [Asset]
            }.flatMap { $0 }
        
        let matchedAssets = assets.filter { (asset) -> Bool in
            return asset.coinID! == coin.identifier!
        }
        
        return matchedAssets
    }
    
    func getWallet(ofAddress addr: String, type: ChainType) -> Wallet? {
        guard let wallets = wallets?.array as? [Wallet] else { return nil }
        guard let idx = wallets.index(where: { (w) -> Bool in
            return (w.address!.caseInsensitiveCompare(addr) == .orderedSame) && w.owChainType == type
        }) else { return nil }
        
        return wallets[idx]
    }
}

//MARK: - QRCode Restore
extension Identity {
    static func create(fromQRCodeContent content: IdentityQRCodeContent, idName: String, pwd: String, hint: String) -> Identity? {
        guard let identity = Identity.create(
            mnemonic: content.systemMnemonic,
            name: idName,
            pwd: pwd,
            hint: hint
            ) else {
            return nil
        }
        
        let systemWalletSources = content.systemWallets.map {
            $0.transformToWalletCreateSource(pwd: pwd, pwdHint: hint, isFromSystem: true, mnemonic: content.systemMnemonic)
        }
        
        let importedWalletSources = content.importedWallets.map {
            $0.transformToWalletCreateSource(pwd: pwd, pwdHint: hint, isFromSystem: false, mnemonic: nil)
        }
        
        let allSources = systemWalletSources + importedWalletSources
        
        guard let wallets = Wallet.create(identity: identity, sources: allSources),
            wallets.count == allSources.count else {
                return nil
        }
        
        return identity
    }
}

//MARK: - Mock
extension Identity {
    static func createMockIdentity() {
    }
}
