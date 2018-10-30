//
//  TransferRecordsListViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class TransferRecordsListViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    private var nextPage: Driver<Void> {
        return listTableView.rx.contentOffset
            .asDriver()
            .map { $0.y }
            .filter({ [unowned self] (y) -> Bool in
                let sizeHeight = self.listTableView.contentSize.height
                let tableViewHeight = self.listTableView.height
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
    }
    
    private let refresher: UIRefreshControl = UIRefreshControl.init()
    private var refresh: Driver<Void> {
        return refresher.rx
                .controlEvent(.valueChanged)
                .asDriver()
                .map { _ in () }
                .throttle(1)
    }
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        configBars()
        setupTableView()
        viewModel = ViewModel.init(
            input: TransferRecordsListViewModel.InputSource(
//                defaultOptionProvider: infoBar.viewModel,
                defaultOptionProvider: optionBar.viewModel,
                refreshInput: refresh,
                nextPageInput: nextPage
            ),
            output: ()
        )
        
        bindViewModel()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    typealias ViewModel = TransferRecordsListViewModel
    var viewModel: TransferRecordsListViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var topBarBase: UIView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    
    private lazy var systemETHWallet: Wallet = {
        let systemETHWallet = Wallet.getWallets(ofMainCoinID: Coin.eth_identifier).filter { $0.isFromSystem }.first!
        return systemETHWallet
    }()
    
    private lazy var infoBar: TransferRecordInfoBarViewController = {
        return TransferRecordInfoBarViewController.instance(from: TransferRecordInfoBarViewController.Config(wallet: systemETHWallet))
    }()
    
    private lazy var optionBar: TransferRecordOptionBarViewController = {
       return TransferRecordOptionBarViewController.instance(from: TransferRecordOptionBarViewController.Config(defaultWallet: systemETHWallet))
    }()
    
    private func setupTableView() {
        listTableView.register(TransRecordListTableViewCell.nib, forCellReuseIdentifier: TransRecordListTableViewCell.cellIdentifier())
        listTableView.separatorStyle = .none
        
        listTableView.addSubview(refresher)
    }
    
    private func bindViewModel() {
        viewModel.filteredRecords.bind(to: listTableView.rx.items(cellIdentifier: TransRecordListTableViewCell.cellIdentifier(), cellType: TransRecordListTableViewCell.self)) {
            [weak self]
            row, rec, cell in
            guard let wSelf = self else { return }
            let wallet = wSelf.viewModel.getSelectedWallet()
            let address = wallet?.address ?? errorDebug(response: "")
            let type = wallet?.owChainType ?? errorDebug(response: .eth)
            
            cell.config(address: address,
                        chainType: type,
                        transRecord: rec,
                        statusURLHandle: { (url) in
                            wSelf.toRecordUrl(url: url)
                        })
        }
        .disposed(by: bag)
        
        viewModel.filteredRecords.asObservable().subscribe(onNext: { (records) in
            self.listTableView.isHidden = records.count == 0
            self.noDataLabel.isHidden = !self.listTableView.isHidden
        }).disposed(by: bag)
        
        viewModel.onReceiveRecordsUpdateResponse
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.refresher.endRefreshing()
            })
            .disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        noDataLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 11)
        )
        view.backgroundColor = palette.bgView_main
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.txRecord_title
        noDataLabel.text = dls.g_error_emptyData
    }
    
    private func configBars() {
//        topBarHeight.constant = TransferRecordInfoBarViewController.prefererHeight
        topBarHeight.constant = TransferRecordOptionBarViewController.preferedHeight
        view.layoutIfNeeded()
        
        addChildViewController(infoBar)
        infoBar.didMove(toParentViewController: self)
        topBarBase.addSubview(infoBar.view)
        
        constrain(infoBar.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
        
        addChildViewController(optionBar)
        optionBar.didMove(toParentViewController: self)
        topBarBase.addSubview(optionBar.view)

        constrain(optionBar.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }

//        optionBar.view.isHidden = true
        optionBar.view.isHidden = false
        
        infoBar.onSwitchingToOptionBar.drive(onNext: {
            [unowned self] in
            self.topBarHeight.constant = TransferRecordOptionBarViewController.preferedHeight
            self.optionBar.view.isHidden = false
            self.viewModel.switchInfoProvider(self.optionBar.viewModel)
            self.view.layoutIfNeeded()
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
    
    private func toRecordUrl(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
