//
//  TTNotificationHandler.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/27.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class TTNotificationHandler {
  
    static let shared:TTNotificationHandler = TTNotificationHandler.init()
    private let bag = DisposeBag.init()
    
    init() {
        
    }
    
    static func registerIMUserForNotification() {
        
        JPUSHService.registrationIDCompletionHandler {  _, registerID in
            guard let registerID = registerID else { return }
            DLogInfo(registerID)
            Server.instance.registerJiGuangPush(registrationId: registerID).subscribe(onSuccess: { response in
                switch response {
                case .success(_): DLogDebug("success regist")
                case .failed(error:let error):
                    DLogError(error)
                    DLogError(error)
                }
            }, onError: nil).disposed(by: TTNotificationHandler.shared.bag)
        }
    }
    
    static func deregisterIMUserFromNotification() {
        if (IMUserManager.manager.userModel.value?.uID) != nil {
            //Make sure the user is logged out
            IMUserManager.manager.userModel.accept(nil)
        }
        JPUSHService.registrationIDCompletionHandler {  _, registerID in
            guard let registerID = registerID else { return }
            DLogInfo(registerID)
            Server.instance.registerJiGuangPush(registrationId: registerID).subscribe(onSuccess: { response in
                switch response {
                case .success(_): DLogDebug("success Deregister")
                case .failed(error:let error):
                    DLogError(error)
                    DLogError(error)
                }
            }, onError: nil).disposed(by: TTNotificationHandler.shared.bag)
        }
    }
    
    func parseNotification(userInfo:[AnyHashable : Any]) {
     
        OWRxNotificationCenter.instance.notifyNotificationReceived()

        guard let messageDict = userInfo["msg_content"] as? [String:Any] else {
            return
        }

        guard var callMessageModel = CallMessageModel.init(json: messageDict) else {
            return
        }
        if let aps =  userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:String], let message = alert["body"] {
            callMessageModel.message = message
        }

        //Show Incoming Call if not already in call
        if !callMessageModel.isConnect {
            AVCallHandler.handler.otherUserCancelledCall()
            return
        }
        
        AVCallHandler.handler.showIncomingCall(forCallMessage: callMessageModel, calleeName: callMessageModel.roomName ?? "")

    }
    
   
}
