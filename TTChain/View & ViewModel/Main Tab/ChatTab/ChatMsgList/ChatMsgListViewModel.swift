//
//  ChatMsgListViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/20.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class ChatMsgListViewModel: KLRxViewModel {
    
    var input: ChatMsgListViewModel.Input
    
    var output: ChatMsgListViewModel.Output
    
    var bag: DisposeBag = DisposeBag()
    required init(input: ChatMsgListViewModel.Input, output: ChatMsgListViewModel.Output) {
        self.input = input
        self.output = output
        self.concatInput()
        self.listenToPushNotificationUpdate()
    }
    
    struct Input {
        let chatSelected: Driver<IndexPath>
        let chatRefresh: Driver<Void>
        let searchText: Driver<String>
    }
    struct Output {
        let selectedChat:(CommunicationListModel) -> Void
        let onShowingHUD:(Bool) -> Void
    }
    
    func concatInput() {
        self.input.chatSelected.asDriver().drive(onNext: { indexPath in
            self.output.selectedChat(self._communicationList.value[indexPath.row])
        }).disposed(by: bag)
        
        self.input.chatRefresh.drive(onNext: { (_) in
            self.getCommunicationList()
        }).disposed(by: bag)

    }
    
    func concatOutput() {}

    public lazy var communicationList: Observable<[CommunicationListModel]> = {
        return Observable.combineLatest(self._communicationList,self.input.searchText.asObservable()).map { data, text in
            if text.count == 0 {
               return self._communicationList.value
            }
            return self._communicationList.value.filter { $0.displayName.contains(text,caseSensitive: false) }
        }
    }()
    
    private lazy var _communicationList: BehaviorRelay<[CommunicationListModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
//    public var allCommunicationList: Observable<[CommunicationListModel]> {
//        return _allCommunicationList.asObservable()
//    }
//    private lazy var _allCommunicationList: BehaviorRelay<[CommunicationListModel]> = {
//        return BehaviorRelay.init(value: [])
//    }()
    

    func getCommunicationList() {
        Server.instance.getCommunicationsList().asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err) :
                DLogError(err)
            case .success(let model):
                self._communicationList.accept(model.communicationList)
                DLogInfo("GotCommunicationList")
            }
        }).disposed(by: bag)
    }
    
    private func listenToPushNotificationUpdate() {
        OWRxNotificationCenter.instance.notificationReceived.subscribe(onNext: {[weak self] (_) in
            self?.getCommunicationList()
        }).disposed(by: bag)
    }
    
    
}
