//
//  ReceiveRedEnvelopeTableViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class ReceiveRedEnvelopeTableViewCell: UITableViewCell {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var coinDisplayNameLabel: UILabel!

    var viewModel: ReceiveRedEnvelopeTableViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            avatarImageView.setProfileImage(image: viewModel.output.imageString, tempName: nil)
            titleLabel.text = viewModel.output.title
            timeLabel.text = viewModel.output.timestamp
            statusLabel.text = viewModel.output.status
            amountLabel.text = viewModel.output.amount
            coinDisplayNameLabel.text = viewModel.output.coinDisplayName
        }
    }
}
