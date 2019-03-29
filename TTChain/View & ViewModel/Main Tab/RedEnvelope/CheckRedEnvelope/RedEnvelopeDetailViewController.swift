//
//  RedEnvelopeDetailViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import UIKit

class RedEnvelopeDetailViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableHeaderView = headerView
            tableView.register(cellType: ReceiveRedEnvelopeTableViewCell.self)
            tableView.rowHeight = ReceiveRedEnvelopeTableViewCellModel.height
            viewModel.output.cellModelsSubject
                .bind(to: tableView.rx.items(cellIdentifier: ReceiveRedEnvelopeTableViewCell.className,
                                             cellType: ReceiveRedEnvelopeTableViewCell.self)) { _, cellModel, cell in
                                                cell.viewModel = cellModel
            }.disposed(by: viewModel.disposeBag)
            
            viewModel.output.cellModelsSubject.map { [unowned self] in
                $0.isEmpty ? UIView() : self.footerButton
                }.bind(to: tableView.rx.tableFooterView).disposed(by: viewModel.disposeBag)
            
            tableView.delegate = self
        }
    }
    @IBOutlet private weak var checkButton: UIButton! {
        didSet {
            viewModel.output.cellModelsSubject.map { $0.isEmpty == false }
                .bind(to: checkButton.rx.isHidden).disposed(by: viewModel.disposeBag)
            checkButton.rx.tap.bind(to: viewModel.input.historyTapSubject).disposed(by: viewModel.disposeBag)
        }
    }

    @IBOutlet weak var bgView: UIImageView! {
        didSet {
            let color1 = UIColor(red:254,green: 135,blue: 98)?.cgColor
            let color2 = UIColor(red:230,green: 75,blue: 75)?.cgColor
            self.bgView.setGradientColor(color1:color1, color2: color2)
        }
    }
    private lazy var titleView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        label.text = LM.dls.view_red_envelope
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    private lazy var headerView = RedEnvelopeDetailView(viewModel: viewModel)
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btnCancelWhiteNormal.png"), style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.bind(to: viewModel.input.closeTapSubject).disposed(by: viewModel.disposeBag)
        barButtonItem.tintColor = UIColor.white
        return barButtonItem
    }()
    private lazy var spaceBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btnCancelWhiteNormal.png"), style: .plain, target: self, action: nil)
        barButtonItem.tintColor = UIColor.clear
        return barButtonItem
    }()
    private lazy var footerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 2, height: 46))
        button.backgroundColor = .white
        let attributedString = NSMutableAttributedString(string: LM.dls.red_env_view_record, attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.owAzure])
        let subStringRange = LM.dls.red_env_view_record.range(of: LM.dls.red_env_view_record_substring)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.owCharcoalGrey,
                                      range: NSRange(subStringRange!,in:LM.dls.red_env_view_record))
        button.setAttributedTitle(attributedString, for: .normal)
        button.rx.tap.bind(to: viewModel.input.historyTapSubject).disposed(by: viewModel.disposeBag)
        return button
    }()
    
    private let viewModel: RedEnvelopeDetailViewModel

    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    
    init(viewModel: RedEnvelopeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: RedEnvelopeDetailViewController.className, bundle: nil)
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
        
        viewModel.output.hudAnimationStatus.subscribe(onNext: { [unowned self] status in
            if status {
                self.hud.startAnimating(inView: self.view)
            }else {
                self.hud.stopAnimating()
            }
        }).disposed(by:viewModel.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.bounds.height
        tableView.tableHeaderView?.frame.size.height = 440
    }

    private func setUpView() {
        navigationItem.rightBarButtonItem = closeBarButtonItem
        navigationItem.leftBarButtonItem = spaceBarButtonItem
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "arrowNavWhite.png")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "arrowNavWhite.png")
        navigationItem.titleView = titleView
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

extension RedEnvelopeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 10))
        let cornerRadiusView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        cornerRadiusView.backgroundColor = .white
        cornerRadiusView.cornerRadius = 10
        headerView.addSubview(cornerRadiusView)
        headerView.clipsToBounds = true
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
