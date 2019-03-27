//
//  RedEnvelopeDetailView.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class RedEnvelopeDetailView: UIView {
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.setProfileImage(image: viewModel.output.imageString, tempName: nil)
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = viewModel.output.title
        }
    }
    @IBOutlet private weak var contentLabel: UILabel! {
        didSet {
            contentLabel.text = viewModel.output.message
        }
    }
    @IBOutlet private weak var amountLabel: UILabel! {
        didSet {
            amountLabel.text = viewModel.output.amount
        }
    }
    @IBOutlet private weak var coinDisplayNameLabel: UILabel! {
        didSet {
            coinDisplayNameLabel.text = viewModel.output.coinDisplayName
        }
    }
    @IBOutlet private weak var sendButton: UIButton! {
        didSet {
            viewModel.output.isSendButtonHiddenSubject.bind(to: sendButton.rx.isHidden)
                .disposed(by: viewModel.disposeBag)
            sendButton.rx.tap.bind(to: viewModel.input.sendTapSubject).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var statusLabel: UILabel! {
        didSet {
            viewModel.output.statusSubject.bind(to: statusLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var receiveCountLabel: UILabel! {
        didSet {
            viewModel.output.contentSubject.bind(to: receiveCountLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var luckyImageView: UIImageView! {
        didSet {
            luckyImageView.isHidden = viewModel.output.isLuckyHidden
        }
    }
    @IBOutlet private weak var expiredLabel: UILabel! {
        didSet {
            expiredLabel.text = viewModel.output.expiredString
        }
    }

    private let viewModel: RedEnvelopeDetailViewModel

    init(viewModel: RedEnvelopeDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.size.width,
                                 height: RedEnvelopeDetailViewModel.height))
        nibSetUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func nibSetUp() {
        UINib(nibName: className, bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    }
}
