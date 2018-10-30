//
//  ServerAPIErrorTypes.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/17.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
//import Flurry_iOS_SDK

enum GTServerAPIError: Error {
    static var invalidTokenErrorRange = [9005, 9006]
    static var expiredTokenErrorCode = 9007
    
    case noData
    case incorrectResult(String, String)
    case noInternet
    case invalidToken
    case expiredToken
    case apiReject
    case invalidVerision
    case appDisabled
    
    //This case should directly pass response error to input
    case unknown(Error)
    
    var descString: String {
        get {
            switch self {
            case .incorrectResult(_, let message):
                return message
            case .noData:
                return LM.dls.g_error_emptyData
            case .noInternet:
                return LM.dls.g_error_networkUnreachable
            case .invalidToken:
                return LM.dls.g_error_tokenInvalid
            case .unknown(let err):
                return err.localizedDescription
            case .apiReject:
                return LM.dls.g_error_apiReject
            case .invalidVerision:
                return LM.dls.g_error_invalidVersion
            case .appDisabled:
                return LM.dls.g_error_appDisabled
            case .expiredToken:
                return LM.dls.g_error_tokenExpired
            }
        }
    }
}

class ServerAPIErrorHandler : NSObject {
    static func serverErrorType(of originError:Error) -> GTServerAPIError {
        return .unknown(originError)
    }
    
    static func serverWrongResultError(code: String, message:String) -> GTServerAPIError {
        return .incorrectResult(code, message)
    }
    
    static func serverNoDataError() -> GTServerAPIError {
        return .noData
    }
}
