//
//  ReceiveRedEnvelopeTableViewCellModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveRedEnvelopeTableViewCellModel: ViewModel {
    typealias Member = RedEvelopeInfoModel.Member

    static let height: CGFloat = 84

    struct Input {
        let member: Member
    }

    struct Output {
        let imageString: String?
        let title: String?
        let timestamp: String?
        let status: String?
        let amount: String?
        let coinDisplayName: String?
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init(member: Member, displayName: String?) {
        input = Input(member: member)
        let date = DateFormatter.date(from: member.receiveTime, withFormat: C.IMDateFormat.dateFormatForIM)

        output = Output(imageString: member.imageString?.medium,
                        title: member.nickName,
                        timestamp: date?.string(),
                        status: member.isDone ? LM.dls.red_env_money_sent : LM.dls.red_env_waiting_to_send,
                        amount: NSNumber(value: member.receiveAmount).decimalValue.description,
                        coinDisplayName: displayName)
    }
}
