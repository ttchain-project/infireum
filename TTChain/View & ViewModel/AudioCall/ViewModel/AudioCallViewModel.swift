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
    var timerBag: DisposeBag! = DisposeBag()
    var sig: Observable<Int>!
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
    }
    
    var input: AudioCallViewModel.Input
    var output: AudioCallViewModel.Output
    
    public var didEndCall : PublishSubject<Void> = PublishSubject.init()
    
    func concatInput() {
        self.input.endCallAction.asObservable().subscribe(onNext: {[weak self] _ in
            guard self != nil else {
                return
            }
            AVCallHandler.handler.endCall()
            self?.didEndCall.onNext(())
        }).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    func initiateCall() {
        AVCallHandler.handler.initiateAudioCall(forRoomId: self.input.roomId)
        sig = Observable<Int>.interval(60.0, scheduler: MainScheduler.instance)
        
        sig.map({[weak self] _ in
            guard self != nil else {
                return
            }
            AVCallHandler.handler.endCall()
            self?.didEndCall.onNext(())
            DLogInfo("EndCall here")
        }).subscribe(onNext: {[weak self] (_) in
            DLogInfo("EndCall here")
            self?.timerBag = nil
        }).disposed(by: timerBag)
    }
    func joinCall(forStreamId streamId:String)  {
        AVCallHandler.handler.acceptCall()
    }
}
