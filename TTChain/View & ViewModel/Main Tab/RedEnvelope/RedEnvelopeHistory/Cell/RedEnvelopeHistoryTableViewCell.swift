//
//  RedEnvelopeHistoryTableViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2019/3/4.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class RedEnvelopeHistoryTableViewCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var coinLabel: UILabel!
    @IBOutlet private weak var amountTitleLabel: UILabel!

    var viewModel: RedEnvelopeHistoryTableViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            DispatchQueue.main.async { [unowned self] in
                switch viewModel.output.status {
                case .received: self.iconImageView.image = #imageLiteral(resourceName: "iconReceiveGreen.png")
                case .sent: self.iconImageView.image = #imageLiteral(resourceName: "iconSendGreen.png")
                case .waitPaid: self.iconImageView.image = #imageLiteral(resourceName: "iconReceiveBlue.png")
                case .waitReceive: self.iconImageView.image = #imageLiteral(resourceName: "iconWaitReceiveGray.png")
                case .waitSend: self.iconImageView.image = #imageLiteral(resourceName: "iconWaitSendRed.png")
                }
                let isReceive = viewModel.output.status == .received || viewModel.output.status == .waitPaid
                self.amountTitleLabel.text = isReceive ? "金额" : "金额 / 数量"
                self.titleLabel.text = viewModel.output.title
                self.amountLabel.text = viewModel.output.amount
                self.statusLabel.text = viewModel.output.statusString
                self.coinLabel.text = viewModel.output.coinDisplayName
                switch viewModel.output.status {
                case .received: self.statusLabel.textColor = UIColor.owCoolGreen
                case .waitPaid: self.statusLabel.textColor = UIColor.owAzure
                case .sent: self.statusLabel.textColor = UIColor.owWaterBlue
                case .waitReceive: self.statusLabel.textColor = UIColor.owWarmGrey
                case .waitSend: self.statusLabel.textColor = UIColor.owPinkRed
                }
            }
        }
    }
}
