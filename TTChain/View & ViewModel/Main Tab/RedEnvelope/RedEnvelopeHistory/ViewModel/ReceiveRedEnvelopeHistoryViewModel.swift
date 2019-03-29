//
//  ReceiveRedEnvelopeHistoryViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveRedEnvelopeHistoryViewModel: ViewModel {
    typealias Information = RedEvelopeInfoModel

    struct Input {
        let informationSubject: BehaviorSubject<Information?>
        let identifier: String
        let closeTapSubject = PublishSubject<Void>()
    }

    struct Output {
        let amountSubject = BehaviorSubject<String?>(value: nil)
        let coinDisplayNameSubject = BehaviorSubject<String?>(value: nil)
        let statusSubject = BehaviorSubject<String?>(value: nil)
        let imageSubject = BehaviorSubject<UIImage?>(value: nil)
        let senderNameSubject = BehaviorSubject<String?>(value: nil)
        let addressSubject = BehaviorSubject<String?>(value: nil)
        let createTimeSubject = BehaviorSubject<String?>(value: nil)
        let receiveTimeSubject = BehaviorSubject<String?>(value: nil)
        let depositTimeSubject = BehaviorSubject<String?>(value: nil)
        let backgroundImageSubject = BehaviorSubject<UIImage>(value: #imageLiteral(resourceName: "bgRecordCardBlue.png"))
        let isDoneLabelHiddenSubject = BehaviorSubject<Bool>(value: true)
        let dismissSubject = PublishSubject<Void>()
        let toSubject = BehaviorSubject<String>(value: "To")
        let isSenderNameHiddenSubject = BehaviorSubject<Bool>(value: false)
        let hasCloseBarButton: Bool
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init(identifier: String,
         information: Information? = nil,
         member: Information.Member,
         hasCloseBarButton: Bool = true) {
        input = Input(informationSubject: BehaviorSubject<Information?>(value: information), identifier: identifier)
        output = Output(hasCloseBarButton: hasCloseBarButton)
        getRedEnvelope(identifier)
        input.informationSubject.subscribe(onNext: { [unowned self] information in
            guard let information = information else { return }
            self.setUpInformation(information, member: member)
        }, onError: nil,
           onCompleted: nil,
           onDisposed: nil).disposed(by: disposeBag)
        input.closeTapSubject.bind(to: output.dismissSubject).disposed(by: disposeBag)
    }

    private func getRedEnvelope(_ identifier: String) {
        
        let parameter =  RedEnvelopeInfoAPI.Parameters.init(redEnvelopeId: identifier)
        Server.instance.getRedEnvelopeInfo(parameter: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: _):
                DLogError("error")
            case .success(let model):
                self.input.informationSubject.onNext(model.redEnvelopeInfo)
            }
        }).disposed(by: disposeBag)
    }

    private func setUpInformation(_ information: Information, member: Information.Member) {
        if member.uid == Tokens.getUID() {
            output.statusSubject.onNext(member.isDone ? "恭喜，红包钱入帐了" : "等待塞钱进红包")
            output.senderNameSubject.onNext(information.info.senderName)
        } else {
            output.statusSubject.onNext(member.isDone ? "塞钱成功" : "等待塞钱进红包")
            output.isSenderNameHiddenSubject.onNext(true)
            output.toSubject.onNext("To \(member.nickName)")
        }
        let amountDecimal = NSNumber(value: member.receiveAmount).decimalValue
        output.amountSubject.onNext(NSDecimalNumber(decimal: amountDecimal).stringValue)
        output.coinDisplayNameSubject.onNext(information.info.displayName)
        output.imageSubject.onNext(member.isDone ? #imageLiteral(resourceName: "progressBarSendPageSuccess.png") : #imageLiteral(resourceName: "progressBarSendPageWait.png"))
        output.addressSubject.onNext(member.receiveAddress)
        
        output.createTimeSubject.onNext(information.info.createTime.convertToDateString)
        output.receiveTimeSubject.onNext(member.receiveTime.convertToDateString)
        output.depositTimeSubject.onNext(member.paidTime?.convertToDateString ?? "-")
        output.backgroundImageSubject.onNext(member.isDone ? #imageLiteral(resourceName: "bgRecordCardBlue.png") : #imageLiteral(resourceName: "bgRecordCard.png"))
        output.isDoneLabelHiddenSubject.onNext(member.isDone == false)
    }
}
