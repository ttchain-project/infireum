//
//  KLMoyaAPIBase.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/18.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import RxSwift
import RxCocoa

//MARK: - Server Process Extensions
extension Single where Element == Any {
    func cacheResponseDataIfPossible<REQ: KLMoyaAPIData>(ofREQ req: REQ) -> Single<Element> {
        return asObservable().map {
            response -> Element in
            if let json = response as? [String : Any] {
                ErrorLogger.instance.cachedResponse(data: json, ofReq: req)
            }
            
            return response
            }.asSingle()
    }
    
    func filterServerWrongCode() -> Observable<Element> {
        return asObservable().map { response -> Element in
            if let json = response as? [String : Any] {
                if let status = json["code"] as? Int, !(status == 200 || status == 0)  {
                    //Removed the Error code check for particular error codes. // Discuss with Hermes if any problem
                    //                    if GTServerAPIError.invalidTokenErrorRange
                    //                        .contains(status) {
                    //                        throw GTServerAPIError.invalidToken
                    //                    }else if GTServerAPIError.expiredTokenErrorCode == status {
                    //                        throw GTServerAPIError.expiredToken
                    //                    }else {
                    throw GTServerAPIError.incorrectResult(String(status), json["message"] as! String)
                    //                    }
                }
                
                if let data = json["data"] {
                    return data
                }else {
                    return json as Any
                }
            } else {
                return response
            }
        }
    }
}


extension Observable where Element == JSON {
    func map<T: KLJSONMappableMoyaResponse>(to: T.Type, withAPI api: T.API) -> Observable<T> {
        let observ = self.map { (json) -> T in
            do {
                let t = try T.init(json: json, sourceAPI: api)
                return t
            }
            catch let e {
                throw e
            }
        }
        
        return observ
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    func cachedResponseHeaderAndRequestToErrorLogger<REQ: KLMoyaAPIData>(ofREQ req: REQ) -> PrimitiveSequence<TraitType, ElementType> {
        return map {
            source -> Response in
            let originReq = source.request
            ErrorLogger.instance.cachedReq(req: req, originReq: originReq)
            if let response = source.response {
                ErrorLogger.instance.cachedResponseHeader(
                    statusCode: response.statusCode,
                    header: response.allHeaderFields as? [String : Any],
                    ofReq: req
                )
            }
            
            return source
        }
    }
    
    //        func checkVersion() -> PrimitiveSequence<TraitType, ElementType> {
    //            return map {
    //                source -> Response in
    //                guard let response = source.response else {
    //                    return source
    //                }
    //
    //                let checkResult = VersionChecker.isVersionAcceptable(fromServerResponse: response)
    //                switch checkResult {
    //                case .localVersionIsNewer:
    //    //                URLSwitcher.switcher.switchToURLStrOfSpecificEnvironment(.sit)
    //                    return source
    //                case .localVersionIsSupported:
    //                    return source
    //                case .localVersionIsTooOld:
    //                    throw GTServerAPIError.invalidVerision
    //                }
    //            }
    //        }
    //
    //        func checkEnable() -> PrimitiveSequence<TraitType, ElementType> {
    //            return map {
    //                source -> Response in
    //                guard let response = source.response else {
    //                    return source
    //                }
    //
    //                let isAppDisabled = AppEnableChecker.isAppDisabled(fromServerResponse: response)
    //                guard !isAppDisabled else { throw GTServerAPIError.appDisabled }
    //
    //                return source
    //            }
    //        }
    
    
    func process<T: KLJSONMappableMoyaResponse>(to: T.Type, withAPI api: T.API) -> Observable<APIResult<T>> {
        return cachedResponseHeaderAndRequestToErrorLogger(ofREQ: api)
            .catchError({ (error) -> PrimitiveSequence<SingleTrait, Response> in
                let err = GTServerAPIError.unknown(error)
                return PrimitiveSequence.error(err)
            })
            //                .checkEnable()
            //                .checkVersion()
            
            .debug("json")
            .mapJSON()
            
            .cacheResponseDataIfPossible(ofREQ: api)
            .filterServerWrongCode()
            //                .reauthIfNeeded(maxTimes: C.Server.maxReAuthTimes)
            .map {
                raw -> JSON in
                if let err = raw as? Error {
                    throw GTServerAPIError.unknown(err)
                }
                
                if let json = JSON.init(rawValue: raw) {
                    return json
                    //                    if let errMsg = json["error"].string {
                    //                        throw GTServerAPIError.incorrectResult("9999", errMsg)
                    //                    }else {
                    //                        return json
                    //                    }
                }else {
                    throw GTServerAPIError.noData
                }
            }
            .map(to: T.self, withAPI: api)
            .map { result in
                ErrorLogger.instance.clearCache(ofReq: api)
                return APIResult<T>.success(result)
            }
            .catchError({ (error) -> Observable<APIResult<T>> in
                ErrorLogger.instance.cachedReq(req: api)
                ErrorLogger.instance.logErrorEvent(ofReq: api, error: error)
                ErrorLogger.instance.clearCache(ofReq: api)
                
                throw error
            })
            .catchError({ (error) -> Observable<APIResult<T>> in
                return Observable<APIResult<T>>.just(
                    APIResult.failed(error: (error as? GTServerAPIError) ?? GTServerAPIError.apiReject)
                )
            })
        
        //                .debug("process finish")
        
    }
}

//MARK: - Request APIs
protocol KLMoyaAPISet {
    var api: KLMoyaAPIData { get }
    var path: String { get }
    var task: Task { get }
    var method: Moya.Method { get }
    var stub: Data? { get }
    var headers: [String : String]? { get }
    
