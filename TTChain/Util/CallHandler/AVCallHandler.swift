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
    
    func cancelCall() {
        
        guard let callDetails = self.callDetails else {
            return
        }
        
        if case .connected? = self._currentCallStatus.value {
            self.disconnectCall()
            return
        }
        
        let parameter = InAppCallApi.Parameter.init(type: callDetails.currentCallType,
                                                    roomId: callDetails.currentCallRoomId ,
                                                    isGroup: false,
                                                    isConnect: false)
        
        let initiateCall = Server.instance.initiateInAppCall(parameter: parameter)
        
        initiateCall.asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .success(let model):
                DLogDebug("Call Stream Id \(model.streamId)")
                guard let `self` = self else {
                    return
                }
                self.callDetails = nil
                self._currentCallStatus.accept(nil)
            case .failed(error: let error):
                DLogError("Call Initiate Error \(error.descString) ")
            }
        }).disposed(by: bag)
    }
    
    func acceptCall(forStreamId streamId:String) {
        
       
        self.createARDAppClient()
        guard let client = self.client else {
            return
        }
        client.connectToRoom(withId: streamId,
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
                                                    isConnect: true)
        
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
        guard self.client != nil else {
            return
        }
        self.client?.disconnect()
        self.callDetails = nil
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
    private func createARDAppClient() {
        self.client = ARDAppClient.init(delegate: self)
        self.client?.serverHostUrl = SERVER_HOST_URL
    }
}

extension AVCallHandler:ARDAppClientDelegate {
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        DLogInfo("ADRAppClient Status Update - \(state)")
        switch (state) {
        case ARDAppClientState.connected:
            self._currentCallStatus.accept(.connected)
            break
        case ARDAppClientState.connecting:
            break
        case ARDAppClientState.disconnected:
            self._currentCallStatus.accept(.disconnected)
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
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        DLogError("Error in Call - \(error!)")
    }
    
    
    
    
}
