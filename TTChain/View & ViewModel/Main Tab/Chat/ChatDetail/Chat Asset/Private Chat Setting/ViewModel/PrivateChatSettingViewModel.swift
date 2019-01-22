//
//  PrivateChatSettingViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/8.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PrivateChatSettingViewModel: KLRxViewModel  {
    
    struct Input {
        var selectedDuration: PrivateChatSettingViewModel.PrivateChatDuration?
        var selectedStatus: Bool?
        var privateChatSwitch:ControlProperty<Bool>
        var pickerSelectedIndex: Driver<Int>
    }
    
    enum PrivateChatDuration {
        case singleConversation
        case pvt_10_minutes
        case pvt_1_minutes
        
        var title : String {
            switch self {
            case .singleConversation:
                return "Single Conversation"
            case .pvt_10_minutes:
                return "For 10 minutes"
            case .pvt_1_minutes:
                return "For 1 minute"
            }
        }
    }
    
    private lazy var _isPrivateChatEnabled: BehaviorRelay<Bool> = BehaviorRelay.init(value: self.input.selectedStatus ?? false)
    private lazy var _privateChatDuration: BehaviorRelay<PrivateChatSettingViewModel.PrivateChatDuration> = BehaviorRelay.init(value: self.input.selectedDuration ?? .pvt_10_minutes)
    
    public var privateChatDurationObserver: Observable<PrivateChatSettingViewModel.PrivateChatDuration> {
        return _privateChatDuration.asObservable()
    }
    
    public func isChatPrivate() -> Bool {
        return _isPrivateChatEnabled.value
    }
    public func getPrivateChatDuration() -> PrivateChatDuration? {
        return _privateChatDuration.value
    }
    
    public let durationOptions : [PrivateChatSettingViewModel.PrivateChatDuration] = [.singleConversation, .pvt_1_minutes, .pvt_10_minutes]

    
    required init(input: InputSource, output: Void) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
        self.bindUI()
    }
    
    var input: Input
    var output: Void
    
    func concatInput() {
        input.pickerSelectedIndex
            .drive(onNext: {
                [unowned self] row in
                self._privateChatDuration.accept(self.durationOptions[row])
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    private func bindUI () {
        self.input.privateChatSwitch.skip(1).bind(to: self._isPrivateChatEnabled).disposed(by: bag)
    }
}
