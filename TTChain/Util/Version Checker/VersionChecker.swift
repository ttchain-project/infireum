//
//  VersionChecker.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/8/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class VersionChecker: NSObject {
    enum VersionCompareResult {
        case new
        case old
        case same
    }
    
    struct Helper {
        static func parse(versionString version: String) -> (major: Int, minor: Int, build: Int)? {
            let infos = version.split(separator: ".")
            guard infos.count >= 3 else {
                return nil
            }
            
            guard let major = Int(infos[0]),
                let minor = Int(infos[1]),
                let build = Int(infos[2]) else {
                    return nil
            }
            
            return (major: major, minor: minor, build: build)
        }
        
        static func compare(version: String, toAnotherVersion version2: String) -> VersionCompareResult {
            guard let fromInfo = parse(versionString: version),
                let toInfo = parse(versionString: version2) else {
                    return .same
            }
            
            guard fromInfo.major == toInfo.major else {
                return fromInfo.major > toInfo.major ? .new : .old
            }
            
            guard fromInfo.minor == toInfo.minor else {
                return fromInfo.minor > toInfo.minor ? .new : .old
            }
            
            guard fromInfo.build == toInfo.build else {
                return fromInfo.build > toInfo.build ? .new : .old
            }
            
            return .same
        }
    }
    
    
    enum CheckResult {
        case localVersionIsNewer
        case localVersionIsTooOld
        case localVersionIsSupported
    }
    
    static let sharedInstance = VersionChecker.init()
    private var _isVersionValid: Bool = true
    private var checkDate: Date?
    private var versionCheckingSharedSequence: RxAPIResponse<CheckResult>?
    
    func updateVersionValidity(to validity: Bool) {
        _isVersionValid = validity
    }
    
    var isVersionValid: Bool {
        return _isVersionValid
    }

    var shouldCheck: Bool {
        return true
    }
    
    func getVersion() -> RxAPIResponse<(latest: String, min: String)> {
        return Server.instance.getVersion()
            .map {
                result in
                switch result {
                case .failed(error: let err): return .failed(error: err)
                case .success(let model): return .success((latest: model.latest, min: model.minimum))
                }
            }
    }
    
    //Will recheck per day
    private var recheckInterval: TimeInterval {
        return 86400
    }
    
    private func shouldReCheckVersionNow() -> Bool {
        guard let latestCheckedDate = checkDate else { return true }
        return Date().timeIntervalSince(latestCheckedDate) > recheckInterval
    }
    
    func checkVersionIfNeeded() -> RxAPIResponse<CheckResult> {
        if shouldReCheckVersionNow() {
            return versionCheckingSharedSequence ?? checkVersion()
        }
        else {
            let result: CheckResult = isVersionValid ? .localVersionIsSupported : .localVersionIsTooOld
            return RxAPIResponse.just(.success(result))
        }
    }
    
    func checkVersion() -> RxAPIResponse<CheckResult> {
        if let currentReq = versionCheckingSharedSequence {
            return currentReq
        }else {
            versionCheckingSharedSequence = getVersion()
                .map {
                    [unowned self]
                    result in
                    switch result {
                    case .failed(error: let err):
                        return .failed(error: err)
                    case .success(let versions):
                        return .success(self.isVersionAcceptable(versions.min))
                    }
            }
            
            return checkVersion()
        }
    }
    
    func isVersionAcceptable(_ minVersion: String) -> CheckResult {
        //Only update value when version is invalid
        var acceptable: Bool = true
        defer {
            updateVersionValidity(to: acceptable)
            checkDate = Date()
        }
        
        guard shouldCheck else {
            return .localVersionIsSupported
        }
        
        let curVer = C.Application.version
        switch Helper.compare(version: curVer, toAnotherVersion: minVersion) {
        case .new:
            return .localVersionIsNewer
        case .old:
            return .localVersionIsTooOld
        case .same:
            return .localVersionIsSupported
        }
    }
}
