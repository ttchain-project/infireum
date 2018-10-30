//
//  KLDebugHelper.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation

func errorDebug<E>(response: E) -> E {
    #if DEBUG
    fatalError()
    #else
    return response
    #endif
}
