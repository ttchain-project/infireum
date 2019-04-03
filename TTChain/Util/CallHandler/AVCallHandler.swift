//
//  AVCallHandler.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum CallType:String,Codable {
    case audio = "audio"
    case video = "video"
}


enum CallStatus {
    case dialing
    case ringing
    case incoming
    case connected
    case otherClientConnected
    case disconnected
}

fileprivate let SERVER_HOST_URL = "https://appr.tc"

class AVCallHandler : NSObject{
    
    static let handler = AVCallHandler.init()
    
    let bag: DisposeBag
    
    struct CallDetails {
        let currentCallRoomId:String
        let currentCallType:CallType
        
        var currentCallStreamId:String? = nil
    }
    
    private var callDetails:CallDetails?
    
    private var _currentCallStatus:BehaviorRelay<CallStatus?> = BehaviorRelay.init(value: nil)
    public var currentCallingStatus : Observable<CallStatus?> {
        return self._currentCallStatus.asObservable()
    }
    
    public func isInCall() -> Bool {
        return self.callDetails != nil
    }
    private var client:ARDAppClient?
    
    override init() {
        self.bag = DisposeBag.init()
    }
    
    func initiateAudioCall(forRoomId roomId:String) {
        guard self.callDetails == nil else {
            return
        }
        self.callDetails = CallDetails.init(currentCallRoomId: roomId, currentCallType: CallType.audio,currentCallStreamId: nil)
        self.initiateCall()
    }
    
    func initiateVideoCall(forRoomId roomId:String) {
        guard self.callDetails == nil else {
            return
        }
        self.callDetails = CallDetails.init(currentCallRoomId: roomId, currentCallType: CallType.video, currentCallStreamId: nil)
        self.initiateCall()
    }
    
    func endCall() {
       
        self.updateCallStatusToEndCall()
        self.disconnectCall()
    }
    
    func otherUserCancelledCall() {
        self.disconnectCall()
    }
    
    func startIncomingCall(callMessageModel:CallMessageModel) {
        guard self.callDetails == nil else {
            return
        }
        self.callDetails = CallDetails.init(currentCallRoomId: callMessageModel.roomId, currentCallType: callMessageModel.type, currentCallStreamId: callMessageModel.streamId)
        self._currentCallStatus.accept(.incoming)
    }
    
    func acceptCall() {
        
        self.createARDAppClient()
        guard let client = self.client, self.callDetails != nil else {
            return
        }
        client.connectToRoom(withId: self.callDetails?.currentCallStreamId,
                             forVideoCall:false ,
                             options: [:])
    }
    
