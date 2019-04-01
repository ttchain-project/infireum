//
//  SendRedEnvelopeHistoryView.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

final class SendRedEnvelopeHistoryView: UIView {
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var amountContentLabel: UILabel! {
        didSet {
            viewModel.output.amountContentSubject.bind(to: amountContentLabel.rx.text)
            .disposed(by: viewModel.disposeBag)
            
        }
    }
    @IBOutlet private weak var amountLabel: UILabel! {
        didSet {
            viewModel.output.amountSubject.bind(to: amountLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var coinLabel: UILabel! {
        didSet {
            viewModel.output.coinDisplayNameSubject.bind(to: coinLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }

    @IBOutlet private weak var sendButton: UIButton! {
        didSet {
            sendButton.rx.tap.bind(to: viewModel.input.sendTapSubject).disposed(by: viewModel.disposeBag)
            viewModel.output.isSendButtonHiddenRelay.bind(to: sendButton.rx.isHidden).disposed(by: viewModel.disposeBag)
            sendButton.setTitle(LM.dls.red_env_send_confirm_transfer, for: .normal)
        }
    }
    @IBOutlet private weak var createTimeLabel: UILabel! {
        didSet {
            viewModel.output.createTimeSubject.bind(to: createTimeLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var addressLabel: UILabel! {
        didSet {
            viewModel.output.addressSubject.bind(to: addressLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var expiredTimeLabel: UILabel! {
        didSet {
            viewModel.output.expiredTimeSubject.bind(to: expiredTimeLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            viewModel.output.descriptionSubject.bind(to: descriptionLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }

    private let viewModel: SendRedEnvelopeHistoryViewModel

    init(viewModel: SendRedEnvelopeHistoryViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.size.width,
                                 height: viewModel.output.height))
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
