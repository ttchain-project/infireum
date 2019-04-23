//
//  LightTransMenuViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightTransMenuViewController: KLModuleViewController,KLVMVC {
  
    var viewModel: LightTransViewModel!
    
    func config(constructor: LightTransMenuViewController.Config) {
        self.viewModel = LightTransViewModel.init(input: LightTransViewModel.Input(),output: LightTransViewModel.Output())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
    }
    
    typealias ViewModel = LightTransViewModel
    var bag: DisposeBag = DisposeBag.init()
    typealias Constructor = Config
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Config {
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.lightning_payment_title
    }
    
    override func renderTheme(_ theme: Theme) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor(color1: UIColor.init(red: 44, green: 60, blue: 78)?.cgColor, color2: UIColor.init(red: 24, green: 34, blue: 39)?.cgColor)
    }
    
    func bindUI(){
        self.viewModel.assets.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: LightTransMenuTableViewCell.className, cellType: LightTransMenuTableViewCell.self)) {[weak self]
            row, asset, cell in
            guard let `self` = self else {
                return
            }
            cell.config(asset: asset,transferAction: { asset in self.showTransferAction(asset: asset)}, depositAction: {asset in self.showDepositAction(asset: asset)})
            }.disposed(by:bag)
        
        self.tableView.rx.itemSelected.asDriver().drive(onNext: { (path) in
            if self.viewModel.assets.value.indices.contains(path.row) {
                self.showLightDetail(asset: self.viewModel.assets.value[path.row])
            }
        }).disposed(by: bag)
    }
    
    func showTransferAction(asset:Asset) {
        let nav = WithdrawalBaseViewController.navInstance(from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: nil,defaultAmount:nil))
        present(nav, animated: true, completion: nil)

    }
    func showDepositAction(asset:Asset) {
        let vc = DepositViewController.navInstance(from: DepositViewController.Setup(wallet: asset.wallet!, asset: asset))
        present(vc, animated: true, completion: nil)
    }
    
    func showLightDetail(asset:Asset) {
        let viewModel = LightTransDetailViewModel.init(withAsset: asset)
        let vc = LightTransDetailViewController.init(withViewModel: viewModel)
        present(vc, animated: true, completion: nil)
    }
}
