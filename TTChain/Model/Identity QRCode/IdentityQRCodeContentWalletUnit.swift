//
//  IdentityQRCodeContentWalletUnit.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import SwiftyJSON

class IdentityQRCodeContentWalletUnit: Codable {
    
    
    var mainCoinID: String
    var name: String
    var privateKey: String
    var address: String
    
    required init(mainCoinID: String,
                  name: String,
                  privateKey: String,
                  address: String) {
        self.mainCoinID = mainCoinID
        self.name = name
        self.privateKey = privateKey
        self.address = address
    }
    
    convenience init?(mainCoinID: String,
                      name: String,
                      encryPrivateKey: String,
                      pwd: String,
                      address: String) {
        guard let pKey = OWDatabaseEntityCrypter.decrypt(source: encryPrivateKey, key: pwd) else {
            return nil
        }
        
        self.init(mainCoinID: mainCoinID, name: name, privateKey: pKey, address: address)
    }
    
    convenience init?(json: JSON, pwd: String) {
        guard let mainCoinID = json["mainCoinID"].string,
            let name = json["name"].string,
            let encryPrivateKey = json["privateKey"].string,
            let address = json["address"].string else {
                return nil
        }
        
        self.init(mainCoinID: mainCoinID,
                  name: name,
                  encryPrivateKey: encryPrivateKey,
                  pwd: pwd,
                  address: address)
    }
    
    convenience init(wallet: Wallet) {
        let pKey = wallet.pKey
        let mainCoinID = wallet.walletMainCoinID!
        let name = wallet.name!
        let address = wallet.address!
        
        self.init(mainCoinID: mainCoinID,
                  name: name,
                  privateKey: pKey,
                  address: address)
    }
    
    func convertToEncryJSONDictionary(withPwd pwd: String) -> [String : Any]? {
        guard let encryPKey = OWDatabaseEntityCrypter.encrypt(source: privateKey, key: pwd)  else {
            return nil
        }
        
        return [
            "mainCoinID" : mainCoinID,
            "name" : name,
            "privateKey" : encryPKey,
            "address" : address
        ]
    }
}

// MARK: - Helper to transform to WalletCreateSource
extension IdentityQRCodeContentWalletUnit {
    func transformToWalletCreateSource(pwd: String, pwdHint: String, isFromSystem: Bool, mnemonic: String?) -> WalletCreateSource {
        let mainCoin = Coin.getCoin(ofIdentifier: mainCoinID)!
        return (address: address, pKey: privateKey, mnenomic: mnemonic, isFromSystem: isFromSystem, name: name, pwd: pwd, pwdHint: pwdHint, chainType: mainCoin.owChainType, mainCoinID: mainCoinID)
    }
}
