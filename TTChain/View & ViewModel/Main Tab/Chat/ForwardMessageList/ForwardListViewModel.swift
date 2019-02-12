//
//  ForwardListViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/11.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class ForwardListViewModel: KLRxViewModel {

    struct Input {
        var listType: ForwardListViewController.ListType
        var messageModel: MessageModel
        var selectionIndex: Driver<Int>
    }
    
    struct Output {
        let selectedChat:(ChatListPage) -> Void
    }
    
    required init(input: Input, output: Output) {
        self.input = input
        self.output = output
        switch self.input.listType {
        case .Chat:
            self.getCommunicationList()
        case .Friends:
            self.getFriendsList()
        case .Group:
            self.getGroupList()
        }
        self.input.selectionIndex.drive(onNext: { (row) in
            self.output.selectedChat(self._forwardList.value[row])
        }).disposed(by: bag)
    }
    
    var input: Input
    
    var output: Output
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    private lazy var _forwardList: BehaviorRelay<[ChatListPage]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    public var forwardList: Observable<[ChatListPage]> {
        return _forwardList.asObservable()
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Output
    
    var bag: DisposeBag = DisposeBag.init()
    
    func getCommunicationList() {
        Server.instance.getCommunicationsList().asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err) :
                print(err)
            case .success(let model):
                self._forwardList.accept(model.communicationList)
            }
        }).disposed(by: bag)
    }
    
    func getGroupList() {
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.getUserGroupList(imUserId:userId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err):
                print(err)
            case .success(let model):
                print("err")
                self._forwardList.accept(model.groupList)
            }
        }).disposed(by: bag)
    }
    
    func getFriendsList() {
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.getUserPersonalChatList(imUserId:userId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err):
                print(err)
            case .success(let model):
                print("err")
                self._forwardList.accept(model.personalDirectoryModel.friendList)
            }
        }).disposed(by: bag)
    }
}
