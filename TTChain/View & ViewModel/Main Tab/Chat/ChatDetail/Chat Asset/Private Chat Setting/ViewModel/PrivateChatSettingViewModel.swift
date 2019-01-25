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

enum PrivateChatDuration:String {
    case singleConversation = "Single"
    case pvt_10_minutes = "Ten"
    case pvt_5_minutes = "Five"
    case pvt_20_minutes = "Twenty"
    
    var title : String {
        switch self {
        case .singleConversation:
            return "Single Conversation"
        case .pvt_10_minutes:
            return "For 10 minutes"
        case .pvt_5_minutes:
            return "For 5 minutes"
        case .pvt_20_minutes:
            return "For 20 minutes"
        }
    }
    var apiValue:String {
        switch self {
        case .singleConversation:
            return "Single"
        case .pvt_10_minutes:
            return "Ten"
        case .pvt_5_minutes:
            return "Five"
        case .pvt_20_minutes:
            return "Twenty"
        }
    }
}

class PrivateChatSettingViewModel: KLRxViewModel  {
    
    struct Input {
        var selectedDuration: PrivateChatDuration?
        var selectedStatus: Bool?
        var privateChatSwitch:ControlProperty<Bool>
        var pickerSelectedIndex: Driver<Int>
        var roomId:String
        var roomType:RoomType
        var uId:String
    }
    
    
    
    private lazy var _isPrivateChatEnabled: BehaviorRelay<Bool> = BehaviorRelay.init(value: self.input.selectedStatus ?? false)
    private lazy var _privateChatDuration: BehaviorRelay<PrivateChatDuration> = BehaviorRelay.init(value: self.input.selectedDuration ?? .pvt_10_minutes)
    
    public var privateChatDurationObserver: Observable<PrivateChatDuration> {
        return _privateChatDuration.asObservable()
    }
    
    public func isChatPrivate() -> Bool {
        return _isPrivateChatEnabled.value
    }
    public func getPrivateChatDuration() -> PrivateChatDuration? {
        return _privateChatDuration.value
    }
    
    public let durationOptions : [PrivateChatDuration] = [.singleConversation, .pvt_5_minutes, .pvt_10_minutes, .pvt_20_minutes]

    private var shouldUpdateSetting:Bool = false
    
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
    
    func setDestructMessageSetting() -> RxAPIResponse<SelfDestructMessageSettingAPIModel> {
        let value:String
        
        if _isPrivateChatEnabled.value {
            value = _privateChatDuration.value.apiValue
        }else {
            value = "Inactive"
        }
        
        let paramet = SelfDestructMessageSettingAPI.Parameter.init(roomId: self.input.roomId, roomType: self.input.roomType.rawValue, uid: self.input.uId, selfDestructingMessageType: value)
        
        return Server.instance.destructMessage(parameter:paramet)
    }
}
