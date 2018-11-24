//
//  SearchMemberViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchMemberViewModel: ViewModel {
    struct Input {
        let searchText = BehaviorRelay<String>(value: String())
        let friendInfoModels = BehaviorRelay<[FriendInfoModel]>(value: [FriendInfoModel]())
        let tableViewItemSelected = PublishSubject<Int>()
        let collectionViewItemSelected = PublishSubject<Int>()
        let tableViewItemDeselected = PublishSubject<Int>()
        let confirmButtonSubject = PublishSubject<Void>()
    }
    
    struct Output {
        let addGroupMemberTableViewCellModels = BehaviorRelay<[AddGroupMemeberTableViewCellModel]>(value: [AddGroupMemeberTableViewCellModel]())
        let addGroupMemberCollectionViewCellModels = BehaviorRelay<[AddGroupMemberCollectinoViewCellModel]>(value: [AddGroupMemberCollectinoViewCellModel]())
        let selectedFriends = PublishSubject<[FriendInfoModel]>()
    }
    
    var input = Input()
    var output = Output()
    private let disposeBag = DisposeBag()
    
    init() {
        input.friendInfoModels.map { (viewModels) -> [AddGroupMemeberTableViewCellModel] in
            return viewModels.map(AddGroupMemeberTableViewCellModel.init)
            }.bind(to: output.addGroupMemberTableViewCellModels).disposed(by: disposeBag)
        Observable.of(input.tableViewItemSelected, input.tableViewItemDeselected).merge().subscribe(onNext: {
            [unowned self] index in
            let targetViewModel = self.output.addGroupMemberTableViewCellModels.value[index]
            let targetModel = targetViewModel.input.friendInfoModel
            var value = self.output.addGroupMemberCollectionViewCellModels.value
            if targetViewModel.output.isSelected.value {
                targetViewModel.output.isSelected.accept(false)
                value.removeFirst(where: { (model) -> Bool in
                    return model.input.friendInfoModel.uid == targetModel.uid
                })
            } else {
                targetViewModel.output.isSelected.accept(true)
                let viewModel = AddGroupMemberCollectinoViewCellModel(friendInfoModel: targetModel)
                value.append(viewModel)
            }
            self.output.addGroupMemberCollectionViewCellModels.accept(value)
        }).disposed(by: disposeBag)
        input.collectionViewItemSelected.subscribe(onNext: {
            [unowned self] index in
            var value = self.output.addGroupMemberCollectionViewCellModels.value
            self.output.addGroupMemberTableViewCellModels.value.first(where: { (viewModel) -> Bool in
                return viewModel.input.friendInfoModel.uid == value[index].input.friendInfoModel.uid
            })?.output.isSelected.accept(false)
            value.remove(at: index)
            self.output.addGroupMemberCollectionViewCellModels.accept(value)
        }).disposed(by: disposeBag)
        input.searchText.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged().subscribe(onNext: {
            [unowned self] text in
            var value = self.input.friendInfoModels.value
            if !text.isEmpty {
                value = value.filter({ (model) -> Bool in
                    return model.nickName.contains(text)
                })
            }
            let tableViewCellModels = value.map(AddGroupMemeberTableViewCellModel.init)
            tableViewCellModels.forEach({ (viewModel) in
                if self.output.addGroupMemberCollectionViewCellModels.value.contains(where: { (groupViewModel) -> Bool in
                    return groupViewModel.input.friendInfoModel.uid == viewModel.input.friendInfoModel.uid
                }) {
                    viewModel.output.isSelected.accept(true)
                }
            })
            self.output.addGroupMemberTableViewCellModels.accept(tableViewCellModels)
        }).disposed(by: disposeBag)
        guard let uid = IMUserManager.manager.userModel.value?.uID else { return }
        Server.instance.getUserPersonalChatList(imUserId: uid).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .failed(error: let error): DLogError(error)
            case .success(let value):
                self.input.friendInfoModels.accept(value.personalDirectoryModel.friendList)
            }
        }).disposed(by: disposeBag)
        input.confirmButtonSubject.subscribe(onNext: {
            [unowned self] in
            self.output.selectedFriends.onNext(self.output.addGroupMemberCollectionViewCellModels.value.map({ $0.input.friendInfoModel }))
        }).disposed(by: disposeBag)
    }
}
