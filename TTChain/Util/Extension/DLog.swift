//
//  DLog.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/13.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation

public func DLogDebug(_ string: Any? = String(), file: String = #file, line: Int = #line, function: String = #function) {
    print("📒 \(file.components(separatedBy: "/").last ?? String())[\(line)](\(function)): \(string ?? String())")
}

public func DLogWarn(_ string: Any? = String(), file: String = #file, line: Int = #line, function: String = #function) {
    print("⚠️ \(file.components(separatedBy: "/").last ?? String())[\(line)](\(function)): \(string ?? String())")
}

public func DLogInfo(_ string: Any? = String(), file: String = #file, line: Int = #line, function: String = #function) {
    print("ℹ️ \(file.components(separatedBy: "/").last ?? String())[\(line)](\(function)): \(string ?? String())")
}

public func DLogError(_ string: Any? = String(), file: String = #file, line: Int = #line, function: String = #function) {
    print("🚨 \(file.components(separatedBy: "/").last ?? String())[\(line)](\(function)): \(string ?? String())")
}
