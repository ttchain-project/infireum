//
//  RedEnvelopeHistoryTableViewCellModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/3/4.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxSwift

final class RedEnvelopeHistoryTableViewCellModel: ViewModel {
    static let height: CGFloat = 102

    enum Status: String {
        case waitSend, waitReceive, sent, received, waitPaid
    }

    struct Input {
        let identifier: String
        let amount: NSDecimalNumber
        let time: String
    }

    struct Output {
        let title: String
        let coinDisplayName: String
        let amount: String
        var statusString: String {
            switch status {
            case .waitPaid, .waitSend: return "等待塞钱"
            case .received: return "领取成功"
            case .waitReceive: return "等待领取"
            case .sent: return "塞钱完毕"
            }
        }
        let status: Status
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init(response: ReceiveRedEnvelopeHistoryModel) {
        let amount = NSDecimalNumber(decimal: NSNumber(value: response.receiveAmount).decimalValue)
        let time = response.createTime.convertToDateString
        input = Input(identifier: response.redEnvelopeId, amount: amount, time: time)
        let title = time + " " + response.senderName
        output = Output(title: title,
                        coinDisplayName: response.displayName,
                        amount: "+\(amount.stringValue)",
                        status: response.isDone ? .received : .waitPaid)
    }

    init(response: SendRedEnvelopeHistoryModel) {
        let amount = NSDecimalNumber(decimal: NSNumber(value: response.totalAmount).decimalValue)
        let title = response.createTime.convertToDateString
        input = Input(identifier: response.redEnvelopeId, amount: amount, time: title)
        var status: Status
        switch response.status {
        case .done: status = .sent
        case .waitReceive: status = .waitReceive
        case .waitSend: status = .waitSend
        }
        output = Output(title: title,
                        coinDisplayName: response.displayName,
                        amount: "-\(amount.stringValue) / \(response.totalCount)",
                        status: status)
    }
}
