//
//  APISensitiveDataCrypter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/29.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

struct APISensitiveDataCrypter {
    //MAKR: - Any
    static func decrypt(enc: String) throws -> String {
        guard let raw = enc.aes256Decrypt(key: C.Crypto.AES.key.md5(), iv: C.Crypto.AES.iv) else {
            throw GTServerAPIError.incorrectResult("", LM.dls.g_error_decryptFail_mnemonic)
        }
        
        return raw
    }
    
    //MARK: - Mnemonic
    static func encryptMnemonic(rawMnemonic: String) throws -> String {
//        return rawMnemonic
        
        guard let encryptedMnemonic = rawMnemonic.aes256Encrypt(key: C.Crypto.AES.key.md5(), iv: C.Crypto.AES.iv) else {
            throw GTServerAPIError.incorrectResult("", LM.dls.g_error_encryptFail_mnemonic)
        }
        
        return encryptedMnemonic
    }
    
    static func decryptEncryptedMnemonic(encryptedMnemonic: String) throws -> String {
//        return encryptedMnemonic
        
        guard let menmonic = encryptedMnemonic.aes256Decrypt(key: C.Crypto.AES.key.md5(), iv: C.Crypto.AES.iv) else {
            throw GTServerAPIError.incorrectResult("", LM.dls.g_error_decryptFail_mnemonic)
        }
        
        return menmonic
    }
    
    //MARK: - Prirvate Key
    static func encryptPrivateKey(rawPrivateKey: String) throws -> String {
//        return rawPrivateKey
        
        guard let encryptedPrivateKey = rawPrivateKey.aes256Encrypt(key: C.Crypto.AES.key.md5(), iv: C.Crypto.AES.iv) else {
            throw GTServerAPIError.incorrectResult("", LM.dls.g_error_encryptFail_privateKey)
        }
        
        return encryptedPrivateKey
    }
    
    static func decryptEncryptedPrivateKey(encryptedPricateKey: String) throws -> String {
//        return encryptedPricateKey
        
        guard let privateKey = encryptedPricateKey.aes256Decrypt(key: C.Crypto.AES.key.md5(), iv: C.Crypto.AES.iv) else {
            throw GTServerAPIError.incorrectResult("", LM.dls.g_error_decryptFail_privateKey)
        }
        
        return privateKey
    }
}
