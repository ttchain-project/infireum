//
//  SendRedEnvelopeHistoryViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import RxSwift
import UIKit

class SendRedEnvelopeHistoryViewController: UIViewController {
    @IBOutlet private weak var isDoneLabel: UILabel! {
        didSet {
            viewModel.output.isDoneLabelHiddenSubject.bind(to: isDoneLabel.rx.isHidden)
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var isWaitingLabel: UILabel! {
        didSet {
            viewModel.output.isWaitingLabelHiddenSubject.bind(to: isWaitingLabel.rx.isHidden)
                .disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var progressImageView: UIImageView! {
        didSet {
            viewModel.output.imageSubject.bind(to: progressImageView.rx.image).disposed(by: viewModel.disposeBag)
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableHeaderView = headerView
            tableView.tableFooterView = UIView()
            tableView.register(cellType: SendRedEnvelopeTableViewCell.self)
            tableView.rowHeight = SendRedEnvelopeTableViewCellModel.height
            viewModel.output.cellModelsRelay
                .bind(to: tableView.rx.items(dataSource: viewModel.output.dataSource))
                .disposed(by: viewModel.disposeBag)
            tableView.delegate = self
        }
    }

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btnCancelWhiteNormal.png"), style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.bind(to: viewModel.input.closeTapSubject).disposed(by: viewModel.disposeBag)
        barButtonItem.tintColor = UIColor.black
        return barButtonItem
    }()
    private var headerView: SendRedEnvelopeHistoryView {
        return SendRedEnvelopeHistoryView(viewModel: viewModel)
    }

    private let viewModel: SendRedEnvelopeHistoryViewModel

    init(viewModel: SendRedEnvelopeHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: SendRedEnvelopeHistoryViewController.className, bundle: nil)
        viewModel.output.enterPasswordAlertSubject.subscribe(onNext: { [unowned self] text in
            self.presentEnterPasswordAlert(text)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: viewModel.disposeBag)
        viewModel.output.continueAlertSubject.subscribe(onNext: { [unowned self] text in
            self.presentContinueAlert(text)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: viewModel.disposeBag)
        viewModel.output.messageSubject.bind(to: rx.message).disposed(by: viewModel.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = viewModel.output.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    private func setUpView() {
        title = LM.dls.red_env_send_records
        if viewModel.output.hasCloseBarButton {
            navigationItem.rightBarButtonItem = closeBarButtonItem
        }
    }

    private func presentEnterPasswordAlert(_ text: String) {
        let alertController = UIAlertController(title: LM.dls.red_env_send_confirm_transfer,
                                                message: text,
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = LM.dls.qrCodeImport_alert_input_pwd
        }
        let okAlertAction = UIAlertAction(title: LM.dls.g_confirm,
                                          style: .default) { [unowned alertController, unowned self] _ in
                                            guard let password = alertController.textFields?.first?.text else { return }
                                            self.viewModel.input.enterPasswordSubject.onNext(password)
        }
        let cancelAlertAction = UIAlertAction(title: LM.dls.g_cancel, style: .cancel)
        alertController.addAction(cancelAlertAction)
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }

    private func presentContinueAlert(_ text: String) {
        let alertController = UIAlertController(title: nil,
                                                message: text,
                                                preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: LM.dls.g_confirm, style: .default) { [unowned self] _ in
            self.viewModel.input.sendTapSubject.onNext(())
        }
        let cancelAlertAction = UIAlertAction(title: LM.dls.g_cancel, style: .cancel)
        alertController.addAction(cancelAlertAction)
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension SendRedEnvelopeHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.output.cellModelsRelay.value[section].items.isEmpty {
            return UIView()
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
            let label = UILabel(frame: CGRect(x: 18, y: 0, width: UIScreen.main.bounds.size.width - 36, height: 17))
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = viewModel.output.cellModelsRelay.value[section].model
            label.textColor = UIColor.gray
            view.addSubview(label)
            return view
        }
    }
}
