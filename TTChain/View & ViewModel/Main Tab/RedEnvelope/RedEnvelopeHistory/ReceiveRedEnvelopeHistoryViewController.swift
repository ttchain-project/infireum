//
//  ReceiveRedEnvelopeHistoryViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class ReceiveRedEnvelopeHistoryViewController: UIViewController {
    @IBOutlet private weak var isDoneLabel: UILabel! {
        didSet {
            viewModel.output.isDoneLabelHiddenSubject.bind(to: isDoneLabel.rx.isHidden)
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var contentLabel: UILabel! {
        didSet {
            viewModel.output.statusSubject.bind(to: contentLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var senderNameLabel: UILabel! {
        didSet {
            viewModel.output.senderNameSubject.bind(to: senderNameLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var addressLabel: UILabel! {
        didSet {
            viewModel.output.addressSubject.bind(to: addressLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var createTimeLabel: UILabel! {
        didSet {
            viewModel.output.createTimeSubject.bind(to: createTimeLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var receiveTimeLabel: UILabel! {
        didSet {
            viewModel.output.receiveTimeSubject.bind(to: receiveTimeLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var depositTimeLabel: UILabel! {
        didSet {
            viewModel.output.depositTimeSubject.bind(to: depositTimeLabel.rx.text).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var cardImageView: UIImageView! {
        didSet {
            viewModel.output.backgroundImageSubject.bind(to: cardImageView.rx.image).disposed(by: viewModel.disposeBag)
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
    @IBOutlet private weak var progressImageView: UIImageView! {
        didSet {
            viewModel.output.imageSubject.bind(to: progressImageView.rx.image).disposed(by: viewModel.disposeBag)
        }
    }

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btnCancelWhiteNormal.png"), style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.bind(to: viewModel.input.closeTapSubject).disposed(by: viewModel.disposeBag)
        barButtonItem.tintColor = UIColor.black
        return barButtonItem
    }()
    private let viewModel: ReceiveRedEnvelopeHistoryViewModel

    init(viewModel: ReceiveRedEnvelopeHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: ReceiveRedEnvelopeHistoryViewController.className, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    private func setUpView() {
        title = "红包领取纪录"
        if viewModel.output.hasCloseBarButton {
            navigationItem.rightBarButtonItem = closeBarButtonItem
        }
    }
}
