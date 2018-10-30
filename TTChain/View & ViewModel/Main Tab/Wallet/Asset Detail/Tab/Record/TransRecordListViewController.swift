//
//  TransRecordListViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransRecordListViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    public lazy var nextPage: Driver<Void> = {
        return tableView.rx.contentOffset
            .asDriver()
            .map { $0.y }
            .filter({ [unowned self] (y) -> Bool in
                let sizeHeight = self.tableView.contentSize.height
                let tableViewHeight = self.tableView.height
                guard sizeHeight >= tableViewHeight else {
                    return false
                }
                
                let buffer: CGFloat = -20
                let refreshPoint = sizeHeight - tableViewHeight - buffer
                return y > refreshPoint
            })
            .throttle(1)
            .map {
                _ in ()
            }
        
    }()
    
    public lazy var onRefresh: Driver<Void> = {
        return refresher.rx.controlEvent(.valueChanged)
            .asDriver()
            .map { _ in () }
    }()
    
    private let refresher = UIRefreshControl.init()
    public func stopRefreshing() {
        refresher.endRefreshing()
    }
    
    enum RecordType {
        case total
        case deposit
        case withdrawal
        case failed
    }
    
    struct Config {
        let asset: Asset
        let records: [TransRecord]
        let type: RecordType
    }
    
    typealias Constructor = Config
    typealias ViewModel = TransRecordListViewModel
    var viewModel: TransRecordListViewModel!
    var bag: DisposeBag = DisposeBag.init()
    private var asset: Asset!
    private var recordType: RecordType = .total
    
    func config(constructor: TransRecordListViewController.Config) {
        recordType = constructor.type
        asset = constructor.asset
        
        view.layoutIfNeeded()
        setupTableView()
        viewModel = ViewModel.init(
            input: TransRecordListViewModel.InputSource(
                records: filterDesiredRecords(from: constructor.records)
            ),
            output: ()
        )
        
        bindViewModel()
        observePrivateModeUpdateEvent()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func setupTableView() {
        tableView.register(TransRecordListTableViewCell.nib, forCellReuseIdentifier: TransRecordListTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
        tableView.addSubview(refresher)
        
        onRefresh.drive(onNext: {
            [unowned self] in self.refresher.beginRefreshing()
        })
        .disposed(by: bag)
        
        

    }
    
    private func bindViewModel() {
        viewModel.transRecords.bind(to: tableView.rx.items(cellIdentifier: TransRecordListTableViewCell.cellIdentifier(), cellType: TransRecordListTableViewCell.self)) {
            [unowned self]
            row, record, cell in
            cell.config(asset: self.asset,
                        transRecord: record,
                        statusURLHandle: {
                            (url) in
                            self.openTransRecordURL(url)
                        })
        }
        .disposed(by: bag)
        
        viewModel.transRecords.asObservable().subscribe(onNext: { (records) in
            self.tableView.isHidden = records.count == 0
            self.noDataLabel.isHidden = !self.tableView.isHidden
        }).disposed(by: bag)
    }
    
    private func observePrivateModeUpdateEvent() {
        OWRxNotificationCenter.instance.onChangePrivateMode
            .subscribe(onNext: {
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette

        view.backgroundColor = palette.bgView_main
        noDataLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 11)
        )
    }
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        noDataLabel.text = dls.g_error_emptyData
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Helper

    public func updateRecords(_ records: [TransRecord]) {
        let filteredRecords = filterDesiredRecords(from: records)
        viewModel.updateRecords(filteredRecords)
    }
    
    private func filterDesiredRecords(from records: [TransRecord]) -> [TransRecord] {
        switch recordType {
        case .deposit:
            return records.filter { $0.inoutRoleOfAddress(asset.wallet!.address!) == .deposit }
        case .withdrawal:
            return records.filter { $0.inoutRoleOfAddress(asset.wallet!.address!) == .withdrawal }
        case .failed:
            return records.filter { $0.owStatus == .failed }
        case .total:
            return records
        }
    }
    
    //MARK: - Routing
    private func openTransRecordURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
