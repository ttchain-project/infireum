//
//  IdentityQRCodeContent.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/13.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import SwiftyJSON
import Gzip
class IdentityQRCodeContent: Codable {
    struct Finder {
        static func findPwdHintFromQRCodeRawContentIfPossible(_ content: String) -> String? {
            return parse(qrCodeRawContent: content)?["hint"].string
        }
    }
    
    private(set) var timestamp: TimeInterval
    private(set) var pwdHint: String
    private(set) var systemMnemonic: String
    private(set) var systemWallets: [IdentityQRCodeContentWalletUnit]
    private(set) var importedWallets: [IdentityQRCodeContentWalletUnit]

    required init(timestamp: TimeInterval,
                  pwdHint: String,
                  systemMnemonic: String,
                  systemWallets: [IdentityQRCodeContentWalletUnit],
                  importedWallets: [IdentityQRCodeContentWalletUnit]) {
        self.timestamp = timestamp
        self.pwdHint = pwdHint
        self.systemMnemonic = systemMnemonic
        self.systemWallets = systemWallets
        self.importedWallets = importedWallets
    }
    
    convenience init?(timestamp: TimeInterval,
                      pwdHint: String,
                      encrySystemMnemonic: String,
                      pwd: String,
                      systemWallets: [IdentityQRCodeContentWalletUnit],
                      importedWallets: [IdentityQRCodeContentWalletUnit]) {
        guard let systemMnemonic = OWDatabaseEntityCrypter.decrypt(source: encrySystemMnemonic, key: pwd) else {
            return nil
        }
        
        guard case .valid = systemMnemonic.ow_isValidMnemonic else {
            return nil
        }
        
        self.init(timestamp: timestamp,
                  pwdHint: pwdHint,
                  systemMnemonic: systemMnemonic,
                  systemWallets: systemWallets,
                  importedWallets: importedWallets)
    }
    
    convenience init?(qrCodeRawContent: String, pwd: String) {
        guard let json = IdentityQRCodeContent.parse(qrCodeRawContent: qrCodeRawContent) else {
            return nil
        }
        
        guard let hint = json["hint"].string,
            let timestamp_int = json["timestamp"].int else {
                return nil
        }
        
        let timestamp = Double(timestamp_int) / 1000.0
        
        let content = json["content"]
        let systemContent = content["system"]
        
        guard let encryMnemonic = systemContent["mnemonic"].string,
            let mnemonic = OWDatabaseEntityCrypter.decrypt(source: encryMnemonic, key: pwd),
            let systemWalletJSONs = systemContent["wallets"].array else {
                return nil
        }
        
        guard case .valid = mnemonic.ow_isValidMnemonic else {
            return nil
        }
        
        guard let importedWalletJSONs = content["imported"].array else {
            return nil
        }
        
        let systemWallets = systemWalletJSONs.compactMap {
            IdentityQRCodeContentWalletUnit.init(json: $0, pwd: pwd)
        }
        
        let importedWallets = importedWalletJSONs.compactMap {
            IdentityQRCodeContentWalletUnit.init(json: $0, pwd: pwd)
        }
        
        self.init(timestamp: timestamp,
                  pwdHint: hint,
                  systemMnemonic: mnemonic,
                  systemWallets: systemWallets,
                  importedWallets: importedWallets)
    }
    
    convenience init?(identity: Identity, pwd: String, pwdHint: String)  {
        guard let allWallets = identity.wallets?.array as? [Wallet] else {
            return nil
        }
 
        var systemWallets: [Wallet] = []
        var importedWallets: [Wallet] = []
        for wallet in allWallets {
            wallet.isFromSystem ? systemWallets.append(wallet) : importedWallets.append(wallet)
        }
        
        guard let firstSystemWallet = systemWallets.first else {
                return nil
        }
        
        let mnemonic = firstSystemWallet.mnemonic
        
        let systemWalletUnits = systemWallets.map { IdentityQRCodeContentWalletUnit.init(wallet: $0) }
        let importedWalletUnits = importedWallets.map { IdentityQRCodeContentWalletUnit.init(wallet: $0) }
        
        let timestamp = Date().timeIntervalSince1970
        self.init(timestamp: timestamp,
                  pwdHint: pwdHint,
                  systemMnemonic: mnemonic,
                  systemWallets: systemWalletUnits,
                  importedWallets: importedWalletUnits)
    }
    
    fileprivate static func parse(qrCodeRawContent: String) -> JSON? {
        var jsonContent : JSON?
        
        if let rawJsonData = qrCodeRawContent.data(using: .utf8),
            let json = try? JSON.init(data: rawJsonData) {
            jsonContent = json
        } else if let jsonStringFromGZIP = self.checkForGZIPData(data: qrCodeRawContent),
            let jsonDataFromGZIP = jsonStringFromGZIP.data(using: .utf8),
            let jsonFromGZip = try? JSON.init(data: jsonDataFromGZIP){
            jsonContent = jsonFromGZip
        }else {
            return nil
        }
        
        guard jsonContent != nil else {
            return nil
        }
        //All These guard check steps just to ensure the format is correct.
        guard let _ = jsonContent!["hint"].string,
            let _ = jsonContent!["timestamp"].int else {
                return nil
        }
        
        let content = jsonContent!["content"]
        let systemContent = content["system"]
        
        guard let _ = systemContent["mnemonic"].string,
            let _ = systemContent["wallets"].array else {
                return nil
        }
        
        guard let _ = content["imported"].array else {
            return nil
        }
        
        return jsonContent
    }
    
