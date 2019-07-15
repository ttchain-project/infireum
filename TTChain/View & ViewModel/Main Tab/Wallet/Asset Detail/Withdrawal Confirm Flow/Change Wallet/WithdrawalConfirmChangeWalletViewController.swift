//
//  WithdrawalConfirmChangeWalletViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/9.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalConfirmChangeWalletViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Config {
        let info: WithdrawalInfo
    }
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalConfirmChangeWalletViewModel
    var viewModel: WithdrawalConfirmChangeWalletViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    public var selectNotifier: Observable<Asset> {
        return viewModel.selectedAsset.distinctUntilChanged().skip(1)
    }
    
    func config(constructor: WithdrawalConfirmChangeWalletViewController.Config) {
        view.layoutIfNeeded()
        setupTableView()
        viewModel = ViewModel.init(
            input: WithdrawalConfirmChangeWalletViewModel.InputSource(
                rowSelect: tableView.rx.itemSelected.asDriver().map { $0.row },
                info: constructor.info
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func setupTableView() {
        tableView.register(
            WithdrawalConfirmChangeWalletTableViewCell.nib,
            forCellReuseIdentifier: WithdrawalConfirmChangeWalletTableViewCell.cellIdentifier()
        )
        
        tableView.separatorStyle = .none
    }
    
    private func bindViewModel() {
        viewModel.assets.bind(to: tableView.rx.items(cellIdentifier: WithdrawalConfirmChangeWalletTableViewCell.cellIdentifier(), cellType: WithdrawalConfirmChangeWalletTableViewCell.self)) {
            [unowned self]
            row, asset, cell in
            let isUsable = self.viewModel.isAssetUsable(asset)
            let isSelected = self.viewModel.isAssetSelected(asset)
            cell.config(asset: asset, isUsable: isUsable, isSelected: isSelected)
        }
        .disposed(by: bag)
        
        viewModel.selectedAsset.distinctUntilChanged().subscribe(onNext: {
            [unowned self] _ in self.tableView.reloadData()
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
    
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.withdrawalConfirm_changeWallet_title
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        
        view.backgroundColor = palette.bgView_sub
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
