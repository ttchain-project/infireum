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
import Cartography

final class WalletsViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = WalletsViewModel
   
    
    func config(constructor: Config) {
        self.view.layoutIfNeeded()
        self.configTableView()
        self.viewModel = WalletsViewModel.init(input: WalletsViewModel.Input(coins: constructor.coins, isReloadCoins: self.isReloadCoins),
                                               output: WalletsViewModel.Output())
        self.viewModel.sectionModelSources.bind(to: self.tableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: bag)
        self.configHeaderView()
        self.monitorLocalWalletsUpdate()
        self.observePrivateModeUpdateEvent()
        bindAssetUpdate()
        
       
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { _ in
                self.viewModel.input.isReloadCoins.accept(true)
                refreshControl.endRefreshing()
            })
            .disposed(by: bag)

        
       self.tableView.addSubview(refreshControl)
        
             
    }
      
    var bag: DisposeBag = DisposeBag()
    var viewModel:ViewModel!
    var isReloadCoins: BehaviorRelay<Bool> = BehaviorRelay<Bool>.init(value: false)
    var headerViewController:WalletHeaderViewController!
    typealias Constructor = Config

    struct Config {
        var coins:[Coin]
    }
    
    func toWalletDetail(asset:Asset) {
   
         switch (asset.coin!.owChainType) {
         case (.btc):
             let vc = AssetDetailViewController.navInstance(
                 from: AssetDetailViewController.Config(asset: asset, purpose: AssetDetailViewController.Purpose.mainWallet)
             )
             vc.modalPresentationStyle = .fullScreen
             present(vc, animated: true, completion: nil)
         case (.eth):
             let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: asset.wallet!, source:MainWalletViewController.Source.ETH))
             vc.modalPresentationStyle = .fullScreen
             self.present(vc, animated: true, completion: nil)
         case (.ifrc):
             let viewModel = LightTransDetailViewModel.init(withAsset: asset)
             let vc = LightTransDetailViewController.init(withViewModel: viewModel)
             let navController = UINavigationController.init(rootViewController: vc)
             navController.modalPresentationStyle = .fullScreen
             self.present(navController, animated: true, completion: nil)
         
         default:
             break
         }
         
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
            self.toWalletDetail(asset: asset)
            
        }).disposed(by: bag)
    }

    func configHeaderView() {
        let totalFiatValues = self.viewModel.totalFiatValues.asObservable()
        headerViewController = WalletHeaderViewController.instance(from: WalletHeaderViewController.Config(totalAssetFiatValue: totalFiatValues,
                                                                                                           fiatCurrency: self.viewModel.fiat.asObservable(), manageAsset: ({
                                                                                                           })))
        let base = UIView.init()
        base.backgroundColor = .clear
        let height = max(250,self.view.height * 0.4)
        base.addSubview(headerViewController.view)
        base.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: height)
        constrain(headerViewController.view) { (view) in
            let sup = view.superview!
            view.edges == sup.edges
        }
        tableView.tableHeaderView = base
        
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
    private func observeReloadWalletsBalance() {
        OWRxNotificationCenter
            .instance
            .reloadWalletsBalance
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] _ in
                self.viewModel.refreshAllData()
            })
            .disposed(by: bag)
    }
    
    
}

extension WalletsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletsTableSectionHeaderView.nameOfClass) as! WalletsTableSectionHeaderView
        let sectionModel = self.viewModel.sectionModelSources.value[section]

        Observable.of(headerView.rx.klrx_tap, headerView.expandButton.rx.klrx_tap)
            .merge()
            .subscribe(onNext: { _ in
                self.viewModel.updateSectionModel(forSection: section)
                headerView.expandButton.isSelected = !headerView.expandButton.isSelected
            })
            .disposed(by: headerView.bag)
            
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
