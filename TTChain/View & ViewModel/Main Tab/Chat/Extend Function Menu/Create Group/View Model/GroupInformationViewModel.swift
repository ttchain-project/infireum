//
//  GroupInformationViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

final class GroupInformationViewModel: ViewModel {
    enum ViewModelType {
        case normal, create, edit
    }
    
    enum ButtonType {
        case edit, leave, confirm, create
    }
    
    struct Input {
        let typeSubject = BehaviorRelay<ViewModelType>(value: .normal)
        let userGroupInfoModelSubject = BehaviorRelay<UserGroupInfoModel>(value: UserGroupInfoModel())
        let buttonTapSubject = PublishSubject<Void>()
        let addMembersSubject = PublishSubject<[FriendInfoModel]>()
        
        init(userGroupInfoModel: UserGroupInfoModel? = nil) {
            userGroupInfoModelSubject.accept(userGroupInfoModel ?? UserGroupInfoModel())
        }
    }
    
    struct Output {
        let title = BehaviorRelay<String>(value: String())
        let groupName = BehaviorRelay<String?>(value: nil)
        let isPrivate = BehaviorRelay<Bool>(value: false)
        let isPostable = BehaviorRelay<Bool>(value: false)
        let introduction = BehaviorRelay<String?>(value: nil)
        let bottomButtonIsEnabled = BehaviorRelay<Bool>(value: false)
        let groupMemberCollectionViewCellModels = BehaviorRelay<[GroupMemberCollectionViewCellModel]>(value: [GroupMemberCollectionViewCellModel]())
        let isEditable = BehaviorRelay<Bool>(value: false)
        let errorMessageSubject = PublishSubject<String>()
        let dismissSubject = PublishSubject<Void>()
        let popToRootSubject = PublishSubject<Void>()
        let buttonType = BehaviorRelay<ButtonType>(value: GroupInformationViewModel.ButtonType.leave)
        let groupImageString = BehaviorRelay<String>(value: String())
    }
    
    var input: Input
    var output: Output
    private let disposeBag = DisposeBag()
    private var createGroupDisposeBag = DisposeBag()
    private var groupMembersDisposeBag = DisposeBag()
    
    init(userGroupInfoModel: UserGroupInfoModel? = nil) {
        input = Input.init(userGroupInfoModel: userGroupInfoModel)
        output = GroupInformationViewModel.Output.init()
        concatInput()
    }
    
