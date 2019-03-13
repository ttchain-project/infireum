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
                    DLogError(error.localizedDescription)
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
                    DLogError(error.localizedDescription)
                }
            }, onError: nil).disposed(by: TTNotificationHandler.shared.bag)
        }
    }
    
    func parseNotification(userInfo:[AnyHashable : Any]) {
     
        OWRxNotificationCenter.instance.notifyNotificationReceived()

        guard let apsDict = userInfo["aps"] as? [String:Any], let alert = apsDict["alert"] as? [String:Any],let messageBody = alert["body"] as? String else {
            return
        }
        var headImgURL:URL
        let headImg = userInfo["headImg"] as! String
        headImgURL = URL.init(string: headImg)!
        
        var callTitle :String = ""
        if userInfo["roomName"] as? String != nil {
            callTitle = userInfo["roomName"] as! String
        }
        
        guard let messageData = messageBody.data(using: .utf8),let dict = try! JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] else{
            return
        }
        
        guard let callMessageModel = CallMessageModel.init(json: dict) else {
            return
        }
         let rootVC = UIApplication.shared.keyWindow?.rootViewController
        //Show Incoming Call if not already in call
            let incomingCallVC = IncomingCallViewController.instance(from: IncomingCallViewController.Config(callModel: callMessageModel, headImage: headImgURL, callTitle: callTitle, didReceiveCall: {
                result in
                if result {
                    self.connectCall(forRoom: callMessageModel.roomId, calleeName: callTitle, streamId: callMessageModel.streamId)
                    
                } else {
                    
                }
                
            }))
        
        
            rootVC?.present(incomingCallVC, animated: true, completion: nil)
    }
    
    private func connectCall(forRoom roomId:String, calleeName:String, streamId:String) {
        let config = AudioCallViewController.Config.init(roomId: roomId, calleeName: calleeName, roomType: .pvtChat, callAction: CallAction.joinCall, streamId: streamId)
        let audioCallVC = AudioCallViewController.instance(from: config)
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.present(audioCallVC, animated: true, completion: nil)
    }
}
