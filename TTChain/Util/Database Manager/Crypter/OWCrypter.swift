//
//  OWCrypter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/21.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CryptoSwift

protocol OWCrypter {
    func aes256Encrypt(key: String, iv: String) -> String?
    func aes256Decrypt(key: String, iv: String) -> String?
}

// MARK: - OWCrypter
extension String: OWCrypter {
    func aes256Encrypt(key: String, iv: String) -> String? {
        guard let aesEnc: AES = try? AES.init(key: key, iv: iv) else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        do{
            let encrypted = try aesEnc.encrypt(bytes)
            let str = encrypted.toBase64()
            
            return str
            
        } catch let e {
            #if DEBUG
            print(e)
            fatalError()
            #else
            return nil
            #endif
        }
    }
    
    func aes256Decrypt(key: String, iv: String) -> String? {
        guard let aesEnc: AES = try? AES(key: key, iv: iv) else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        do {
            let bytes = [UInt8](data)
            let decrypted = try aesEnc.decrypt(bytes)
            let dec = Data.init(bytes: decrypted, count: decrypted.count)
            guard let str = String.init(data: dec, encoding: .utf8) else {
//                #if DEBUG
//                fatalError()
//                #else
                return nil
//                #endif
            }
            
            return str
            
        } catch let e {
//                #if DEBUG
                print(e)
//                fatalError()
//                #else
                return nil
//                #endif
        }
    }
}


struct OWDatabaseEntityCrypter {
    //MARK: - AES256 General
    static func encrypt(source: String, key: String) -> String? {
        var key = key
        var interval = 16 - key.bytes.count
        while interval != 0 {
            if interval > 0 {
                key += key
            }else {
                key = String(key[key.startIndex...key.index(key.startIndex, offsetBy: 15)])
            }
            
            interval = 16 - key.bytes.count
        }
        
        return source.aes256Encrypt(key: key, iv: C.Crypto.AES.iv)
    }
    
    static func decrypt(source: String, key: String) -> String? {
        var key = key
        var interval = 16 - key.bytes.count
        while interval != 0 {
            if interval > 0 {
                key += key
            }else {
                key = String(key[key.startIndex...key.index(key.startIndex, offsetBy: 15)])
            }
            
            interval = 16 - key.bytes.count
        }
        
        return source.aes256Decrypt(key: key, iv: C.Crypto.AES.iv)
    }
    
    //MARK: - Private Key
    /// Pass the private key and raw pwd
    /// SYSTEM WILL HELP THE PWD ENCRYPTION PART
    /// - Parameters:
    ///   - pKey:
    ///   - pwd:
    /// - Returns:
    public static func encryptPrivateKeyWithRawPwd(_ pKey: String, pwd: String) -> String? {
        guard let ePwd = encryptPwd(pwd) else { return nil }
        return encryptPrivateKey(pKey, ePwd: ePwd)
    }
    
    /// Pass the private key and ENCRYPTED raw pwd
    ///
    /// - Parameters:
    ///   - pKey:
    ///   - ePwd:
    /// - Returns:
    private static func encryptPrivateKey(_ pKey: String, ePwd: String) -> String? {
        return encrypt(source: pKey, key: ePwd)
    }
    
    /// Pass the ENCRYPTED private key and raw pwd.
    /// SYSTEM WILL HELP THE PWD ENCRYPTION PART
    /// - Parameters:
    ///   - pKey:
    ///   - pwd:
    /// - Returns:
    public static func decryptEncryptedPrivateKeyWithRawPwd(_ epKey: String, pwd: String) -> String? {
        guard let ePwd = encryptPwd(pwd) else { return nil }
        return decryptEncryptedPrivateKey(epKey, ePwd: ePwd)
    }
    
    public static func decryptEncryptedPrivateKey(_ epKey: String, ePwd: String) -> String? {
        return decrypt(source: epKey, key: ePwd)
    }
    
    //MARK: - Mnemonic
    public static func encryptMnemonicWithRawPwd(_ mne: String, pwd: String) -> String? {
        guard let ePwd = encryptPwd(pwd) else { return nil }
        return encryptMnemonic(mne, ePwd: ePwd)
    }
    
    private static func encryptMnemonic(_ mne: String, ePwd: String) -> String? {
        return encrypt(source: mne, key: ePwd)
    }
    
    public static func decryptMnemonicWithRawPwd(_ encryptedMne: String, pwd: String) -> String? {
        guard let ePwd = encryptPwd(pwd) else { return nil }
        return decryptMnemonic(encryptedMne, ePwd: ePwd)
    }
    
    public static func decryptMnemonic(_ encryptedMne: String, ePwd: String) -> String? {
        return decrypt(source: encryptedMne, key: ePwd)
    }
    
    //MARK: -
    
    /// Encrypt Pwd, please remind that input will be both source and key. AND PLZ STORE THE ORIGIN SOURCE IF FURTHER AUTO-DECRYPTION IS NEEDED.
    ///
    /// - Parameter pwd: source and key
    /// - Returns:
    static func encryptPwd(_ pwd: String) -> String? {
        return encrypt(source: pwd, key: pwd)
    }
    
    
    //MARK: - Identity ID
    static func hashIdentityIDFromMnemonic(_ mnemonic: String) -> String? {
        let prefix = "OW"
        let hashedMnemonic = String(mnemonic.replacingOccurrences(of: " ", with: "").reversed())
        print(hashedMnemonic)
        guard let base64Encoded = hashedMnemonic.base64Encoded else {
            #if DEBUG
            fatalError()
            #else
            return nil
            #endif
        }
        
        print(base64Encoded)
        return prefix + base64Encoded.sha1()
    }
}
