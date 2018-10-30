//
//  GTTypeDefs.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/11.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation

//MARK: - Server Interaction Response
// T would be success return type.
enum GTProcessResult<T> {
    case success(T)
    case failure(GTServerAPIError?)
}

typealias GTResponseHandler<T> = (_ result: GTProcessResult<T>) -> Void
