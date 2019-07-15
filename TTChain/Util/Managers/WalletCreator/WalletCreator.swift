//
//  WalletCreator.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/14.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import HDWalletKit

class WalletCreator {
    
    static func createNewWallet(forChain chain: ChainType, mnemonic: String?, pwd:String, pwdHint:String, isSystemWallet:Bool, walletName:String? = nil) -> Single<Bool> {
        return Single.create { (handler) -> Disposable in
            
            //used Just for termination
            let error: GTServerAPIError = .apiReject
            
            guard let wallets = Identity.singleton!.wallets?.array as? [Wallet] else {
                handler(.error(error))
                return Disposables.create ()
            }

            let change = WalletCreator.getChange(forMnemonic: mnemonic!, chain: chain)
            
            var pvtKeyForNewWallet: PrivateKey?
            
            for i in 0...50 {
                let firstPrivateKey = change.derived(at: .notHardened(UInt32(i)))
                let matchedWallet = wallets.filter { $0.address!.caseInsensitiveCompare(firstPrivateKey.publicKey.address) == .orderedSame}
                if !matchedWallet.isEmpty {
                    continue
                }
                pvtKeyForNewWallet = firstPrivateKey
                break
            }
            guard pvtKeyForNewWallet != nil else {
                handler(.error(error))
                return Disposables.create ()
            }
            guard let mainCoin = Coin.getCoin(ofChainName: chain.name, chainType: chain) else {
                handler(.error(error))
                return Disposables.create ()

            }
            
            var address = pvtKeyForNewWallet!.publicKey.address
            if chain == .eth {
                address = address.lowercased()
            }
            let source = (address: pvtKeyForNewWallet!.publicKey.address,
                          pKey: pvtKeyForNewWallet!.get(),
                          mnenomic: mnemonic,
                          isFromSystem: isSystemWallet,
                          name: walletName ?? Wallet.importedWalletName(ofMainCoin: mainCoin),
                          pwd: pwd,
                          pwdHint: pwdHint,
                          chainType: chain,
                          mainCoinID: mainCoin.walletMainCoinID!)
            
            guard Wallet.create(identity: Identity.singleton!, source: source) != nil else {
                handler(.error(error))
                return Disposables.create()

            }
            handler(.success(true))
            
            return Disposables.create()
        }
    }
    
    static private func createChange(seed:Data , chain:ChainType) -> PrivateKey {
        
        let privateKey = PrivateKey(seed: seed, coin: (chain == ChainType.btc ? .bitcoin : .ethereum))
        // BIP44 key derivation
        // m/44'
        let purpose = privateKey.derived(at: .hardened(44))
        
        // m/44'/0' || // m/44'/60'
        let coinType = purpose.derived(at: .hardened(chain == ChainType.btc  ? 0 : 60))
        
        // m/44'/0'/0' || // m/44'/60'/0'
        let account = coinType.derived(at: .hardened(0))
        
        // m/44'/0'/0'/0 || // m/44'/60'/0'/0
        return account.derived(at: .notHardened(0))
    }
    
    static func getChange(forMnemonic mnemonic:String, chain:ChainType) -> PrivateKey {
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let change = WalletCreator.createChange(seed: seed, chain: chain)
        return change
    }
    
    static func generatePvtKeyAndAddress(mnemonic:String, chain:ChainType) -> (String,String) {
        let change = WalletCreator.getChange(forMnemonic: mnemonic, chain: chain)
        let firstPrivateKey = change.derived(at: .notHardened(UInt32(0)))
        
        var address = firstPrivateKey.publicKey.address
        if chain == .eth {
            address = address.lowercased()
        }
        
        return (firstPrivateKey.get(),address)
    }
    
}
