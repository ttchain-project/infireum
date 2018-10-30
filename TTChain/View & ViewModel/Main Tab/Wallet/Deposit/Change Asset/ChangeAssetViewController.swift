//
//  ChangeAssetViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/25.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangeAssetViewController: KLModuleViewController, KLVMVC {

    struct Config {
        let wallet: Wallet
        let selectedCoin: Coin
    }
    
    typealias Constructor = Config
    typealias ViewModel = ChangeAssetViewModel
    var viewModel: ChangeAssetViewModel!
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private let assetSelect: PublishRelay<Asset> = PublishRelay.init()
    lazy var onAssetSelect: Driver<Asset> = {
        return assetSelect.asDriver(onErrorRecover: { _ in fatalError() })
    }()
    
    
    private let cancel: PublishRelay<Void> = PublishRelay.init()
    lazy var onCancel: Driver<Void> = {
        return cancel.asDriver(onErrorJustReturn: ())
    }()
    
    func config(constructor: ChangeAssetViewController.Config) {
        view.layoutIfNeeded()
        view.cornerRadius = 5
        
        configTableView()
        
        
        viewModel = ViewModel.init(
            input: ChangeAssetViewModel.InputSource(
                wallet: constructor.wallet,
                selectedCoin: constructor.selectedCoin,
                selectRowInput: tableView.rx.itemSelected.asDriver().map { $0.row }
        ),
            output: ChangeAssetViewModel.OutputSource(
                handleAssetSelect: { [unowned self] (asset) in
                    self.onSelectAsset(asset: asset)
            })
        )
        
        bindTableView()
        
        cancelBtn.rx.tap.asObservable().bind(to: cancel).disposed(by: bag)
        
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func configTableView() {
        tableView.register(ChangeAssetTableViewCell.nib, forCellReuseIdentifier: ChangeAssetTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func bindTableView() {
        viewModel.assets.bind(to: tableView.rx.items(cellIdentifier: ChangeAssetTableViewCell.cellIdentifier(), cellType: ChangeAssetTableViewCell.self)) {
            [unowned self]
            row, asset, cell in
            let s = self.viewModel.amtSource(of: asset)
            cell.config(
                asset: asset,
                amtSource: s.asObservable(),
                isSelected: self.viewModel.isCoinSelected(asset.coin!)
            )
        }
        .disposed(by: bag)
    }
    
    private func onSelectAsset(asset: Asset) {
        tableView.reloadData()
        assetSelect.accept(asset)
    }
    
    override func renderLang(_ lang: Lang) {
        cancelBtn.setTitle(nil, for: .normal)
        titleLabel.text = lang.dls.changeAsset_title
    }
    
    override func renderTheme(_ theme: Theme) {
        titleLabel.set(textColor: theme.palette.nav_item_1, font: .owRegular(size: 18))
        cancelBtn.set(color: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "btnAlertCancelNormal"))
        view.backgroundColor = theme.palette.bgView_sub
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
