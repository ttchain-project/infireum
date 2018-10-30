//
//  UIViewController+ReachabilityMonitor.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

protocol RxNetworkReachabilityRespondable {
    var networkBag: DisposeBag { get set }
    func monitorNetwork(handler: @escaping NetworkStatusReponder, inBag bag: DisposeBag)
    func monitorNetwork(handler: @escaping NetworkStatusReponder)
}

extension RxNetworkReachabilityRespondable {
    func monitorNetwork(handler: @escaping NetworkStatusReponder, inBag bag: DisposeBag) {
        NetworkReachabilityHandler.instance.reachable
            .scan([], accumulator: { (seed, newStatus) -> [NetworkStatus] in
                guard !seed.isEmpty else { return [ newStatus ] }
                return [ seed.last!, newStatus ]
            })
            .filter {
                statuses -> Bool in
//                print("Calculate statues: \(statuses)")
                guard !statuses.isEmpty else { return false }
                if statuses.count >= 2 {
                    return statuses[1].hasNetwork != statuses[0].hasNetwork
                }else {
                    return !statuses.first!.hasNetwork
                }
            }
            .map { $0.last! }
            .subscribe(onNext: {
                status in
                handler(status)
            })
        .disposed(by: bag)
    }
    
    func monitorNetwork(handler: @escaping NetworkStatusReponder) {
        monitorNetwork(handler: handler, inBag: networkBag)
    }
}
