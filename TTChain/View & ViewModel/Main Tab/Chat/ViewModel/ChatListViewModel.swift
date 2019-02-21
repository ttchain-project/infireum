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
        let chatRefresh: Driver<Void>
    }
    struct Output {
        let selectedChat:(CommunicationListModel) -> Void
        let onJoinGroup:(String) -> Void
        let onShowingHUD:(Bool) -> Void
    }
    
    
    var input: Input
    var output: Output
    func concatInput() {
        self.input.chatSelected.asDriver().drive(onNext: { indexPath in
            self.output.selectedChat(self._communicationList.value[indexPath.row])
        }).disposed(by: bag)
        
        self.input.chatRefresh.drive(onNext: { (_) in
            self.getList()
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
    
    public var onReceiveRecordsUpdateResponse: Observable<Void> {
        return _onReceiveRecordsUpdateResponse.asObservable()
    }
    
    private lazy var _onReceiveRecordsUpdateResponse: PublishSubject<Void> = {
        return PublishSubject.init()
    }()
    
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
  
        let obs = self._communicationList.asObservable().map { _ in () }
        Observable.merge(obs,self._groupRequestModel.asObservable().map { _ in () }, self._friendRequestModel.asObservable().map { _ in () }).subscribe(onNext: { () in
            self._onReceiveRecordsUpdateResponse.onNext(())
        }).disposed(by: bag)

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
    
    func joinGroup(groupID:String) {
        
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        self.output.onShowingHUD(true)
        Server.instance.getGroupInfo(forGroupId: groupID).flatMap { response -> RxAPIResponse<GroupMembersAPIModel> in
            switch response {
            case .success(let model):
                if !model.groupInfo.isPrivate {
                    
                    let param = GroupMembersAPI.Parameters.init(groupID: groupID, members: [userId])
                    return Server.instance.groupMembers(parameters: param)
                }else {
                    return RxAPIResponse.just(.failed(error:GTServerAPIError.incorrectResult("", LM.dls.alert_cant_join_pvt_group)))
                }
            case .failed(error: let error):
                return RxAPIResponse.just(.failed(error: error))
            }
            }.subscribe(onSuccess: { (model) in
                switch model {
                case .failed(error:let error):
                    self.output.onShowingHUD(false)

                    self.output.onJoinGroup(error.descString)
                case .success(let model) :
                    self.output.onShowingHUD(false)
                    self.output.onJoinGroup(LM.dls.group_join_success)
                    if model.isSuccess {
                        self.getList()
                    }
                }
            }) { (error) in
                print(error)
                self.output.onShowingHUD(false)
        }.disposed(by: bag)
    }
    
}

