//
//  SendRedEnvelopeTableViewCellModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxSwift

final class SendRedEnvelopeTableViewCellModel: ViewModel {
    typealias Member = RedEvelopeInfoModel.Member

    static let height: CGFloat = 69

    struct Input {
        let member: Member
    }

    struct Output {
        let title: String
        let amount: String
        let paidTime: String
        let textColor: UIColor
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init(member: Member) {
        input = Input(member: member)
        let amount = NSDecimalNumber(decimal: NSNumber(value: member.receiveAmount).decimalValue).stringValue
        let date = member.receiveTime.convertToDateString
        output = Output(title: "\(date) \(member.nickName)",
                        amount: amount,
                        paidTime: member.paidTime?.convertToDateString ?? "-",
                        textColor: member.isDone ? UIColor.black : UIColor.red)
    }
}
