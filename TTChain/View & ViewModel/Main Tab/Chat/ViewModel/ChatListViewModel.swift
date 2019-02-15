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
import RxDataSources

class ChatListSectionModel: SectionModelType {
    var items: [ChatListPage]
    
    required init(original: ChatListSectionModel, items: [ChatListPage]) {
        self.items = items
    }
    init(list: [ChatListPage]) {
        self.items = list
    }
    
    typealias Item = ChatListPage
}

class ChatListViewModel: KLRxViewModel {
    required init(input: ChatListViewModel.Input, output: ChatListViewModel.Output) {
        self.input = input
        self.output = output
        self.concatInput()
    }
    
    struct Input {
        let chatSelected: Driver<IndexPath>
    }
    struct Output {
        let selectedChat:(CommunicationListModel) -> Void
    }
    
    
    var input: Input
    var output: Output
    func concatInput() {
        self.input.chatSelected.asDriver().map { [unowned self] indexPath -> CommunicationListModel?  in
            if indexPath.section == 2 {
                return self._communicationList.value[indexPath.row]
            }else {
                return nil
            }
            }.filter { $0 != nil }.drive(onNext: { (model) in
                self.output.selectedChat(model!)
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
    
    public var communicationListArray: [CommunicationListModel] {
        return _communicationList.value
    }
    private lazy var _communicationList: BehaviorRelay<[CommunicationListModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    private lazy var _friendRequestModel: BehaviorRelay<[FriendRequestInformationModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    private lazy var _groupRequestModel: BehaviorRelay<[UserGroupInfoModel]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    let dataSource: RxTableViewSectionedReloadDataSource<ChatListSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<ChatListSectionModel>.init(configureCell: { (friends, tableView, indexPath, friend) -> UITableViewCell in
            return UITableViewCell()
        })
        return source
    }()

    lazy var chatListSections: Observable<[ChatListSectionModel]> = {
        return Observable.combineLatest(_friendRequestModel.asObservable(),_groupRequestModel.asObservable(),_communicationList.asObservable()).map { (arg) -> [ChatListSectionModel] in
            
            let (friendRequestArray,groupRequestListArray,chatList) = arg

            return  [ChatListSectionModel.init(list:friendRequestArray),ChatListSectionModel.init(list: groupRequestListArray),ChatListSectionModel.init(list: chatList)]
        }
    }()
    
    func getList()  {
        self.getCommunicationList()
        self.fetchGroupList()
        self.fetchFriendsList()
    }
    
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
    
    func fetchGroupList() {
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.getUserGroupList(imUserId:userId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err):
                print(err)
            case .success(let model):
                self._groupRequestModel.accept(model.invitationList)
            }
        }).disposed(by: bag)
    }
    
    func handleGroupRequest(withAction groupAction: GroupAction, forModel model: UserGroupInfoModel) {
        Server.instance.respondToGroupRequestAPI(groupID: model.groupID, groupAction: groupAction).asObservable().subscribe(onNext : { [unowned self] (response) in
            switch response {
            case .failed(error: let err):
                print(err)
                
            case .success(_):
                self.fetchGroupList()
            }
        }).disposed(by:bag)
    }
    
    func fetchFriendsList() {
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.getUserPersonalChatList(imUserId:userId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err):
                print(err)
            case .success(let model):
                self._friendRequestModel.accept(model.personalDirectoryModel.invitationList)
            }
        }).disposed(by: bag)
    }
    
    func handleFriendRequest(withStatus accept: Bool, forModel model: FriendRequestInformationModel) {
        Server.instance.respondToFriendRequestAPI(invitationId: model.invitationID, accept: accept).asObservable().subscribe(onNext : { [unowned self] (response) in
            switch response {
            case .failed(error: let err):
                print(err)
            case .success(_):
                self.fetchFriendsList()
            }
        }).disposed(by:bag)
    }
    
    
}

