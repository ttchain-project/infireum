//
//  RedEnvelopeCordinator.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/28.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift

class RedEnvelopeCordinator {
    
    let bag:DisposeBag = DisposeBag.init()
    
    
    func showCreateRedEnvelope(memberCount:Int? = 0, type:CreateRedEnvelopeViewModel.CreateType,identifier:String, presenterVC:UIViewController) {
        
        
        let viewModel = CreateRedEnvelopeViewModel.init(type: type, roomIdentifier: identifier, memberCount: memberCount ?? 0)
        let vc = CreateRedEnvelopeViewController.init(viewModel: viewModel)
        presenterVC.navigationController?.pushViewController(vc,animated:true)
        viewModel.output.dismissSubject.subscribe(onNext: { _ in
            vc.pop(sender: nil)
        }).disposed(by: viewModel.disposeBag)
    }
    
    func redEnvelopeAction(forRedEnvId redEnvMessage:RedEnvelope, onNavVC presenterVC:UIViewController) {
        
        let parameter = RedEnvelopeInfoAPI.Parameters.init(redEnvelopeId: redEnvMessage.identifier)
        Server.instance.getRedEnvelopeInfo(parameter: parameter).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .success(let model):
                let info = model.redEnvelopeInfo
                var vc:UIViewController!
                if [Tokens.getUID(),Tokens.getRocketChatUserID()].contains(redEnvMessage.senderUID) {
                    let viewModel = RedEnvelopeDetailViewModel.init(identifier: redEnvMessage.identifier, information: info)
                    
                    let redEnvVC = RedEnvelopeDetailViewController.init(viewModel: viewModel)
                    
                    vc = UINavigationController.init(rootViewController: redEnvVC)
                    viewModel.output.actionSubject.subscribe(onNext: { (action) in
                        switch action {
                        case .dismiss:
                            vc.dismiss(animated: true, completion: nil)
                        case .history:
                            var historyVC: UIViewController
                            if info.info.uid == Tokens.getUID() {
                                guard let vc = self.sendHistory(redEnvMessage.identifier, information: info) else {
                                    return
                                }
                                historyVC = vc

                            } else {
                                guard let vc = self.receiveHistory(redEnvMessage.identifier, information: info) else {
                                    return
                                }
                                historyVC = vc
                            }
                            let navController = vc as! UINavigationController
                            navController.pushViewController(historyVC, animated: true)
                        }
                    }).disposed(by: viewModel.disposeBag)
                    
                }else {
                    
                    let viewModel = RedEvelopeInfoViewModel.init(identifier: redEnvMessage.identifier, information: info)
                    vc = ReceiveRedEnvelopeViewController.init(viewModel: viewModel)
                    
                    viewModel.output.actionSubject.subscribe(onNext: { (_) in
                        vc.dismiss(animated: true, completion: nil)
                    }).disposed(by: viewModel.disposeBag)
                }
                
                presenterVC.present(vc, animated: true, completion: nil)
            case .failed(error:let error):
                print(error)
            }
        }).disposed(by: bag)
    }
    
    private func receiveHistory(_ identifier: String,
                                information:RedEvelopeInfoModel? = nil) -> UIViewController? {
        
        guard let member = information?.members.first(where: {
            $0.uid == Tokens.getUID()
        }) else { return nil}


        let viewModel = ReceiveRedEnvelopeHistoryViewModel(identifier: identifier,
                                                           information: information,
                                                           member: member)
        let viewController = ReceiveRedEnvelopeHistoryViewController(viewModel: viewModel)
        viewModel.output.dismissSubject.subscribe(onNext: { _ in
            viewController.pop(sender: nil)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: viewModel.disposeBag)
        return viewController
    }
    
    private func sendHistory(_ identifier: String, information: RedEvelopeInfoModel? = nil) -> UIViewController? {
        
        let viewModel = SendRedEnvelopeHistoryViewModel(identifier: identifier, information: information)
        let viewController = SendRedEnvelopeHistoryViewController(viewModel: viewModel)
        viewModel.output.actionSubject.asDriver(onErrorJustReturn: .dismiss)
            .drive(onNext: {
                action in
                switch action {
                case .dismiss:
                    viewController.pop(sender: nil)
                default: return
                }
                }, onCompleted: nil,
                   onDisposed: nil).disposed(by: viewModel.disposeBag)
        return viewController
    }
}
