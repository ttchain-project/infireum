//
//  Router.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/1/23.
//  Copyright © 2018年 GIT. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import RxSwift


//MARK: - Router

/// Router defines what kind of api the server has.
///
/// - auth:
enum Router: TargetType {
    case blockchain(BlockchainAPI)
    case helper(HelperAPI)
    case IM(IMAPI)
    case rocketChat(RocketChatAPI)
    var api: KLMoyaAPISet {
        switch self {
        case .blockchain(let endpoint): return endpoint
        case .helper(let endpoint): return endpoint
        case .IM(let endpoint): return endpoint
        case .rocketChat(let endpoint): return endpoint
        }
    }
    
    var baseURL: URL {
        switch api.api.base {
        case .system:
            switch self {
            case .blockchain:
                return URL.init(string: C.BlockchainAPI.urlStr_3206)!
            case .helper:
                return URL.init(string: C.HTTPServerAPI.urlStr)!
            case .IM:
                return URL.init(string: C.HTTPServerAPI.urlStr)!
            case .rocketChat:
                return URL.init(string: C.HTTPServerAPI.rocketChatURL)!
            }
        case .custom(let url):
            return url
        }
        
    }
    
    var path: String {
        var p: String
        //        if api.langDepended {
        //            p = "/\(LanguageHandler.systemLang)" + api.path
        //        }else {
        p = api.path
        //        }
        
        //        print("path is: \(p)")
        return p
    }
    
    var method: Moya.Method { return api.method }
    var sampleData: Data { return api.stub ?? "".data(using: .utf8)! }
    var task: Task {
        return api.task
    }
    
    var headers: [String : String]? {
        return api.headers
    }
    
    
}


