//
//  IdentityQRCodeEncryptedContent.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import SwiftyJSON

/*class IdentityQRCodeEncryptedContent: Codable {
    private(set) var timestamp: TimeInterval
    private(set) var pwdHint: String
    private(set) var content: String
    
    required init(timestamp: TimeInterval,
                  pwdHint: String,
                  encryptedContent: String) {
        self.timestamp = timestamp
        self.pwdHint = pwdHint
        self.content = encryptedContent
    }
    
    static func create(fromDecryptedContent fromContent: IdentityQRCodeContent, withPwd pwd: String) -> IdentityQRCodeEncryptedContent? {
        let encoder = JSONEncoder()
        
        let systemWallets = fromContent.systemWallets
        let systemMnemonic = fromContent.systemMnemonic
        let importedWallets = fromContent.importedWallets
        
        let convertWalletUnitToJSON: (IdentityQRCodeContentWalletUnit) -> [String : Any]? = {
            unit in
            guard let unitData = try? encoder.encode(unit) else { return nil }
            guard let dataMap = try? JSONSerialization.jsonObject(with: unitData, options: .allowFragments) else {
                return nil
            }
            
            guard let unitJSON = dataMap as? [String : Any] else {
                return nil
            }
            
            return unitJSON
        }
        
        let systemWalletsMap: [String : Any] = [
            "mnemonic" : systemMnemonic,
            "wallets" : systemWallets.compactMap { convertWalletUnitToJSON($0) }
        ]
        
        let importedWalletsMap = importedWallets.compactMap { convertWalletUnitToJSON($0) }
        
        let contentJsonMap: [String : Any] = [
            "system" : systemWalletsMap,
            "imported" : importedWalletsMap
        ]
        
        let contentJSON = JSON.init(contentJsonMap)
        let rawJSONContent = contentJSON.description
        notice("raw JSON Content parsing is finish, content is:\n\(rawJSONContent)")
        
        guard let encryptedJSONContent = rawJSONContent.aes256Encrypt(key: pwd, iv: C.Crypto.AES.iv) else {
            return nil
        }
        
        return IdentityQRCodeEncryptedContent(timestamp: fromContent.timestamp,
                                              pwdHint: fromContent.pwdHint,
                                              encryptedContent: encryptedJSONContent)
    }
    
    static func create(fromQRCodeRawContent rawContent: String) -> IdentityQRCodeEncryptedContent? {
        guard let rawData = rawContent.data(using: .utf8) else {
            return nil
        }
        
        guard let result = try? JSONDecoder().decode(IdentityQRCodeEncryptedContent.self, from: rawData) else {
            warning("Cannot decode result from rawContent: \(rawContent)")
            return nil
        }
        
        return result
    }
    
    //MARK: - Test
    func printContentLength() {
        let encoder = try! JSONEncoder().encode(self.self)
        let desc = JSON.init(encoder).description
        print("Content Length is : \(desc.count)")
        print(desc)
        
    }
}*/