    fileprivate static func checkForGZIPData(data: String) -> String? {
        
        guard let decodedData = Data.init(base64Encoded: data) else {
            return nil
        }
//        guard let decodedString = String.init(data: decodedData, encoding: .utf8) else {
//            return nil
//        }
//        if  decodedData.isGzipped {
//            print("This is gzipped")
//        }
        
//        guard let gzipData = decodedString.data(using: .utf8) else {
//            return nil
//        }
        if decodedData.isGzipped {
            print("IsGZIP")
        }
        guard let gzipDecompressedData = try? decodedData.gunzipped() else {
            return nil
        }
           guard let gzipDecompressedString = String(data: gzipDecompressedData, encoding: .utf8) else {
                return nil
        }
        return gzipDecompressedString
    }
    
    public static func isSourceHasValidIdentityQRCodeFormat(_ source: String) -> Bool {
        return parse(qrCodeRawContent: source) != nil
    }

    public func generateQRCodeContent(withPwd pwd: String) -> String? {
        guard let encryMnemonic = OWDatabaseEntityCrypter.encrypt(source: systemMnemonic, key: pwd) else { return nil }
        
        let systemWalletsEncryJSONDictionaries = systemWallets.compactMap { $0.convertToEncryJSONDictionary(withPwd: pwd) }
        
        let importedWalletsEncryJSONDictionaries = importedWallets.compactMap { $0.convertToEncryJSONDictionary(withPwd: pwd) }
        
        
        let encryContentDictionary: [String : Any] = [
            "hint" : pwdHint,
            "timestamp" : Int(timestamp * 1000),
            "content": [
                "system" : [
                    "mnemonic" : encryMnemonic,
                    "wallets": systemWalletsEncryJSONDictionaries
                ],
                "imported": importedWalletsEncryJSONDictionaries
            ]
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: encryContentDictionary, options: [])
        let str = json.string(encoding: .utf8)!
//        let json = JSON(encryContentDictionary)
//        print("QRCode content result is\n\(str)")
        
        return str
    }
    public func generateMultipleQRCodeContent(withPwd pwd:String) -> [String]? {
        
        var jsonArray = [String]()
        
        guard let encryMnemonic = OWDatabaseEntityCrypter.encrypt(source: systemMnemonic, key: pwd) else { return nil }
//        let systemWalletsEncryJSONDictionaries = systemWallets.compactMap { $0.convertToEncryJSONDictionary(withPwd: pwd) }
//        let importedWalletsEncryJSONDictionaries = importedWallets.compactMap { $0.convertToEncryJSONDictionary(withPwd: pwd) }
        
        let systemWalletsArray =  systemWallets.compactMap { wallet -> String? in
            
            guard let walletJson = wallet.convertToEncryJSONDictionary(withPwd: pwd) else {
                return nil
            }
            
            let encryContentDictionary: [String : Any] = [
                "hint" : pwdHint,
                "timestamp" : Int(timestamp * 1000),
                "content": [
                    "system" : [
                        "mnemonic" : encryMnemonic,
                        "wallets": walletJson
                    ]
                ]
            ]
            let json = try! JSONSerialization.data(withJSONObject: encryContentDictionary, options: [])
            return json.string(encoding: .utf8)!
        }
        
        let importedWalletArray = importedWallets.compactMap { wallet -> String? in
            
            guard let walletJson = wallet.convertToEncryJSONDictionary(withPwd: pwd) else {
                return nil
            }
            
            let encryContentDictionary: [String : Any] = [
                "hint" : pwdHint,
                "timestamp" : Int(timestamp * 1000),
                "content": [
                    "imported": walletJson
                ]
            ]
            let json = try! JSONSerialization.data(withJSONObject: encryContentDictionary, options: [])
            return json.string(encoding: .utf8)!
        }
        
//        let encryContentDictionary: [String : Any] = [
//            "hint" : pwdHint,
//            "timestamp" : Int(timestamp * 1000),
//            "content": [
//                "system" : [
//                    "mnemonic" : encryMnemonic,
//                    "wallets": systemWalletsEncryJSONDictionaries
//                ],
//                "imported": importedWalletsEncryJSONDictionaries
//            ]
//        ]
//
//        let json = try! JSONSerialization.data(withJSONObject: encryContentDictionary, options: [])
//        let str = json.string(encoding: .utf8)!
        jsonArray = systemWalletsArray + importedWalletArray
        
        
        //        let json = JSON(encryContentDictionary)
        //        print("QRCode content result is\n\(str)")
        
        return jsonArray
    }
    
}
