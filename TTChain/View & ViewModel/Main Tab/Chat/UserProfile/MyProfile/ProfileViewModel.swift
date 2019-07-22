//
//  ProfileViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/17.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel : KLRxViewModel {
    var bag: DisposeBag = DisposeBag()
    
    typealias InputSource = Input
    typealias OutputSource = Output
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
    }
    var input: ProfileViewModel.Input
    var output: ProfileViewModel.Output
    func concatInput() {
        (self.input.userName <-> self.userName).disposed(by:bag)
    }
    func concatOutput() {
    }
    struct Input {
        let userName:ControlProperty<String?>
    }
    
    struct Output {
        let messageSubject = PublishSubject<String>()
        let animateHud = PublishSubject<Bool>()
        let onUpdateComplete = PublishSubject<Void>()
    }
    var userName:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    
    var imUser: IMUser? = {
        guard let imUser = IMUserManager.manager.userModel.value else {
            return nil
        }
        return imUser
    }()
    
    func updateUserName() {
        guard let userName = self.userName.value else {
            self.output.messageSubject.onNext(LM.dls.profile_edit_empty_name_error)
            return
        }
        
        let parameter = UpdateUserAPI.Parameters.init(uid: (imUser?.uID)! , nickName: userName, introduction: imUser?.introduction ?? "")

        self.output.animateHud.onNext(true)
        Server.instance.updateUserData(parameters: parameter).asObservable().subscribe(onNext: { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            self.output.animateHud.onNext(false)
            switch result {
            case .success(_):
                self.imUser?.nickName = userName
                LocalIMUser.updateLocalIMUser()
                self.output.onUpdateComplete.onNext(())
            case .failed(error: let error):
                print("error %@", error)
            }
        }).disposed(by: bag)
    }
    
    func updateProfilePic(image:UIImage) {
       
        let parameter = UploadHeadImageAPI.Parameters.init(personalOrGroupId:imUser!.uID , isGroup: false, image:UIImageJPEGRepresentation(image, 0.5)!)
        self.output.animateHud.onNext(true)
        Server.instance.uploadHeadImg(parameters: parameter).asObservable().subscribe(onNext: {[weak self] (result) in
            guard let `self` = self else {
                return
            }
            self.output.animateHud.onNext(false)
            switch result {
            case .success(let model):
                self.imUser?.headImg = image
                self.imUser?.headImgUrl = model.image
                IMUserManager.manager.userModel.accept(self.imUser)
                LocalIMUser.updateLocalIMUser()
                if self.imUser!.nickName != self.userName.value {
                    //UpdateName
                    self.updateUserName()
                } else {
                    self.output.onUpdateComplete.onNext(())
                }
            case .failed(error: let error):
                self.output.messageSubject.onNext(error.descString)
            }
        }).disposed(by: bag)
        
    }
    func setRecoveryPassword(password:String) {
        self.output.animateHud.onNext(true)
        guard let id = IMUserManager.manager.userModel.value?.uID else { return }
        Server.instance.setRecoveryPassword(withIMUserId: id, recoveryPassword: password).asObservable().subscribe(onNext: {
            [weak self] result in
            guard let `self` = self else { return }
            self.output.animateHud.onNext(false)
            switch result {
            case .success:
                DLogDebug("set recovery key successful.")
                self.output.messageSubject.onNext(LM.dls.chat_recovery_password_successful)
            case .failed(error: let error):
                DLogError(error)
                self.output.messageSubject.onNext(error.descString)
            }
        }).disposed(by:self.bag)
        
    }
}
