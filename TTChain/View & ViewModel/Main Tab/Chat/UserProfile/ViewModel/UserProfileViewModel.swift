//
//  UserProfileViewModel.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserProfileViewModel :KLRxViewModel {
    
    typealias InputSource = Void
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()
    
    var input: UserProfileViewModel.InputSource
    var output: UserProfileViewModel.OutputSource
    struct Output {
        let messageSubject = PublishSubject<String>()
        let animateSubject = PublishSubject<Bool>()
        let friendRequestDoneSubject = PublishSubject<Void>()
    }
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
    }
    
    func concatOutput() {
    }
    
    func handleFriendRequest(withStatus accept: Bool, forModel model: FriendModel) {
        guard let reqModel = model as? FriendRequestInformationModel else {
            return
        }
        self.output.animateSubject.onNext(true)
        Server.instance.respondToFriendRequestAPI(invitationId: reqModel.invitationID, accept: accept).asObservable().subscribe(onNext : { [unowned self] (response) in
            self.output.animateSubject.onNext(false)
            switch response {
            case .failed(error: let err):
                print(err)
                self.output.messageSubject.onNext(err.descString)
            case .success(_):
                self.output.friendRequestDoneSubject.onNext(())
            }
        }).disposed(by:bag)
    }
    
    func sendFriendRequest(rocketChatUID: String, welcomeMessage: String) {
        guard let myselfRocketChatUID = RocketChatManager.manager.rocketChatUser.value?.name else { return }
        self.output.animateSubject.onNext(true)
        IMUserManager.manager.inviteFriend(myselfRocketChatUID: myselfRocketChatUID, friendRocketChatUID: rocketChatUID, welcomeMessage: welcomeMessage).asObservable().subscribe(onNext: {
            [weak self] result in
            self?.output.animateSubject.onNext(false)
            guard let `self` = self else { return }
            switch result {
            case .success:
//                self.output.messageSubject.onNext(LM.dls.add_friend_alert_success)
                self.output.friendRequestDoneSubject.onNext(())

            case .failed(error: let error):
                self.output.messageSubject.onNext(error.descString)
            }
        }).disposed(by: bag)
    }
}
