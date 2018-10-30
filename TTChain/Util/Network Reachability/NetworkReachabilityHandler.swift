//
//  NetworkReachabilityHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Reachability

enum NetworkStatus {
    case reachable
    case unreachable
    case notDetermined
    
    var hasNetwork: Bool {
        return self == .reachable
    }
}

typealias NetworkStatusReponder = (NetworkStatus) -> Void

class NetworkReachabilityHandler {
    static let instance: NetworkReachabilityHandler = NetworkReachabilityHandler()
    private var reachability: Reachability = Reachability.init()!
    lazy var reachable: BehaviorRelay<NetworkStatus> = {
        let connection = reachability.connection
        switch connection {
        case .wifi, .cellular:
            return BehaviorRelay.init(value: .reachable)
        case .none:
            return BehaviorRelay.init(value: .unreachable)
        }
    }()
    
    init() {
        reachability.whenReachable = {
            [unowned self]
            _ in
            self.reachable.accept(.reachable)
        }
        
        reachability.whenUnreachable = {
            [unowned self]
            _ in
            self.reachable.accept(.unreachable)
        }
        
        do {
            try reachability.startNotifier()
//            bindingReachablityChange()
        } catch let e {
            print("Unable to start notifier for error: \(e)")
        }
    }
    
//    private func bindingReachablityChange() {
//        reachable.asObservable().distinctUntilChanged({ (prev, new) -> Bool in
//            //This part is only for filter out init 'valid' state,
//            //which will from .notDetermined to .reachable, in this case we don't need to obeverve.
//            if prev == .notDetermined && new == .reachable {
//                return true
//            }else {
//                //all other case will be observ, since the same case will not trigger banner update so sending same event is acceptable here.
//                return false
//            }
//        })
//            .map {
//                r -> Bool in
//                switch r {
//                case .reachable: return true
//                default: return false
//                }
//            }
//            //            .skip(1)
//            .bind(to: onReachabilityChange)
//            .disposed(by: bag)
//    }
}
