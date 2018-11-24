//
//  GroupChatListViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/14.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum GroupAction: Int {
    case noAction = 0
    case accept
    case reject
}

struct GroupListSectionModel: SectionModelType {
    typealias Item = UserGroupInfoModel
    
    var title: String
    var items: [Item]
    
    init(original: GroupListSectionModel, items: [Item]) {
        self = original
        self.title = ""
        self.items = items
    }
    
    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}

class GroupChatListViewModel: KLRxViewModel {
    
    struct Input {
        var searchTextInOut:ControlProperty<String?>
        var searchModeStatus:BehaviorRelay<Bool>
    }
    
    required init(input: Input, output: Void) {
        self.input = input
        self.output = output
        fetchGroupList()
    }
    
    var input: Input
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    
    lazy var groupList: BehaviorRelay<[UserGroupInfoModel]> = BehaviorRelay.init(value: [])
    lazy var groupRequestList:BehaviorRelay<[UserGroupInfoModel]>  = BehaviorRelay.init(value: [])

    lazy var sections: Observable<[GroupListSectionModel]> = {
        return Observable.combineLatest(groupList.asObservable(),groupRequestList.asObservable(),self.input.searchTextInOut.asObservable()).map { (arg) -> [GroupListSectionModel] in
            
            let (groupListArray, groupRequestListArray,searchText) = arg
           
            if let searchText = searchText, searchText.count > 0 {
                let filterGroupListArray = groupListArray.filter { $0.groupName.localizedCaseInsensitiveContains(searchText) }
                let filterGroupRequestArray = groupRequestListArray.filter { $0.groupName.localizedCaseInsensitiveContains(searchText) }
                return  [GroupListSectionModel.init(title: "Group Requests", items: filterGroupRequestArray),
                         GroupListSectionModel.init(title: "Group Info", items:filterGroupListArray)]
            }else {
                return  [GroupListSectionModel.init(title: "Group Requests", items: groupRequestListArray),
                         GroupListSectionModel.init(title: "Group Info", items:groupListArray)]
            }
        }
    }()
    
    let dataSource: RxTableViewSectionedReloadDataSource<GroupListSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<GroupListSectionModel>.init(configureCell: { (friends, tableView, indexPath, friend) -> UITableViewCell in
            return UITableViewCell()
        })
        return source
    }()
    
    func fetchGroupList() {
        guard let userId = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.getUserGroupList(imUserId:userId).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: let err):
                print(err)
            case .success(let model):
                self.groupRequestList.accept(model.invitationList)
                self.groupList.accept(model.groupList)
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
}
