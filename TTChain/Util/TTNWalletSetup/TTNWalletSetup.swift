//
//  TTNWalletSetup.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/24.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import HDWalletKit

class TTNWalletManager {
    
    static func setupTTNWallet(withPwd pwd:String) {
        //String noPrefixAddress = Utility.getSHA256(ethMaster.getPublicKey()).substring(24, 64);
        let sortDescriptor = NSSortDescriptor.init(key: "isFromSystem", ascending: false)
        let predForETH = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: ChainType.eth.rawValue))
        guard let ethWallet = DB.instance.get(type: Wallet.self, predicate: predForETH, sorts: [sortDescriptor])?.first, ethWallet.isFromSystem else {
            return
        }
        let pvtKey =  PrivateKey.init(pk: ethWallet.pKey, coin: .ethereum)
        let pubKey = pvtKey?.publicKey.getPublicKey(compressed: false)
        var publicKey = pubKey?.toHexString() ?? ""
        if publicKey.count > 128 {
            publicKey = String(publicKey.dropFirst(publicKey.count - 128))
        }
        let shaAddress = publicKey.sha256()
        
        let start = shaAddress.index(shaAddress.startIndex, offsetBy: 24)
        let end = shaAddress.index(shaAddress.startIndex, offsetBy: 63)
        let range = start...end
        let noPrefixAddress = String(shaAddress[range])
        let source = (address: noPrefixAddress,
                      pKey: ethWallet.pKey,
                      mnenomic: Optional(ethWallet.mnemonic),
                      isFromSystem: true,
                      name: Wallet.walletNamePrefix(ofMainCoin: Coin.ttn),
                      pwd: pwd,
                      pwdHint: ethWallet.pwdHint!,
                      chainType: ChainType.ttn,
                      mainCoinID: Coin.ttn_identifier)
        
        _ = Wallet.create(identity: Identity.singleton!, source: source)
    }
}