    private func initiateCall() {
        
        
        guard let callDetails = self.callDetails else {
            return
        }
        self._currentCallStatus.accept(.dialing)

        let parameter = InAppCallApi.Parameter.init(type: callDetails.currentCallType,
                                                    roomId: callDetails.currentCallRoomId ,
                                                    isGroup: false,
                                                    isConnect: true,
                                                    streamId:nil)
        
        let initiateCall = Server.instance.initiateInAppCall(parameter: parameter)
        
        initiateCall.asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .success(let model):
                DLogDebug("Call Stream Id \(model.streamId)")
                guard let `self` = self else {
                    return
                }
                self.callDetails?.currentCallStreamId = model.streamId
                self._currentCallStatus.accept(.ringing)
                self.startCall()
            case .failed(error: let error):
                DLogError("Call Initiate Error \(error.descString) ")
            }
        }).disposed(by: bag)
    }
    
    private func disconnectCall() {
        self._currentCallStatus.accept(.disconnected)
        guard self.client != nil else {
            return
        }
        self.client?.disconnect()
    }
    
    private func startCall() {
        guard let callDetail = self.callDetails else {
            return
        }
        self.createARDAppClient()
        guard let client = self.client else {
            return
        }
        client.connectToRoom(withId: callDetail.currentCallStreamId,
                             forVideoCall:callDetail.currentCallType == .audio ?  false : true ,
                             options: [:])
        
    }
    
    func updateCallStatusToEndCall() {
        
        guard let callDetails = self.callDetails else {
            return
        }
        
        let parameter = InAppCallApi.Parameter.init(type:.audio,
                                                    roomId: callDetails.currentCallRoomId,
                                                    isGroup: false,
                                                    isConnect: false,
                                                    streamId:callDetails.currentCallStreamId)
        
        let callStatusAPI = Server.instance.initiateInAppCall(parameter: parameter)
        
        callStatusAPI.asObservable().subscribe(onNext: {[weak self] (result) in
            guard let `self` = self else {
                return
            }
            switch result {
            case .success(let model):
                DLogDebug("Call Disconnected for Stream Id \(model.streamId)")
                self._currentCallStatus.accept(nil)
                self.callDetails = nil
            case .failed(error: let error):
                DLogError("Call Disconnection Error \(error.descString) ")
                self._currentCallStatus.accept(nil)
                self.callDetails = nil
            }
        }).disposed(by: bag)
    }
    
    private func createARDAppClient() {
        self.client = ARDAppClient.init(delegate: self)
        self.client?.serverHostUrl = SERVER_HOST_URL
    }
    
    public func muteCall(shouldMute:Bool) {
        guard self.client != nil else{
            return
        }
        if shouldMute {
            self.client?.muteAudioIn()
        }else {
            self.client?.unmuteAudioIn()
        }
    }
    
    public func speakerOn(shouldOn:Bool) {
        guard self.client != nil else{
            return
        }
        if shouldOn {
            self.client?.enableSpeaker()
        }else {
            self.client?.disableSpeaker()
        }
    }
}

extension AVCallHandler:ARDAppClientDelegate {
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch (state) {
        case ARDAppClientState.connected:
            self._currentCallStatus.accept(.connected)
            DLogInfo("ADRAppClient Status Update - connected")

            break
        case ARDAppClientState.connecting:
            DLogInfo("ADRAppClient Status Update - connecting")
            break
        case ARDAppClientState.disconnected:
            self._currentCallStatus.accept(.disconnected)
            DLogInfo("ADRAppClient Status Update - disconnected")
            self.callDetails = nil
            break
        }
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        DLogDebug("Received LOCAL Video Track")

    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        DLogDebug("Received REMOTE Video Track")
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteAudioTrack remoteAudioTrack: RTCAudioTrack!) {
        DLogDebug("Received REMOTE Audio Track")
        self._currentCallStatus.accept(.otherClientConnected)
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        DLogError("Error in Call - \(error!)")
    }
}


extension AVCallHandler {
    
    func showIncomingCall(forCallMessage callMessageModel:CallMessageModel, calleeName:String) {
       
        let streamComponent = callMessageModel.streamId.components(separatedBy: "_")
        
        guard streamComponent.count > 0  else {
            return
        }
        let timestamp = streamComponent[1]

        if Date().timeIntervalSince(Date.init(unixTimestamp: timestamp.doubleValue)) > 60 {
            return
        }
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let incomingCallVC = IncomingCallViewController.instance(from: IncomingCallViewController.Config(callModel: callMessageModel, headImage: nil, callTitle: calleeName, didReceiveCall: { [weak self]
            result in
            guard let `self` = self else {
                return
            }
            if result {
                self.connectCall(forRoom: callMessageModel.roomId, calleeName: calleeName, streamId: callMessageModel.streamId)
            } else {
                AVCallHandler.handler.endCall()
            }
            
        }))
        
        rootVC?.present(incomingCallVC, animated: true, completion: nil)
    }
    
    private func connectCall(forRoom roomId:String, calleeName:String, streamId:String) {
        let config = AudioCallViewController.Config.init(roomId: roomId, calleeName: calleeName, roomType: .pvtChat, callAction: CallAction.joinCall, streamId: streamId)
        let audioCallVC = AudioCallViewController.instance(from: config)
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.present(audioCallVC, animated: false, completion: nil)
    }
}
