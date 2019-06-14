//
//  WalletsViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletsViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = WalletsViewModel
    
    func config(constructor: Config) {
        self.view.layoutIfNeeded()
        self.configTableView()
        self.viewModel = WalletsViewModel.init(input: WalletsViewModel.Input(coins: constructor.coins), output: WalletsViewModel.Output())
        self.viewModel.sectionModelSources.bind(to: self.tableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: bag)
        self.configHeaderView()
        self.monitorLocalWalletsUpdate()
        self.observePrivateModeUpdateEvent()
        bindAssetUpdate()
    }
    
    var bag: DisposeBag = DisposeBag()
    var viewModel:ViewModel!
    
    var headerViewController:WalletHeaderViewController!
    typealias Constructor = Config

    struct Config {
        var coins:[Coin]
    }
    
    private func configTableView() {
        self.tableView.rx.setDelegate(self).disposed(by: bag)
        tableView.register(WalletsTableSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: WalletsTableSectionHeaderView.nameOfClass)
        self.tableView.register(cellType: WalletsTableViewCell.self)
        self.tableView.separatorStyle = .none
        self.tableView.rx.modelSelected(Asset.self).subscribe(onNext: { [weak self] (asset) in
            guard let `self` = self else {
                return
            }
            let vc = AssetDetailViewController.navInstance(
                from: AssetDetailViewController.Config(asset: asset, purpose: AssetDetailViewController.Purpose.mainWallet)
            )
            self.present(vc, animated: true, completion: nil)
            
        }).disposed(by: bag)
    }

    func configHeaderView() {
        let totalFiatValues = self.viewModel.totalFiatValues.asObservable()
        headerViewController = WalletHeaderViewController.instance(from: WalletHeaderViewController.Config(totalAssetFiatValue: totalFiatValues,
                                                                                             fiatCurrency: self.viewModel.fiat.asObservable(), manageAsset: ({
                                                                                                
                                                                                             })))
        
        headerViewController.view.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: self.view.height * 0.4)
        self.tableView.tableHeaderView = headerViewController.view
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    private func monitorLocalWalletsUpdate() {
        let imported = OWRxNotificationCenter.instance.walletsImported
            .map { _ in () }
        let singleWalletImported = OWRxNotificationCenter.instance.walletImported
            .map { _ in () }
        let deleted = OWRxNotificationCenter.instance.walletDeleted
            .map { _ in () }
        let walletNameChange = OWRxNotificationCenter.instance.walletNameUpdate
            .map { _ in () }
        
        Observable.merge(imported, deleted, singleWalletImported, walletNameChange)
            .subscribe(onNext: {
                [weak self]
                _ in
                self?.viewModel.prepareSectionModels()
                self?.viewModel.refreshAllData()
            })
            .disposed(by: bag)
    }
    
    private func observePrivateModeUpdateEvent() {
        OWRxNotificationCenter
            .instance
            .onChangePrivateMode
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
    private func bindAssetUpdate() {
        viewModel.onAssetFinishUpdateFromTransfer
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self]
                _ in
                
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
}

extension WalletsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletsTableSectionHeaderView.nameOfClass) as! WalletsTableSectionHeaderView
        let sectionModel = self.viewModel.sectionModelSources.value[section]
        headerView.expandButton.rx.klrx_tap.drive(onNext: { _ in
            self.viewModel.updateSectionModel(forSection: section)
            headerView.expandButton.isSelected = !headerView.expandButton.isSelected
        }).disposed(by: headerView.bag)
        let amtSource = self.viewModel.totalAssetAmtForCoin(coin: sectionModel.header)
        let fiatValSrc = self.viewModel.totalFiatAmoutForCoin(coin: sectionModel.header)
        headerView.config(sectionModel:sectionModel,amtSource:amtSource,fiatValSrc:fiatValSrc)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
