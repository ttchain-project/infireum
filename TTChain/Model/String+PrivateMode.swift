//
//  String+PrivateMode.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/26.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
extension String {
    /// Will change the string to disguisedValueStr in Constants if the private mode is enabled in the SettingsManager
    ///
    /// - Returns: 
    func disguiseIfNeeded() -> String {
        return SettingsManager.isPrivateModeEnabled ? C.PrivateMode.disguisedValueStr : self
    }
}