    func concatInput() {
        input.userGroupInfoModelSubject.map { (userGroupInfoModel) -> ViewModelType in
            return userGroupInfoModel.groupID.isEmpty ? .create : .normal
            }.bind(to: input.typeSubject).disposed(by: disposeBag)
        input.typeSubject.map({ $0 != .normal }).bind(to: output.isEditable).disposed(by: disposeBag)
        input.typeSubject.map { (type) -> ButtonType in
            switch type {
            case .create: return .create
            case .edit: return .confirm
            case .normal:
                if self.input.userGroupInfoModelSubject.value.groupOwnerUID == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId {
                    return .leave
                } else {
                    return .edit
                }
            }
        }.bind(to: output.buttonType).disposed(by: disposeBag)
        input.userGroupInfoModelSubject.asDriver().drive(onNext: {
            [unowned self] userGroupInfoModel in
            self.output.title.accept(userGroupInfoModel.groupID.isEmpty ? "创建群组" : "群组成员")
            self.output.groupName.accept(userGroupInfoModel.groupName)
            self.output.isPrivate.accept(userGroupInfoModel.isPrivate)
            self.output.isPostable.accept(userGroupInfoModel.isPostMsg)
            self.output.introduction.accept(userGroupInfoModel.introduction)
            if let members = userGroupInfoModel.membersArray {
                self.output.groupMemberCollectionViewCellModels.accept(members.map(GroupMemberCollectionViewCellModel.init))
            } else {
                guard let user = IMUserManager.manager.userModel.value else { return }
                self.output.groupMemberCollectionViewCellModels.accept([GroupMemberCollectionViewCellModel.init(), GroupMemberCollectionViewCellModel.init(text: user.nickName ?? "", avatarImge: user.headImg)])
            }
        }).disposed(by: disposeBag)
        input.typeSubject.subscribe(onNext: {
            [unowned self] type in
            self.output.groupMemberCollectionViewCellModels.value.forEach({ (viewModel) in
                let isHidden = type == .normal || viewModel.input.groupMemberModel?.uid == IMUserManager.manager.userModel.value?.uID || viewModel.input.groupMemberModel == nil
                viewModel.output.closeButtonIsHidden.accept(isHidden)
            })
        }).disposed(by: disposeBag)
        input.addMembersSubject.subscribe(onNext: {
            [unowned self] newValue in
            let value = self.output.groupMemberCollectionViewCellModels.value
            let models = value.compactMap({ $0.input.groupMemberModel })
            let needToAddFriends = newValue.filter({ (model) -> Bool in
                return !models.contains(where: { $0.uid == model.uid })
            }).map(GroupMemberCollectionViewCellModel.init)
            let result = value + needToAddFriends
            self.output.groupMemberCollectionViewCellModels.accept(result)
        }).disposed(by: disposeBag)
        input.buttonTapSubject.subscribe(onNext: {
            [unowned self] in
            switch self.output.buttonType.value {
            case .create:
                guard let groupName = self.output.groupName.value else { fatalError("groupName should not be nil.") }
                let memberIDs = self.output.groupMemberCollectionViewCellModels.value.compactMap({ $0.input.groupMemberModel?.uid })
                let parameters = CreateGroupAPI.Parameters.init(isPrivate: self.output.isPrivate.value, groupName: groupName, isPostMsg: self.output.isPostable.value, headImg: self.output.groupImageString.value, introduction: self.output.introduction.value ?? String())
                Server.instance.createGroup(parameters: parameters).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let value):
                        DLogInfo("Create group successful - \(value.groupID)")
                        let parameters = GroupMembersAPI.Parameters.init(groupID: value.groupID, members: memberIDs)
                        Server.instance.groupMembers(parameters: parameters).asObservable().subscribe(onNext: {
                            [weak self] result in
                            guard let `self` = self else { return }
                            self.output.dismissSubject.onCompleted()
                        }).disposed(by: self.groupMembersDisposeBag)
                    case .failed(error: let error):
                        DLogError(error)
                        self.output.errorMessageSubject.onNext(error.localizedDescription)
                    }
                    self.createGroupDisposeBag = DisposeBag()
                }).disposed(by: self.createGroupDisposeBag)
            case .leave:
                let groupID = self.input.userGroupInfoModelSubject.value.groupID
                Server.instance.respondToGroupRequestAPI(groupID: groupID, groupAction: GroupAction.reject).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success: self.output.popToRootSubject.onCompleted()
                    case .failed(error: let error):
                        DLogError(error)
                        self.output.errorMessageSubject.onNext(error.localizedDescription)
                    }
                }).disposed(by: self.disposeBag)
            case .edit: self.input.typeSubject.accept(GroupInformationViewModel.ViewModelType.edit)
            case .confirm:
                guard let groupName = self.output.groupName.value else { fatalError("groupName should not be nil.") }
                let groupID = self.input.userGroupInfoModelSubject.value.groupID
                let memberIDs = self.output.groupMemberCollectionViewCellModels.value.compactMap({ $0.input.groupMemberModel?.uid })
                let parameters = UpdateGroupAPI.Parameters.init(groupID: groupID, groupName: groupName, isPostMsg: self.output.isPostable.value, headImg: self.output.groupImageString.value, introduction: self.output.introduction.value ?? String())
                Server.instance.updateGroup(parameters: parameters).asObservable().subscribe(onNext: {
                    [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success:
                        DLogInfo("Update group successful")
                        let parameters = GroupMembersAPI.Parameters.init(groupID: groupID, members: memberIDs)
                        Server.instance.groupMembers(parameters: parameters).asObservable().subscribe(onNext: {
                            [weak self] result in
                            guard let `self` = self else { return }
                            self.output.dismissSubject.onCompleted()
                        }).disposed(by: self.groupMembersDisposeBag)
                    case .failed(error: let error):
                        DLogError(error)
                        self.output.errorMessageSubject.onNext(error.localizedDescription)
                    }
                    self.createGroupDisposeBag = DisposeBag()
                }).disposed(by: self.createGroupDisposeBag)
            }
        }).disposed(by: disposeBag)
        Observable.combineLatest(output.groupName.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged(), self.output.groupMemberCollectionViewCellModels) { [unowned self] (groupName, cellModels) -> Bool in
            guard let groupName = groupName, !(cellModels.compactMap({ $0.input.groupMemberModel?.uid }).isEmpty && self.input.userGroupInfoModelSubject.value.invitedMembersArray.isNilOrEmpty) else { return false }
            return !(groupName.isEmpty && (self.output.buttonType.value == .confirm || self.output.buttonType.value == .create))
        }.bind(to: output.bottomButtonIsEnabled).disposed(by: disposeBag)
        output.groupMemberCollectionViewCellModels.subscribe(onNext: {
            [unowned self] value in
            let type = self.input.typeSubject.value
            value.forEach({ (viewModel) in
                let isHidden = type == .normal || viewModel.input.groupMemberModel?.uid == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId || viewModel.input.groupMemberModel == nil
                viewModel.output.closeButtonIsHidden.accept(isHidden)
            })
        }).disposed(by: disposeBag)
    }
}
