//
//  ErrorLogger.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/5/21.
//  Copyright © 2018年 GIT. All rights reserved.
//

import Foundation
import Moya
import Firebase
import Flurry_iOS_SDK

class ErrorLogger {
    static let instance: ErrorLogger = ErrorLogger.init()
    var paramCache: [String : [String : Any]] = [ : ]
    var maintenanceURL: URL?
    private func key<REQ: KLMoyaAPIData>(ofREQ req: REQ) -> String {
        return String(req.path.hashValue &+ req.method.hashValue)
    }
    
    @discardableResult func cachedReq<REQ: KLMoyaAPIData>(req: REQ, originReq: URLRequest? = nil) -> [String : Any] {
        let key = self.key(ofREQ: req)
        let reqData: [String:Any]
        switch req.loggerTask {
        case .requestParameters(parameters: let p, encoding: _):
            reqData = p
        default: reqData = [:]
        }
        
        var params: [String : Any] = [
            "path" : req.path,
            "reqHeader" : req.headers ?? [:],
            "reqData" : reqData
        ]
        
        if let oReq = originReq {
            if let oHeader = oReq.allHTTPHeaderFields {
                params["originReqHeaders"] = oHeader
            }
            
            if let oBody = oReq.httpBody {
                let prettyPrintStr = String.init(data: oBody, encoding: .utf8) ?? ""
                params["originReqData"] = prettyPrintStr
            }
        }
        
        if let cache = paramCache[key] {
            var newCache = cache
            for (k, v) in params {
                newCache[k] = v
            }
            
            paramCache[key] = newCache
            
        }else {
            paramCache[key] = params
        }
        
        return paramCache[key]!
    }
    
    @discardableResult func cachedResponseHeader<REQ: KLMoyaAPIData>(statusCode: Int, header: [String : Any]?, ofReq req: REQ) -> [String : Any] {
        cachedReq(req: req)
        
        let key = self.key(ofREQ: req)
        let usefulHeader: [String : Any]
        
        if let h = header {
            usefulHeader = extractUsefulResponseHeader(from: h)
        }else {
            usefulHeader = [:]
        }
        
        if let cache = paramCache[key] {
            var newCache = cache
            newCache["resCode"] = statusCode
            newCache["resHeader"] = usefulHeader
            paramCache[key] = newCache
        }else {
            paramCache[key] = [
                "resCode" : statusCode,
                "resHeader" : usefulHeader
            ]
        }
        guard let h = header ,let maintenanceURLString = h["maintain-url"] as? String else {
            return paramCache[key]!
        }
        maintenanceURL = URL.init(string: maintenanceURLString)
        return paramCache[key]!
    }
    
    private func extractUsefulResponseHeader(from header: [String : Any]) -> [String : Any] {
        let usefulKeys: [String] = [
            "X-iOS-Version",
            "x-ios-is-disable",
            "Date"
        ]
        
        var result = [String:Any]()
        for key in usefulKeys {
            if let v = header[key] {
                result[key] = v
            }
        }
        
        return result
    }
    
    @discardableResult func cachedResponse<REQ: KLMoyaAPIData>(data: [String:Any], ofReq req: REQ) -> [String : Any] {
        cachedReq(req: req)
        
        let key = self.key(ofREQ: req)
        if let cache = paramCache[key] {
            var newCache = cache
            newCache["resData"] = data
            paramCache[key] = newCache
        }else {
            paramCache[key] = [
                "resData" : data
            ]
        }
        
        return paramCache[key]!
    }
    
    private var userParams: [String : Any] {
//        guard let handler = UserRoleHandler.handler,
//            let member = handler.authedMember else {
            return [:]
//        }
//        
//        return ["name" : member.name, "sysID": member.id, "mobile" : member.account.fullNumber]
    }
    
    private var envParams: [String : Any] {
        let env: String
        let version = C.Application.version
        #if PRD || PRD_TEST
        env = "PRD"
        #elseif UAT
        env = "UAT"
        #else
        env = "SIT"
        #endif
        
        let osVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        return ["version" : version, "env" : env, "OSName" : osName, "OSVersion" : osVersion]
    }
    
    func logErrorEvent<REQ: KLMoyaAPIData>(
        ofReq req: REQ, error: Error
        ) {
        let key = self.key(ofREQ: req)
        var params = paramCache[key]
        guard params != nil else { return }
        let errorDescription: String
        if let serverError = error as? GTServerAPIError {
            switch serverError {
            case .unknown(let e):
                errorDescription = e.localizedDescription
            case .incorrectResult(_, let content):
                errorDescription = content
            default:
                errorDescription = serverError.localizedDescription
            }
        }else {
            errorDescription = error.localizedDescription
        }
        params!["error"] = errorDescription
        
        //Append user and env info
        params!["user"] = userParams
        params!["environment"] = envParams
        
//        let json = try! JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
//        let decode = try! JSONSerialization.jsonObject(with: json, options: []) as! [AnyHashable : Any]
//        print(decode)
        
        var flattenedParams: [String : String] = [:]
        let desiredString: (String) -> String = {
            str in
            let nsStr = str as NSString
            let maxCharIdx = min(nsStr.length, 255)
            return nsStr.substring(to: maxCharIdx)
        }
        
        for (k, v) in params! {
            if let dict = v as? [String : Any] {
                let json = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let prettyPrintStr = String.init(data: json, encoding: .utf8) ?? ""
                flattenedParams[k] = desiredString(prettyPrintStr)
            }else if let str = v as? String {
                flattenedParams[k] = desiredString(str)
            }
        }
        
//        let dictionary = NSDictionary.init(dictionary: params!)
        Flurry.logEvent("APIError", withParameters: flattenedParams)
    }
    
    func clearCache<REQ: KLMoyaAPIData>(ofReq req: REQ) {
        let key = self.key(ofREQ: req)
        paramCache[key] = nil
    }
}
