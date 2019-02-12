//
//  ChatPersonListViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum FriendsSectionModel {
    case FriendRequestSection(title: String, items: [FriendRequestInformationModel])
    case FriendInfoSection(title: String, items: [FriendInfoModel])

}

extension FriendsSectionModel: SectionModelType {
  
    typealias Item = FriendModel

    var items: [FriendModel] {
        switch self {
        case .FriendInfoSection(title: _, items:let items):
            return items.map {$0}
        case .FriendRequestSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: FriendsSectionModel, items: [Item]) {
        switch original {
            case let .FriendInfoSection(title: title, items: _):
                self = .FriendInfoSection(title: title, items: items as! [FriendInfoModel])
            case let .FriendRequestSection(title: title, items: _):
                self = .FriendRequestSection(title: title, items: items as! [FriendRequestInformationModel])
        }
    }
}

extension FriendsSectionModel {
    var title: String {
        switch self {
        case .FriendInfoSection(title:let title, items:_):
            return title
        case .FriendRequestSection(title: let title, items: _):
            return title
        }
    }
}


class ChatPersonListViewModel: KLRxViewModel {
   
    struct Input {
        var searchTextInOut:ControlProperty<String?>
        var searchModeStatus:BehaviorRelay<Bool>
    }
    var input: InputSource
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    typealias InputSource = Input
    
    typealias OutputSource = Void
    
    lazy var friendsList: BehaviorRelay<[FriendInfoModel]> = BehaviorRelay.init(value: [])
    lazy var friendRequestList:BehaviorRelay<[FriendRequestInformationModel]>  = BehaviorRelay.init(value: [])
    
    var bag: DisposeBag = DisposeBag.init()

    lazy var sections: Observable<[FriendsSectionModel]> = {

            return Observable.combineLatest(friendsList.asObservable(),friendRequestList.asObservable(),self.input.searchTextInOut.asObservable()).map { (arg) -> [FriendsSectionModel] in
                let (friendListArray, friendRequestListArray,searchText) = arg
                if let searchText = searchText, searchText.count > 0 {
                    let filterFriendsListArray = friendListArray.filter { $0.nickName.localizedCaseInsensitiveContains(searchText) }
                    let filterFriendRequestArray = friendRequestListArray.filter { $0.nickName.localizedCaseInsensitiveContains(searchText) }
                    
                    return  [FriendsSectionModel.FriendRequestSection(title:LM.dls.friend_request_title, items:filterFriendRequestArray),
                             FriendsSectionModel.FriendInfoSection(title:LM.dls.friend, items:filterFriendsListArray)]
                }else {
                    return  [FriendsSectionModel.FriendRequestSection(title:LM.dls.friend_request_title, items:friendRequestListArray),
                             FriendsSectionModel.FriendInfoSection(title:LM.dls.friend, items:friendListArray)]
                }
                
        }
    }()

    let dataSource: RxTableViewSectionedReloadDataSource<FriendsSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<FriendsSectionModel>.init(configureCell: { (friends, tableView, indexPath, friend) -> UITableViewCell in
            return UITableViewCell()
        })
        return source
    }()
    
    required init(input: InputSource, output: Void) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
        self.fetchFriendsList()

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
                self.friendRequestList.accept(model.personalDirectoryModel.invitationList)
                self.friendsList.accept(model.personalDirectoryModel.friendList)
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
