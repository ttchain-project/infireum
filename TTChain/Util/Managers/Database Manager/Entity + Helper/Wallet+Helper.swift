//
//  Wallet+Helper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

typealias WalletCreateSource = (address: String, pKey: String, mnenomic: String?, isFromSystem: Bool, name: String, pwd: String, pwdHint: String, chainType: ChainType, mainCoinID: String)

extension Wallet {
    static func defaultName(ofMainCoin mainCoin: Coin) -> String {
        return walletNamePrefix(ofMainCoin: mainCoin) + " 1"
    }
    
    static func walletNamePrefix(ofMainCoin mainCoin: Coin) -> String {
        return "\(mainCoin.inAppName!) Wallet"
    }
    
    static func importedWalletName(ofMainCoinID mainCoinID: String) -> String {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        return importedWalletName(ofMainCoin: coin)
    }
    
    static func importedWalletName(ofMainCoin mainCoin: Coin) -> String {
        let typeName: String = walletNamePrefix(ofMainCoin: mainCoin)
        let no: String = String(getWalletsCount(ofMainCoinID: mainCoin.walletMainCoinID!) + 1)
        return typeName + " " + no
    }
    
    static func getWallets(ofMainCoinID mainCoinID: String) -> [Wallet] {
        let pred = Wallet.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Wallet.walletMainCoinID), value: mainCoinID))
        guard let wallets = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil), !wallets.isEmpty else {
            return []
        }
        return wallets
    }
    
    static func getWalletsCount(ofMainCoinID mainCoinID: String) -> Int {
        return getWallets(ofMainCoinID: mainCoinID).count
    }
    
    static func getWallet(ofAddress addr: String, mainCoinID: String) -> Wallet? {
        let wallets = getWallets(ofMainCoinID: mainCoinID)
        guard let idx = wallets.index(where: { (w) -> Bool in
            return w.address!.caseInsensitiveCompare(addr) == .orderedSame
        }) else { return nil }
        
        let wallet = wallets[idx]
//        wallet.address = wallet.address?.lowercased()
        return wallet
    }
    
    static func create(
        identity: Identity,
        sources: [WalletCreateSource]
        ) -> [Wallet]? {
        
        let setups = sources.compactMap {
            source -> ((Wallet) -> Void)? in
            return {
                wallet in
                guard let epKey = OWDatabaseEntityCrypter.encryptPrivateKeyWithRawPwd(source.pKey, pwd: source.pwd),
                    let ePwd = OWDatabaseEntityCrypter.encryptPwd(source.pwd) else {
                    return errorDebug(response: ())
                }
                
                wallet.address = source.address
                wallet.encryptedPKey = epKey
                var encryptedMnemonic: String?
                if let _mne = source.mnenomic {
                    encryptedMnemonic = OWDatabaseEntityCrypter.encryptMnemonicWithRawPwd(_mne, pwd: source.pwd)
                }
                
                wallet.eMnemonic = encryptedMnemonic
                wallet.isFromSystem = source.isFromSystem
                wallet.name = source.name
                wallet.ePwd = ePwd
                wallet.pwdHint = source.pwdHint
                wallet.chainType = source.chainType.rawValue
                wallet.identity = identity
                wallet.identityID = identity.id!
                wallet.walletMainCoinID = source.mainCoinID
                
                let mainCoin = Coin.getCoin(ofIdentifier: source.mainCoinID)!
                wallet.mainCoin = mainCoin
                
                mainCoin.addToAsMainInWallets(wallet)
                
                identity.addToWallets(wallet)
            }
        }
        
        let wallets = DB.instance.batchCreate(type: self, setups: setups)
        if let _wallets = wallets {
            identity.addToWallets(NSOrderedSet.init(array: _wallets))
            for _wallet in _wallets {
                let assets = Asset.createDefaultEntitiesOfWallet(wallet: _wallet)
                
                line()
                print("Create default assets of wallet: \(_wallet.chainType), assets count: \(assets.count)\n\nassets: \(assets)")
                line()
            }
        }
        return wallets
    }
    
    static func create(
        identity: Identity,
        source: WalletCreateSource
        ) -> Wallet? {
        return create(identity: identity, sources: [source])?.first
    }
    
    func createNewAsset(ofCoin coin: Coin) -> Asset? {
        guard let asset = DB.instance.create(type: Asset.self, setup: {
            [unowned self]
            asset in
            #if DEBUG
//            asset.amount = 100
            asset.amount = 0
            #else
            asset.amount = 0
            #endif
            asset.coinID = coin.identifier!
            coin.addToAssets(asset)
            
            asset.walletEPKey = encryptedPKey!
            asset.wallet = self
            //Wallet asset add will perform later
            self.addToAssets(asset)
            
//            CoinSelection.markSelection(of: self, coin: coin, isSelected: true)
        }) else {
            return errorDebug(response: nil)
        }
        
        return asset
    }
    
    func getAsset(of coin: Coin) -> Asset? {
        guard let assets = assets?.array as? [Asset] else {
            return errorDebug(response: nil)
        }
        
        guard let idx = assets.index(where: { (asset) -> Bool in
            return asset.coinID! == coin.identifier!
        }) else {
            return nil
        }
        
        return assets[idx]
    }
    
    var pKey: String {
        return OWDatabaseEntityCrypter.decryptEncryptedPrivateKey(encryptedPKey!, ePwd: ePwd!)!
    }
    
    var mnemonic: String {
        return OWDatabaseEntityCrypter.decryptMnemonic(eMnemonic!, ePwd: ePwd!)!
    }
    
    var owChainType: ChainType {
        return ChainType.init(rawValue: chainType)!
    }
    
    func isWalletPwd(rawPwd pwd: String) -> Bool {
        guard let ePwd = OWDatabaseEntityCrypter.encryptPwd(pwd) else { return false }
        return ePwd == self.ePwd
    }
    
    /// Will attemp to decrypt mnemonic with the input pwd key,
    /// return nil if wallet doesn't has mnemonic value or decryption failed
    /// - Parameter pwd:
    /// - Returns:
    func attemptDecryptMnemonic(withRawPwd pwd: String) -> String? {
        guard let eMne = eMnemonic else { return nil }
        return OWDatabaseEntityCrypter.decryptMnemonicWithRawPwd(eMne, pwd: pwd)
    }
}

/// MARK: - Fee Coin Determination
extension Wallet {
    var feeCoinID: String {
        let type = ChainType.init(rawValue: chainType)!
        switch type {
        case .btc:
            return Coin.btc_identifier
        case .eth:
            return Coin.eth_identifier
        case .cic:
            return Coin.cic_identifier
        case .ttn:
            return Coin.ttn_identifier
        case .ifrc:
        return Coin.ifrc_identifier
        }
    }
}

// MARK: - Mocking
extension Wallet {
    func createMockTransRecords() -> Bool {
        let assets = self.assets!.array as! [Asset]
        let coins = assets.map { $0.coin! }
        for coin in coins {
            guard TransRecord.mockAllPossibleRecordsOfCoin(coin: coin, ofWallet: self).count > 0 else {
                return errorDebug(response: false)
            }
        }
        
        return true
    }
    
    func createMockLightningTransRecords() {
        LightningTransRecord.mockAllPossibleRecords(ofWallet: self)
    }
}
