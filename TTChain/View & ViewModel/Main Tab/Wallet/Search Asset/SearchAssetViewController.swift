//
//  SearchAssetViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/28.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchAssetViewController: KLModuleViewController, UISearchResultsUpdating, KLVMVC {
    
    struct Setup {
        let wallet: Wallet
    }
    
    typealias Constructor = Setup
    
    typealias ViewModel = SearchAssetViewModel
    var viewModel: SearchAssetViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    //MARK: - Outlet
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func config(constructor: SearchAssetViewController.Setup) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: ViewModel.Input(wallet: constructor.wallet), output: ())
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        
        setupTableView()
        bindTableView()
    }
    
    private func setupTableView() {
        tableView.register(SearchAssetTableViewCell.nib, forCellReuseIdentifier: SearchAssetTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func bindTableView() {
        viewModel.results.bind(to: tableView.rx.items(cellIdentifier: SearchAssetTableViewCell.cellIdentifier(), cellType: SearchAssetTableViewCell.self)) {
            [unowned self]
            row, result, cell in
            
            let sel = result.selection
            let isInSelection = sel != nil
            let isRemovable: Bool = sel == nil ? true : sel!.coin!.isDeletable
//            print("Config Coin is \(result.type.name), for row: \(row)")
            cell.config(
                source: result,
                isInSelection: isInSelection,
                isRemovable: isRemovable,
                onChangeInSelectionOrNot: {
                    [unowned self] (isInSelection) in
//                    print("action Coin is \(result.type.name)")
                    guard self.viewModel.changeCoinInSelectionDatabase(coinIdx: row, isInSelection: isInSelection) else {
                        return errorDebug(response: ())
                    }
                    
                    self.tableView.reloadData()
                }
            )
        }
        .disposed(by: bag)
        
        let noResult = viewModel.results.map { $0.count == 0 }
        
        noResult.bind(to: tableView.rx.isHidden).disposed(by: bag)
        noResult.bind(to: headerLabel.rx.isHidden).disposed(by: bag)
        noResult.map { $0 ? TM.palette.bgView_sub : TM.palette.bgView_main
            }.subscribe(onNext: { [unowned self] in self.view.backgroundColor = $0 }).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        headerLabel.text = dls.searchAsset_label_myAsset
        noContentLabel.text = dls.searchAsset_label_resultNotFound
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        headerLabel.set(textColor: palette.label_sub, font: .owRegular(size: 10))
        noContentLabel.set(textColor: palette.label_sub, font: .owRegular(size: 11))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.update(searchString: searchController.searchBar.text)
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