    var authNeeded: Bool { get }
    var langDepended: Bool { get }
}

extension KLMoyaAPISet {
    var authNeeded: Bool {
        return api.authNeeded
    }
    
    var langDepended: Bool {
        return api.langDepended
    }
    
    var headers: [String : String]? {
        return api.headers
    }
    
    var path: String {
        return api.path
    }
    
    var method: Moya.Method {
        return api.method
    }
    
    var task: Moya.Task {
        return api.task
    }
    
    var stub: Data? {
        return api.stub
    }
}

//MARK: - Response Models
protocol KLJSONMappableMoyaResponse {
    associatedtype API: KLMoyaAPIData
    init(json: JSON, sourceAPI: API) throws
}

/// This defines the basic data need to implement per api
enum APIBaseEndPointType {
    case system
    case custom(url: URL)
}

protocol KLMoyaAPIData {
    var base: APIBaseEndPointType  { get }
    var path: String { get }
    var method: Moya.Method { get }
    var headers: [String : String]? { get }
    
    var loggerTask: Moya.Task { get }
    
    var task: Moya.Task { get }
    var stub: Data? { get }
    
    var authNeeded: Bool { get }
    var langDepended: Bool { get }
}

extension KLMoyaAPIData {
    var base: APIBaseEndPointType {
        return .system
    }
    
    var headers: [String : String]? {
        var h = [String : String]()
        //        if authNeeded {
        //            h["authorization"] = UserRoleHandler.handler.authedMember?.authToken ?? ""
        //        }
        
        if langDepended {
            h["lang"] = LangManager.instance.lang.value._db_name
        }
        
        return h
    }
    
    var loggerTask: Moya.Task {
        return task
    }
}

protocol KLMoyaLangAPIData: KLMoyaAPIData { }
protocol KLMoyaLangAuthAPIData: KLMoyaLangAPIData {}
extension KLMoyaLangAPIData {
    var langDepended: Bool { return true }
    var authNeeded: Bool { return false }
}

extension KLMoyaLangAuthAPIData {
    var langDepended: Bool { return true }
    var authNeeded: Bool { return true }
}


protocol KLMoyaIMAPIData: KLMoyaAPIData { }
extension KLMoyaIMAPIData {
    var langDepended: Bool { return false }
    var authNeeded: Bool { return false }
    
    var headers: [String : String]? {
        var h = [String : String]()
        
        h["SystemId"] = "2"
        return h
    }
}

protocol KLMoyaRocketChatAPIData:KLMoyaIMAPIData {
    var rocketChatAuthNeeded : Bool { get }
}

extension KLMoyaRocketChatAPIData {
    var headers: [String : String]? {
        var h = [String : String]()
        //        if authNeeded {
        //            h["authorization"] = UserRoleHandler.handler.authedMember?.authToken ?? ""
        //        }
        
        if langDepended {
            h["lang"] = LangManager.instance.lang.value._db_name
        }
        
        if rocketChatAuthNeeded {
            h["X-Auth-Token"] = RocketChatManager.manager.rocketChatUser.value?.authToken
            h["X-User-Id"]  = RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId
        }
        return h
    }
    
}

//MARK: - Mocking
protocol MockableAPI {
    static func mock() -> Self
}
