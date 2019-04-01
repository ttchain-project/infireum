//
//  AudioCallViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftMoment

class AudioCallViewModel: KLRxViewModel {
    
    struct Input {
        let roomId:String
        let roomType:RoomType
        let endCallAction:Driver<Void>
    }
    
    struct Output {
        
    }
    
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()
    
    var disconnectTimerBag: DisposeBag! = DisposeBag()
    private var disconnectTimer: Observable<Int>!
    
    var callTimer:Observable<Int>!
    var callTimerBag: DisposeBag!
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
    }
    
    var input: AudioCallViewModel.Input
    var output: AudioCallViewModel.Output
    var totalCallTime : BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    
    public var didEndCall : PublishSubject<Void> = PublishSubject.init()
    
    func concatInput() {
        self.input.endCallAction.asObservable().subscribe(onNext: {[weak self] _ in
            guard self != nil else {
                return
            }
            AVCallHandler.handler.endCall()
            self?.didEndCall.onNext(())
        }).disposed(by: bag)
        
        AVCallHandler.handler.currentCallingStatus.asObservable().subscribe(onNext: { (callStatus) in
            
            switch callStatus {
                
            case .disconnected?:
                self.didEndCall.onNext(())
            case .otherClientConnected?:
                self.disconnectTimerBag = nil
                self.beginCallTime()
            //Start Timer here
            default:
                DLogInfo("\(callStatus.debugDescription)")
            }
        }).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    func initiateCall() {
        AVCallHandler.handler.initiateAudioCall(forRoomId: self.input.roomId)
        disconnectTimer = Observable<Int>.interval(60.0, scheduler: MainScheduler.instance)
        
        disconnectTimer.map({[weak self] _ in
            guard self != nil else {
                return
            }
            AVCallHandler.handler.endCall()
            self?.didEndCall.onNext(())
            DLogInfo("EndCall here")
        }).subscribe(onNext: {[weak self] (_) in
            DLogInfo("EndCall here")
            self?.disconnectTimerBag = nil
        }).disposed(by: disconnectTimerBag)
    }

    func joinCall(forStreamId streamId:String)  {
        AVCallHandler.handler.acceptCall()
    }
    
    func beginCallTime() {
        
        self.callTimer = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
        self.callTimerBag = DisposeBag.init()
        self.callTimer.map({ time in
            let duration = Duration.init(value: time)
            return String(format:"%02i:%02i:%02i",duration.hours.int,duration.minutes.int,duration.seconds.int)
        }).subscribe(onNext:{ timeInString in
            self.totalCallTime.accept(timeInString)
        }).disposed(by:self.callTimerBag)
    }
    
}
