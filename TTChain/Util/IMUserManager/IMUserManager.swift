//
//  IMUserManager.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum UserLoginStatus: Int {
    case noSuchUser = 0
    case userExists
    case deviceIDNotMatched
}

class IMUserManager {
    
    let bag = DisposeBag.init()
    private var getUserDataBag = DisposeBag()
    static var manager: IMUserManager!
    static func launch() {
        manager = IMUserManager.init()
        RocketChatManager.launch()
        manager.checkIMUserStatus()
    }
    
    var userModel: BehaviorRelay<IMUser?> = BehaviorRelay.init(value: nil)
    var isLoggedIn: BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var userLoginStatus: BehaviorRelay<UserLoginStatus> = BehaviorRelay.init(value: .noSuchUser)
    
    init() {
    }
    
    var shouldLoginToRocketChat: PublishSubject<Void> = PublishSubject.init()
    var didGetCha: PublishSubject<Void> = PublishSubject.init()
    
    func checkIMUserStatus() {
        self.checkForLocalMember().asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .success(let value):
                if value {
                    self?.userLoginStatus.accept(.userExists)
                    //Call RocketChat Login
                    self?.shouldLoginToRocketChat.onNext(())
                }else {
                    DLogDebug("authenticate user")
                    self?.authenticateUser()
                }
            case .failed(let error):
                DLogError(error.localizedDescription)
            }
        }).disposed(by: bag)
    }
    
    private func checkForLocalMember() -> Observable<APIResult<Bool>> {
        if let imUserLocal = try? LocalIMUser.getFromLocal(), let user = imUserLocal {
            self.userModel.accept(user)
            self.getUserData(uID: user.uID)
            return Observable.just(APIResult.success(true))
        }
        else {
            return Observable.just(APIResult.success(false))
        }
    }
    
    private func authenticateUser() {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        guard let user = Identity.singleton, let userID = user.id else { return }
        Server.instance.preLoginIM(withUserId: userID, andDeviceID: deviceId).asObservable().subscribe(onNext: { [weak self]
            result in
            guard let `self` = self else { return }
            switch result {
            case .success(let model):
                DLogInfo(model)
                self.userLoginStatus.accept(model.status)
                switch model.status {
                case .deviceIDNotMatched:
                    DLogDebug("Call Recovery API")
                case .noSuchUser:
                    DLogDebug("Call create user api")
                    self.createUserForIM()
                case .userExists:
                    DLogDebug("Call get user data api")
                    self.getUserData(uID: model.uID)
                }
            case .failed(error: let err):
                DLogError(err)
            }
        }).disposed(by: bag)
    }
    
    private func getUserData(uID: String) {
        Server.instance.getUserData(uID: uID).asObservable().subscribe(onNext: {
            [weak self] userDataResult in
            guard let `self` = self else { return }
            switch userDataResult {
            case .success(let userData):
                DLogInfo(userData)
                let userModel = IMUser.init(uID: uID, nickName: userData.nickName, introduction: userData.introduction, headImg: userData.headImg.imageFromBase64EncodedString)
                self.userModel = BehaviorRelay.init(value: userModel)
                self.shouldLoginToRocketChat.onNext(())
                self.saveIMUser()
            case .failed(error: let error):
                DLogError(error.localizedDescription)
            }
        }).disposed(by: getUserDataBag)
    }
    
    func createUserForIM() {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        guard let user = Identity.singleton, let userID = user.id else {
            return
        }
        Server.instance.createIMUser(userId: userID, deviceID: deviceId, nickName: user.name ?? "", headImg: "", introduction: "").asObservable().subscribe(onNext: {[weak self] (result) in
            switch result {
            case .success(let model):
                let userModel = IMUser.init(uID: model.uID, nickName: "", introduction: "", headImg: nil)
                self?.userModel = BehaviorRelay.init(value: userModel)
                self?.shouldLoginToRocketChat.onNext(())
                self?.saveIMUser()
            case .failed(let error):
                DLogError(error)
            }
        }).disposed(by: bag)
    }
    
    func recoverUser(withPassword password:String, handle: @escaping ((Bool) -> Void)) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        guard let user = Identity.singleton, let userID = user.id else {
            return
        }
        
        Server.instance.recoverIMUser(withUserId: userID, andDeviceID: deviceId, recoveryPassword: password).asObservable().subscribe(onNext: { [weak self] (result) in
            switch result {
            case .success(let model):
                print(model)
                self?.userLoginStatus.accept(model.status)
                
                switch model.status {
                case .deviceIDNotMatched:
                    handle(false)
                case .noSuchUser:
                    handle(false)
                case .userExists:
                    let userModel = IMUser.init(uID: model.uID, nickName: user.name ?? "", introduction: "", headImg: nil)
                    self?.userModel = BehaviorRelay.init(value: userModel)
                    self?.shouldLoginToRocketChat.onNext(())
                    self?.saveIMUser()
                    handle(true)
                }
            case .failed(error: let err):
                DLogError(err)
                handle(false)
            }
        }).disposed(by: bag)
    }
    
    func setRecoveryPassword(password: String) {
        guard let uID = self.userModel.value?.uID  else {
            return
        }
        Server.instance.setRecoveryPassword(withIMUserId: uID, recoveryPassword: password).asObservable().subscribe(onNext: { (result) in
            print(result)
        }).disposed(by: bag)
    }
    
    func saveIMUser() {
        let localUser = LocalIMUser.createLocalIMUser(from: self.userModel.value!)
        let _ = try? localUser.store()
        
    }
    
    func clearIMUser() {
        LocalIMUser.clear()
    }
    
    func getFriendList(complete: @escaping (_ model: MemberPersonalChatAndGroupsModel?) -> Void) {
        guard let rocketChatUID = IMUserManager.manager.userModel.value?.uID else {
            return
        }
        
        Server
            .instance
            .getUserPersonalChatList(imUserId: rocketChatUID)
            .asObservable()
            .subscribe(onNext: {[weak self] (result) in
                switch result {
                case .success(let model):   complete(model.personalDirectoryModel)
                case .failed(let error):    complete(nil)
                }
            }).disposed(by: bag)
    }
    
    func inviteFriend(myselfRocketChatUID: String, friendRocketChatUID: String, welcomeMessage: String) -> RxAPIResponse<SendFriendRequestAPIModel> {
        return Server.instance.sendFriendRequestAPI(inviterUserID: myselfRocketChatUID, inviteeUserID: friendRocketChatUID, invitationMessage: welcomeMessage)
    }
    
    //    func respondToFriendRequest(accept: Bool, invitationID: String, complete: @escaping (_ result: Bool) -> Void) {
    //        guard let imUID = self.userModel.value?.uID,
    //              let authToken = RocketChatManager.manager.rocketChatUser.value?.authToken,
    //              let rocketChatUserId = RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId else {
    //                complete(false)
    //                return
    //        }
    //
    //        Server
    //            .instance
    //            .respondToFriendRequestAPI(inviteeUserID: imUID, invitationId: invitationID, accept: accept, authToken: authToken, rocketChatUserId: rocketChatUserId)
    //            .asObservable()
    //            .subscribe(onNext: { (result) in
    //            print(result)
    //        }).disposed(by: bag)
    //    }
}
