//
//  IncomingCallViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/13.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import AudioToolbox

class IncomingCallViewModel:KLRxViewModel {
  
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let callModel:CallMessageModel
        let strin : UILabel
    }
    
    lazy var timer : Observable<NSInteger> = { return Observable<NSInteger>.interval(0.7, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()
    var timerBag:Disposable!
    var input: IncomingCallViewModel.Input
    var output: Void
    var vibrationBag:DisposeBag! = DisposeBag()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        self.timerBag = Observable<NSInteger>.interval(0.7, scheduler: SerialDispatchQueueScheduler(qos: .background)).observeOn(MainScheduler.instance).subscribe(onNext: {  intVal in
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        })
        
        AVCallHandler.handler.startIncomingCall(callMessageModel: input.callModel)
       
        
    }
}
