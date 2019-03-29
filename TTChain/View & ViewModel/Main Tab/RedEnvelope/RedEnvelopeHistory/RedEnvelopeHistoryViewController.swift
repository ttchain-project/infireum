//
//  RedEnvelopeHistoryViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2019/3/4.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class RedEnvelopeHistoryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(cellType: RedEnvelopeHistoryTableViewCell.self)
            tableView.rowHeight = RedEnvelopeHistoryTableViewCellModel.height
            viewModel.output.cellModelsRelay
                .bind(to: tableView.rx.items(cellIdentifier: RedEnvelopeHistoryTableViewCell.className,
                                             cellType: RedEnvelopeHistoryTableViewCell.self)) { _, cellModel, cell in
                                                cell.viewModel = cellModel
                }.disposed(by: viewModel.disposeBag)
            tableView.rx.itemSelected.bind(to: viewModel.input.selectedItemSubject).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var sendButton: UIButton! {
        didSet {
            sendButton.rx.tap.bind(to: viewModel.input.sendTapSubject).disposed(by: viewModel.disposeBag)
            viewModel.output.sendButtonColorSubject.bind(to: sendButton.rx.titleColor(for: .normal))
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var receiveButton: UIButton! {
        didSet {
            receiveButton.rx.tap.bind(to: viewModel.input.receiveTapSubject).disposed(by: viewModel.disposeBag)
            viewModel.output.receiveButtonColorSubject.bind(to: receiveButton.rx.titleColor(for: .normal))
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var underLineView: UIView!
    @IBOutlet private weak var underLineConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sortTypeButton: UIButton!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var sortMenuView: UIView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var checkImageViews: [UIImageView]! {
        didSet {
            checkImageViews.forEach { imageView in
                viewModel.output.sortTypeRelay.map { $0.rawValue == imageView.tag ? #imageLiteral(resourceName: "recordListCheck.png") : nil }
                    .bind(to: imageView.rx.image).disposed(by: viewModel.disposeBag)
            }
        }
    }
    @IBOutlet private var sortButtons: [UIButton]! {
        didSet {
            sortButtons.forEach { button in
                viewModel.output.sortTypeRelay.map { $0.rawValue == button.tag ? UIColor.owAzure : UIColor.black }
                    .bind(to: button.rx.titleColor()).disposed(by: viewModel.disposeBag)
            }
        }
    }

    private let viewModel: RedEnvelopeHistoryViewModel

    init(viewModel: RedEnvelopeHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: RedEnvelopeHistoryViewController.className, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private func setUpView() {
        title = "红包纪录"
//        setUpBackBarButtonItem()
        viewModel.output.isReceivedRelay.skip(1).subscribe(onNext: { [unowned self] isReceived in
            if self.underLineConstraint != nil {
                self.underLineConstraint.isActive = false
            }
            UIView.animate(withDuration: 0.24) {
                if isReceived {
                    self.underLineView.center.x = self.receiveButton.center.x
                } else {
                    self.underLineView.center.x = self.sendButton.center.x
                }
            }
        }, onError: nil,
           onCompleted: nil,
           onDisposed: nil).disposed(by: viewModel.disposeBag)
    }

    @IBAction private func clickSortButton(_ sender: UIButton) {
        guard let type = RedEnvelopeHistoryViewModel.SortType(rawValue: sender.tag) else { return }
        viewModel.input.sortTypeSubject.onNext(type)
        sortTypeButton.setTitle(sender.title(for: .normal), for: .normal)
        UIView.animate(withDuration:  0.24,
                       animations: {
                        self.shadowView.alpha = 0
                        let originY = self.tableView.frame.origin.y - self.sortMenuView.bounds.size.height
                        self.sortMenuView.frame.origin.y = originY
        }, completion: { _ in
            self.shadowView.isHidden = true
        })
    }

    @IBAction private func clickSortTypeButton(_ sender: UIButton) {
        if bottomConstraint != nil {
            bottomConstraint.isActive = false
        }
        if shadowView.isHidden {
            shadowView.alpha = 0
            shadowView.isHidden = false
            UIView.animate(withDuration:  0.24) {
                self.shadowView.alpha = 1
                self.sortMenuView.frame.origin.y = self.tableView.frame.origin.y
            }
        } else {
            UIView.animate(withDuration:  0.24,
                           animations: {
                            self.shadowView.alpha = 0
                            let originY = self.tableView.frame.origin.y - self.sortMenuView.bounds.size.height
                            self.sortMenuView.frame.origin.y = originY
            }, completion: { _ in
                self.shadowView.isHidden = true
            })
        }
    }
}
