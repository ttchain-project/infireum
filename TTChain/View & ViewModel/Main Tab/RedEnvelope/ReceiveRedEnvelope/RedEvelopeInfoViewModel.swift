//
//  RedEvelopeInfoViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/26.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift

class RedEvelopeInfoViewModel: ViewModel {
    
    enum Action {
        case received, dismiss
    }
    
    struct Input {
        let information: RedEvelopeInfoModel
        let identifier: String
        let receiveTapSubject = PublishSubject<Void>()
        let closeTapSubject = PublishSubject<Void>()
    }
    
    struct Output {
        let imageString: String?
        let title: String?
        let message: String
        let isReceiveButtonHiddenSubject = BehaviorSubject<Bool>(value: false)
        let status: String?
        let actionSubject = PublishSubject<Action>()
        let messageSubject = PublishSubject<String>()
    }
    
    var input: Input
    var output: Output
    let disposeBag = DisposeBag()
    
    init(identifier: String, information: RedEvelopeInfoModel) {
        input = Input(information: information, identifier: identifier)
        let isEmpty = information.info.totalCount == information.info.receiveCount
        var isAlreadyClaimed:Bool = false
        
        var status:String? = information.info.isExpired ? "手慢了，红包过期了" :
            isEmpty ? "手慢了，红包被抢光了" : "未领取"
        
        if (information.members.filter{ $0.uid == Tokens.getUID() }).first != nil {
            isAlreadyClaimed = true
            status = "已领取"
        }
        
        output = Output(imageString: information.info.headImg.medium,
                        title: information.info.senderName,
                        message: information.info.message,
                        status: status)
        output.isReceiveButtonHiddenSubject.onNext(information.info.isExpired || isEmpty || isAlreadyClaimed)
        input.closeTapSubject.map { Action.dismiss }.bind(to: output.actionSubject).disposed(by: disposeBag)
        input.receiveTapSubject.subscribe(onNext: { [unowned self] in
            self.receive(identifier: identifier, information: information)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
    }
    
    
    private func receive(identifier: String, information: RedEvelopeInfoModel) {
        
        guard let coin = Coin.getCoin(ofIdentifier: information.info.identifier) else {
            self.output.messageSubject.onNext("No wallet supporting this coin found")
            return
        }
        
        let wallet = Wallet.getWallets(ofMainCoinID: coin.walletMainCoinID!)
        
        let parameter = AcceptRedEnvelopeAPI.Parameters.init(redEnvelopeId: identifier, receiveAddress: wallet[0].address!)
        
        Server.instance.acceptRedEvelope(parameter: parameter).asObservable().subscribe(onNext: {[weak self] response in
            switch response {
            case .success(let model):
                if model.status {
                    self?.output.actionSubject.onNext(.received)
                }else {
                    self?.output.messageSubject.onNext("Failed")
                }
            case .failed(let error):
                print(error)
                self?.output.messageSubject.onNext(error.localizedDescription)
            }
        }).disposed(by:disposeBag)
    }
    
    private static func content(information: RedEvelopeInfoModel) -> String? {
        let displayName = Coin.getCoin(ofIdentifier: information.info.identifier)?.inAppName ?? ""
        return String(format: "%d / %d 已領取 共 %@ %@",
                      information.info.receiveCount,
                      information.info.totalCount,
                      information.info.totalAmount.description,
                      displayName)
    }
}
