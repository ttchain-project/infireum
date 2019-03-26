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
        let isPrivate = BehaviorRelay<Bool>(value: true)
        let isPostable = BehaviorRelay<Bool>(value: false)
        let introduction = BehaviorRelay<String?>(value: nil)
        let bottomButtonIsEnabled = BehaviorRelay<Bool>(value: false)
        let animatableSectionModel = BehaviorRelay<[AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>]>(value: [AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>]())
        let isEditable = BehaviorRelay<Bool>(value: false)
        let errorMessageSubject = PublishSubject<String>()
        let dismissSubject = PublishSubject<Void>()
        let popToRootSubject = PublishSubject<Void>()
        let buttonType = BehaviorRelay<ButtonType>(value: GroupInformationViewModel.ButtonType.leave)
        let groupImage:BehaviorRelay<UIImage?> = BehaviorRelay<UIImage?>(value: nil)
        let leaveGroupActionSubject = PublishSubject<(() -> ())>()
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>>.init(configureCell: { (dataSource, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(with: GroupMemberCollectionViewCell.self, for: indexPath)
            cell.viewModel = viewModel
            return cell
        }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: GroupCollectionReusableView.self, for: indexPath)
            headerView.titleLabel.text = dataSource[indexPath.section].model
            return headerView
        })
        let nameCountHintString = BehaviorSubject<String>(value: String())
        let nameCountHintColor = BehaviorSubject<UIColor>(value: UIColor.black)
        let introductionCountHintString = BehaviorSubject<String>(value: String())
        let introductionCountHintColor = BehaviorSubject<UIColor>(value: UIColor.black)
        
    }
    
    var input: Input
    var output: Output
    private let disposeBag = DisposeBag()
    private var createGroupDisposeBag = DisposeBag()
    private var groupMembersDisposeBag = DisposeBag()
    
    private let invitedMemberTitle = LM.dls.group_member_invited
    
    public let groupMembersInvitedSuccessfully :PublishSubject<Void> =  PublishSubject.init()
    
    init(userGroupInfoModel: UserGroupInfoModel? = nil) {
        input = Input.init(userGroupInfoModel: userGroupInfoModel)
        output = GroupInformationViewModel.Output.init()
        concatInput()
        self.getGroupDetails()
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
                if self.input.userGroupInfoModelSubject.value.groupOwnerUID == RocketChatManager.manager.rocketChatUser.value?.name {
                    return .edit
                } else {
                    return .leave
                }
            }
            }.bind(to: output.buttonType).disposed(by: disposeBag)
        
        input.userGroupInfoModelSubject.asDriver().drive(onNext: {
            [unowned self] userGroupInfoModel in
            self.output.title.accept(userGroupInfoModel.groupID.isEmpty ? LM.dls.create_group : LM.dls.group_member)
            self.output.groupName.accept(userGroupInfoModel.groupName)
            self.output.isPrivate.accept(userGroupInfoModel.isPrivate)
            self.output.isPostable.accept(userGroupInfoModel.isPostMsg)
            self.output.introduction.accept(userGroupInfoModel.introduction)
            
            if let image = userGroupInfoModel.groupIcon {
                self.output.groupImage.accept(image)
            }else if let url = URL.init(string: userGroupInfoModel.headImg)  {
                KLRxImageDownloader.instance.download(source: url) {
                    result in
                    switch result {
                    case .failed:
                        self.output.groupImage.accept(nil)
                    case .success(let img):
                        self.output.groupImage.accept(img)
                    }
                }
            }
            var animatableSectionModels = [AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>]()
            if let memberCellModels = userGroupInfoModel.membersArray?.map(GroupMemberCollectionViewCellModel.init) {
                animatableSectionModels = [AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>.init(model: LM.dls.group_member, items: memberCellModels)]
            }
            let inviteCellModels = userGroupInfoModel.invitedMembersArray?.map(GroupMemberCollectionViewCellModel.init) ?? [GroupMemberCollectionViewCellModel.init()]
            animatableSectionModels.append(AnimatableSectionModel<String, GroupMemberCollectionViewCellModel>.init(model: LM.dls.group_member_invited, items: inviteCellModels))
            self.output.animatableSectionModel.accept(animatableSectionModels)
        }).disposed(by: disposeBag)
        
        input.typeSubject.subscribe(onNext: {
            [unowned self] type in
            self.output.animatableSectionModel.value.forEach({ (sectionModel) in
                if sectionModel.model == self.invitedMemberTitle {
                    sectionModel.items.forEach({ (viewModel) in
                        let isHidden = type == .normal || viewModel.input.groupMemberModel?.uid == IMUserManager.manager.userModel.value?.uID || viewModel.input.groupMemberModel == nil
                        viewModel.output.closeButtonIsHidden.accept(isHidden)
                    })
                }
            })
            switch type {
            case .create: return
            case .edit:
                self.output.animatableSectionModel.value.forEach({ (sectionModel) in
                    if sectionModel.model == self.invitedMemberTitle {
                        if sectionModel.items.isEmpty || sectionModel.items.first?.input.groupMemberModel != nil {
                            var section = self.output.animatableSectionModel.value
                            if var inviteSection = section.first(where: { $0.model == self.invitedMemberTitle} ) {
                                inviteSection.items.insert(GroupMemberCollectionViewCellModel(), at: 0)
                                section.removeLast()
                                section.append(inviteSection)
                                self.output.animatableSectionModel.accept(section)
                            }
                        }
                    }
                })
            case .normal:
                self.output.animatableSectionModel.value.forEach({ (sectionModel) in
                    if sectionModel.model == self.invitedMemberTitle {
                        if sectionModel.items.first?.input.groupMemberModel == nil {
                            var section = self.output.animatableSectionModel.value
                            if var inviteSection = section.first(where: { $0.model == self.invitedMemberTitle} ) {
                                if !inviteSection.items.isEmpty {
                                    inviteSection.items.removeFirst()
                                }
                                section.removeLast()
                                section.append(inviteSection)
                                self.output.animatableSectionModel.accept(section)
                            }
                        }
                    }
                })
            }
        }).disposed(by: disposeBag)
        
        input.addMembersSubject.subscribe(onNext: {
            [unowned self] newValue in
            let allMembers = self.output.animatableSectionModel.value.flatMap({ $0.items }).compactMap({ $0.input.groupMemberModel?.uid })
            let needToAddFriends = newValue.filter({ (model) -> Bool in
                return !allMembers.contains(where: { $0.uppercased() == model.uid.uppercased() })
            }).map(GroupMemberCollectionViewCellModel.init)
            

            if var value = self.output.animatableSectionModel.value.first(where: { $0.model == self.invitedMemberTitle }) {
                value.items.append(contentsOf: needToAddFriends)
                var section = self.output.animatableSectionModel.value
                section.removeLast()
                section.append(value)
                self.output.animatableSectionModel.accept(section)
            }
        }).disposed(by: disposeBag)
        
        input.buttonTapSubject.subscribe(onNext: {
            [unowned self] in
            switch self.output.buttonType.value {
            case .create:
                guard let groupName = self.output.groupName.value else { fatalError("groupName should not be nil.") }
                let memberIDs = self.output.animatableSectionModel.value.flatMap({ $0.items }).compactMap({ $0.input.groupMemberModel?.uid })
                let parameters = CreateGroupAPI.Parameters.init(isPrivate: self.output.isPrivate.value, groupName: groupName, isPostMsg: self.output.isPostable.value, introduction: self.output.introduction.value ?? String())
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
                            self.uploadGroupPicture(forGroupID: value.groupID).asObservable().subscribe(onNext: { [weak self] (result) in
                                 guard let `self` = self else { return }
                                self.output.dismissSubject.onCompleted()
                            }).disposed(by: self.groupMembersDisposeBag)
                        }).disposed(by: self.groupMembersDisposeBag)
                    case .failed(error: let error):
                        DLogError(error)
                        self.output.errorMessageSubject.onNext(error.localizedDescription)
                    }
                    self.createGroupDisposeBag = DisposeBag()
                }).disposed(by: self.createGroupDisposeBag)
            case .leave:
                self.output.leaveGroupActionSubject.onNext {
                    [unowned self] in
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
                }
            case .edit: self.input.typeSubject.accept(GroupInformationViewModel.ViewModelType.edit)
            case .confirm:
                guard let groupName = self.output.groupName.value else { fatalError("groupName should not be nil.") }
                let groupID = self.input.userGroupInfoModelSubject.value.groupID
                let memberIDs = self.output.animatableSectionModel.value.flatMap({ $0.items }).compactMap({ $0.input.groupMemberModel?.uid })
                let parameters = UpdateGroupAPI.Parameters.init(groupID: groupID, groupName: groupName, isPostMsg: self.output.isPostable.value, introduction: self.output.introduction.value ?? String())
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
                            self.uploadGroupPicture(forGroupID: groupID).asObservable().subscribe(onNext: { [weak self] (result) in
                                guard let `self` = self else { return }
                                self.output.dismissSubject.onCompleted()
                            }).disposed(by: self.groupMembersDisposeBag)
                        }).disposed(by: self.groupMembersDisposeBag)
                    case .failed(error: let error):
                        DLogError(error)
                        self.output.errorMessageSubject.onNext(error.localizedDescription)
                    }
                    self.createGroupDisposeBag = DisposeBag()
                }).disposed(by: self.createGroupDisposeBag)
            }
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(output.groupName.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged(), output.animatableSectionModel, output.introduction.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged()) { [unowned self] (groupName, sectionModels, introduce) -> Bool in
            guard let groupName = groupName else { return false }
            switch self.input.typeSubject.value {
            case .normal: return true
            case .edit,.create: guard !(sectionModels.first(where:{ $0.model == self.invitedMemberTitle })?
                .items.compactMap({ $0.input.groupMemberModel?.uid }).isEmpty ?? true) else { return false }
            }
            switch (groupName.count, introduce?.count ?? 0) {
            case (1...20, 0...100): return true
            default: return false
            }
            }.bind(to: output.bottomButtonIsEnabled).disposed(by: disposeBag)
        
        output.animatableSectionModel.subscribe(onNext: {
            [unowned self] value in
            let type = self.input.typeSubject.value
            value.forEach({ (sectionModel) in
                sectionModel.items.forEach({ (viewModel) in
                    let isHidden = type == .normal || viewModel.input.groupMemberModel?.uid == RocketChatManager.manager.rocketChatUser.value?.name || viewModel.input.groupMemberModel == nil
                    viewModel.output.closeButtonIsHidden.accept(isHidden)
                })
            })
        }).disposed(by: disposeBag)
        
        output.groupName.map({ $0?.count ?? 0}).subscribe(onNext: {
            [unowned self] count in
            self.output.nameCountHintString.onNext(count > 20 ? LM.dls.group_text_too_long(count.stringValue,20.stringValue) : "\(count)/20")
            self.output.nameCountHintColor.onNext(count > 20 ? UIColor.owPinkRed : UIColor.lightGray)
        }).disposed(by: disposeBag)
        
        output.introduction.map({ $0?.count ?? 0}).subscribe(onNext: {
            [unowned self] count in
            self.output.introductionCountHintString.onNext(count > 100 ? LM.dls.group_text_too_long(count.stringValue,100.stringValue)  : "\(count)/100")
            self.output.introductionCountHintColor.onNext(count > 100 ? UIColor.owPinkRed : UIColor.lightGray)
        }).disposed(by: disposeBag)
    }
    
    func addMembersToGroup(friendModels : [FriendModel])  {
        let memberIDs = self.output.animatableSectionModel.value
                        .flatMap({ $0.items })
                        .compactMap({ $0.input.groupMemberModel?.uid })
        
        let groupID = self.input.userGroupInfoModelSubject.value.groupID
        let parameters = GroupMembersAPI.Parameters.init(groupID: groupID, members: memberIDs)
        Server.instance.groupMembers(parameters: parameters).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let model):
                if model.isSuccess {
                    self.groupMembersInvitedSuccessfully.onNext(())
                    self.getGroupDetails()
                }
            case .failed(error: let error):
                print(error)
            }
        }).disposed(by: disposeBag)
    }
    
    func uploadGroupPicture(forGroupID groupId:String) -> RxAPIResponse<UploadHeadImageAPIModel> {
        
        guard let image = self.output.groupImage.value else {
            return .just(.failed(error: GTServerAPIError.noData))
        }
        let parameter = UploadHeadImageAPI.Parameters.init(personalOrGroupId:groupId , isGroup: true, image: UIImageJPEGRepresentation(image, 0.5)!)
        return Server.instance.uploadHeadImg(parameters: parameter)
    }
    
    func getGroupDetails() {
        Server.instance.getGroupInfo(forGroupId:self.input.userGroupInfoModelSubject.value.groupID).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .failed(error: let error):
                print(error)
            case .success(let model):
                self.input.userGroupInfoModelSubject.accept(model.groupInfo)
            }
        }).disposed(by: disposeBag)
    }
}
