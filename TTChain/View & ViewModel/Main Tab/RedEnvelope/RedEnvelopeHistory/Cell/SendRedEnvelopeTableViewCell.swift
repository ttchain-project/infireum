//
//  SendRedEnvelopeTableViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class SendRedEnvelopeTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var paidTimeLabel: UILabel!

    var viewModel: SendRedEnvelopeTableViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.text = viewModel.output.title
            amountLabel.text = viewModel.output.amount
            paidTimeLabel.text = viewModel.output.paidTime
            amountLabel.textColor = viewModel.output.textColor
        }
    }
}
