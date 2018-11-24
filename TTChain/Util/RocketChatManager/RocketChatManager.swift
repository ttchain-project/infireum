//
//  RocketChatManager.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class RocketChatManager {
    
    let bag = DisposeBag.init()
    
    static var manager: RocketChatManager!
    static func launch() {
        manager = RocketChatManager.init()
    }
    init() {
        IMUserManager.manager.shouldLoginToRocketChat.asObserver().subscribe(onNext: { (_) in
            self.loginRocketChat()
        }).disposed(by: bag)
    }
    
    var rocketChatUser: BehaviorRelay<RocketChatUser?> = BehaviorRelay.init(value: nil)
    
    
    func loginRocketChat()  {
        guard let userModel = IMUserManager.manager.userModel.value else {
            return
        }
        Server.instance.loginRocketChat(userID: userModel.uID, password:userModel.uID).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(let err):
                switch err {
                case .expiredToken:
                    print("prelogin again")
                default:
                    print("Issues with login")
                }
            case .success(let model):
                let rocketChatModel = RocketChatUser.init(rocketChatUserId: model.rocketChatUserId, authToken: model.authToken, name: model.username)
                line()
                print(model.rocketChatUserId + " auth " + model.authToken + " username " + model.username)
                line()
                self.rocketChatUser.accept(rocketChatModel)
            }
        }).disposed(by: bag)
    }
}
