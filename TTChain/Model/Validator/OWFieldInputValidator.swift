//
//  OWFieldInputValidator.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import HDWalletKit

enum OWInputFieldValidateResult {
    case valid
    case incorrectFormat(desc: String)
}

extension String {
    var hasWhiteSpacePrefixOrSuffix: Bool {
        return hasPrefix(" ") || hasSuffix(" ")
    }
    
    var ow_isValidIdentityName: OWInputFieldValidateResult {
        //Whitespace check
        guard !hasWhiteSpacePrefixOrSuffix else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_spacePrefixOrSuffix(
                    LM.dls.strValidate_field_identityName
                )
            )
        }
        
        //Invalid char check
        //        let scanner = Scanner.init(string: self)
        //
        //        let result = scanner.scanUpToCharacters(from: NSCharacterSet.alphanumerics.inverted,
        //                               into: nil)
        //        guard !result else {
        //            return .incorrectFormat(desc: "名称不得含有符号字元")
        //        }
        
        //Length check
        guard count > 0 && count <= 30 else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_lengthInvalid(
                    LM.dls.strValidate_field_identityName, "1", "30"
                )
            )
        }
        
        return .valid
    }
    
    var ow_isValidWalletPwd: OWInputFieldValidateResult {
        //Whitespace check
        guard !hasWhiteSpacePrefixOrSuffix else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_spacePrefixOrSuffix(
                    LM.dls.strValidate_field_pwd
                )
            )
        }
        
        //Invalid char check
        let regexStr = "[^0-9a-zA-Z]"
        let regex = try! NSRegularExpression.init(pattern: regexStr, options: .caseInsensitive)
        guard regex.firstMatch(in: self, options: .reportCompletion, range: NSRange.init(location: 0, length: count)) == nil else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_allowAlphanumericOnly(
                    LM.dls.strValidate_field_pwd
                )
            )
        }
        
        //Length check
        guard count >= 8 && count <= 20 else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_lengthInvalid(
                    LM.dls.strValidate_field_pwd, "8", "20"
                )
            )
        }
        
        return .valid
    }
    
    func ow_isValidConfirmPwd(pwd: String) -> OWInputFieldValidateResult {
        return self == pwd ? .valid : .incorrectFormat(desc: LM.dls.strValidate_error_confirmPwd_diffWithPwd)
    }
    
    var ow_isValidPwdHint: OWInputFieldValidateResult {
        //Whitespace check
        guard !hasWhiteSpacePrefixOrSuffix else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_spacePrefixOrSuffix(
                    LM.dls.strValidate_field_pwdHint
                )
            )
        }
        
        //Invalid char check
        //        let scanner = Scanner.init(string: self)
        //        let result = scanner.scanUpToCharacters(from: NSCharacterSet.alphanumerics.inverted,
        //                                                into: nil)
        //        guard !result else {
        //            return .incorrectFormat(desc: "密码提示讯息不得含有符号字元")
        //        }
        
        //Length check
        guard count > 0 && count <= 256 else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_lengthInvalid(
                    LM.dls.strValidate_field_pwdHint, "1", "256"
                )
            )
        }
        
        return .valid
    }
    
    var ow_isValidMnemonic: OWInputFieldValidateResult {
        //Whitespace check
        guard !hasWhiteSpacePrefixOrSuffix else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_spacePrefixOrSuffix(
                    LM.dls.strValidate_field_mnemonic
                )
            )
        }
        
        //Words count check
        let seps = split(separator: " ", omittingEmptySubsequences: false)
        guard seps.count >= 12 else {
            return .incorrectFormat(desc: LM.dls.strValidate_error_mnemonic_12WordsAtLeast)
//            return .incorrectFormat(desc: "助记词格式错误，请确认是否输入正确，单词必须以英文小写输入，并且必须使用一个半形空白分开各个单词")
        }
        
        let mnemonicSet = Set.init(words())
        let mnemonicSuperSetForEnglish = Set.init(WordList.english.words)
        let mnemonicSuperSetForChinese = Set.init(WordList.simplifiedChinese.words)
        if !mnemonicSet.isSubset(of: mnemonicSuperSetForEnglish), !mnemonicSet.isSubset(of: mnemonicSuperSetForChinese){
            return .incorrectFormat(desc: LM.dls.invalid_mnemonic_phrase)
        }
        
        
        //No checks for invalid characters as we have chinese mnemonics now!!
//        let regexStr = "[^a-z]"
//        let regex = try! NSRegularExpression.init(pattern: regexStr,
//                                                  options: .caseInsensitive)
//
//        for sep in seps {
//            let str = String(sep)
//            guard (str.lowercased() == str) else {
//                return .incorrectFormat(desc: LM.dls.strValidate_error_mnemonic_containUppercase(str)
//                )
//            }
//
//            let regexCheck = regex.matches(in: str,
//                                           options: .reportCompletion,
//                                           range: NSRange.init(location: 0,
//                                                               length: str.count))
//
//            guard str.count > 0 && regexCheck.count == 0 else {
//                return .incorrectFormat(desc: LM.dls.strValidate_error_mnemonic_invalidCharacter(str)
//                )
//            }
//        }
        
        return .valid
    }
    
    var ow_isValidWalletName: OWInputFieldValidateResult {
        //Whitespace check
        guard !hasWhiteSpacePrefixOrSuffix else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_spacePrefixOrSuffix(
                    LM.dls.strValidate_field_walletName
                )
            )
        }
        
        //Length check
        guard count > 0 && count <= 30 else {
            return .incorrectFormat(desc: LM.dls
                .strValidate_error_common_lengthInvalid(
                    LM.dls.strValidate_field_walletName, "1", "30"
                )
            )
        }
        
        return .valid
    }
}
