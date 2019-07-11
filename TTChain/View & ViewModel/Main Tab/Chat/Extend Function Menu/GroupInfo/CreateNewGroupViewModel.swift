//
//  CreateNewGroupViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/4.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CreateNewGroupViewModel : KLRxViewModel {

    var input: CreateNewGroupViewModel.Input
    
    var output: CreateNewGroupViewModel.Output
    
    typealias InputSource = Input
    
    typealias OutputSource = Output
    
    struct Input {
        let groupModel:UserGroupInfoModel?
    }
    
    struct Output {
        let bottomButtonIsEnabled = BehaviorRelay<Bool>(value: false)
        let groupImage = BehaviorRelay<UIImage?>(value: nil)
        let errorMessageSubject = PublishSubject<String>.init()
        let groupCreationComplete = PublishSubject<String>.init()
        let animateHUDSubject = PublishSubject<Bool>.init()
        let exitGroupCompleted = PublishSubject<Void>.init()
    }
    
    func concatInput() {
    }
    func concatOutput() {
    }
    
    lazy var groupModel:BehaviorRelay<UserGroupInfoModel?> = {
        return BehaviorRelay.init(value: input.groupModel)
    }()
    
    var groupName:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    var groupInfo:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)

    var shouldUploadGroupImage:Bool = false
    var bag: DisposeBag = DisposeBag()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        Observable.combineLatest(self.groupName.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged(),self.groupInfo.throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged()) { (name, info )-> Bool in
            guard name != nil, name?.count ?? 0 > 0 else { return false }
            return true
            }.bind(to:self.output.bottomButtonIsEnabled).disposed(by:bag)
        self.prepareForEditGroup()
        self.output.groupImage.asObservable().subscribe { _ in
            self.shouldUploadGroupImage = true
        }.disposed(by: bag)
    }
    
    func prepareForEditGroup() {
        self.groupModel.asObservable().subscribe(onNext: { (model) in
            self.groupName.accept(model?.groupName)
            self.groupInfo.accept(model?.introduction)
            if let image = model?.groupIcon {
                self.output.groupImage.accept(image)
            }else if let headImgStr = model?.headImg,let url = URL.init(string: headImgStr)  {
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
        }).disposed(by: bag)
        
        guard let groupID = self.input.groupModel?.groupID else {
            return
        }
        self.fetchGroupInfoFromServer(for: groupID).subscribe().disposed(by: bag)
    }
    
    func createGroup()  {
        guard let groupName = self.groupName.value else { fatalError("groupName should not be nil.") }
        let parameters = CreateGroupAPI.Parameters.init(isPrivate: false, groupName: groupName, isPostMsg: false, introduction: self.groupInfo.value ?? "" )
        self.output.animateHUDSubject.onNext(true)
        Server.instance.createGroup(parameters: parameters).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let value):
                DLogInfo("Create group successful - \(value.groupID)")
                self.uploadGroupPicture(forGroupID: value.groupID).asObservable().subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.output.animateHUDSubject.onNext(false)
                    self.output.groupCreationComplete.onNext(value.groupID)
                    
                }).disposed(by: self.bag)
            case .failed(error: let error):
                DLogError(error)
                self.output.errorMessageSubject.onNext(error.descString)
                self.output.animateHUDSubject.onNext(false)
            }
        }).disposed(by: bag)
    }
    
    func uploadGroupPicture(forGroupID groupId:String) -> RxAPIResponse<UploadHeadImageAPIModel> {
        
        guard let image = self.output.groupImage.value, self.shouldUploadGroupImage == true else {
            return .just(.failed(error: GTServerAPIError.noData))
        }
        let parameter = UploadHeadImageAPI.Parameters.init(personalOrGroupId:groupId , isGroup: true, image: UIImageJPEGRepresentation(image, 0.5)!)
        return Server.instance.uploadHeadImg(parameters: parameter)
    }
    
    func fetchGroupInfoFromServer(for groupID:String) -> Single<Void> {
        
        return Server.instance.getGroupInfo(forGroupId: groupID).map { result in
            switch result {
            case .success(let model):
                self.groupModel.accept(model.groupInfo)
            case .failed(error: let error):
                DLogError(error.descString)
            }
        }
    }

    func updateGroupInfo() -> Single<Void>{
        
        if let model = self.groupModel.value, (self.groupName.value != model.groupName || self.groupInfo.value != model.introduction || self.shouldUploadGroupImage) {
            guard let groupName = self.groupName.value else { fatalError("groupName should not be nil.") }
            let parameters = UpdateGroupAPI.Parameters.init(groupID: model.groupID, groupName: groupName, isPostMsg: model.isPostMsg, introduction: self.groupInfo.value ?? "")
            
            self.output.animateHUDSubject.onNext(true)
            
            return Server.instance.updateGroup(parameters: parameters).flatMap {
                [unowned self] result -> RxAPIResponse<UploadHeadImageAPIModel> in
        
                switch result {
                case .success(_):
                    return self.uploadGroupPicture(forGroupID: model.groupID)
                case .failed(error: let error):
                    DLogError(error)
                    self.output.errorMessageSubject.onNext(error.descString)
                    self.output.animateHUDSubject.onNext(false)
                    return Single.just(APIResult.failed(error: .incorrectResult("", "")))
                }
                }.flatMap({ (model) -> Single<Void> in
                    self.output.animateHUDSubject.onNext(false)
                    return Single.just(())
                })
        }
        return Single.just(())
    }
    
    func leaveGroup() {
        guard let groupID = self.groupModel.value?.groupID else {
            return
        }
        self.output.animateHUDSubject.onNext(true)
        Server.instance.respondToGroupRequestAPI(groupID: groupID, groupAction: GroupAction.reject).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.output.animateHUDSubject.onNext(false)
                self.output.exitGroupCompleted.onNext(())
            case .failed(error: let error):
                DLogError(error)
                self.output.animateHUDSubject.onNext(false)
                self.output.errorMessageSubject.onNext(error.descString)
            }
        }).disposed(by: self.bag)
    }
    
    func deleteGroup() {
        guard let groupModel = self.groupModel.value, groupModel.groupOwnerUID == IMUserManager.manager.userModel.value?.uID else {
            return
        }
        Server.instance.deleteGroup(parameters: DeleteGroupAPI.Parameters.init(userGroupInfoModel: groupModel)).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.output.animateHUDSubject.onNext(false)
                self.output.exitGroupCompleted.onNext(())
            case .failed(error: let error):
                self.output.errorMessageSubject.onNext(error.descString)
            }
        }).disposed(by: self.bag)
    }
}
