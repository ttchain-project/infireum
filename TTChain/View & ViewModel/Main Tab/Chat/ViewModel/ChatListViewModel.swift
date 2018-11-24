//
//  ChatListViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/6.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChatListViewModel: KLRxViewModel {
    required init(input: ChatListViewModel.Input, output: ChatListViewModel.Output) {
        self.input = input
        self.output = output
        self.concatInput()
    }
    
    
    struct Input {
        let chatSelected: Driver<Int>
    }
    struct Output {
        let selectedChat:(CommunicationListModel) -> Void
    }
   
    
    var input: Input
    
    var output: Output
    
    func concatInput() {
        self.input.chatSelected.asDriver().map { [unowned self] row -> CommunicationListModel  in
            
            return self._communicationList.value[row]
            }.drive(onNext: { (model) in
                self.output.selectedChat(model)
            }).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    
    typealias InputSource = Input
    typealias OutputSource = Output
    
    var bag: DisposeBag = DisposeBag.init()
    
    public var communicationList: Observable<[CommunicationListModel]> {
        return _communicationList.asObservable()
    }
    
    private lazy var _communicationList: BehaviorRelay<[CommunicationListModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    func getCommunicationList() {
        Server.instance.getCommunicationsList().asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err) :
                print(err)
            case .success(let model):
                self._communicationList.accept(model.communicationList)
            }
        }).disposed(by: bag)
    }
    
    
}

