//
//  ManageAssetViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/26.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ManageAssetViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let wallet: Wallet
        let updateNotifier: ([Asset]) -> Void
        let source: MainWalletViewController.Source
    }
    
    typealias Constructor = Config
    
    var bag: DisposeBag = DisposeBag.init()
    typealias ViewModel = ManageAssetViewModel
    var viewModel: ManageAssetViewModel!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var manageBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(doManage), image: nil, title: nil, toColor: .black, shouldClear: true, size: CGSize.init(width: 50, height: 44))
    }()
    
    fileprivate lazy var searchController: UISearchController = {
        return UISearchController.init(searchResultsController: searchResultVC)
    }()
    
    fileprivate lazy var searchResultVC: SearchAssetViewController = {
        return SearchAssetViewController.instance(from: SearchAssetViewController.Setup(wallet: viewModel.input.wallet))
    }()
    
    fileprivate var notifier: (([Asset]) -> Void)?
    
    func config(constructor: ManageAssetViewController.Config) {
        notifier = constructor.updateNotifier
        
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: ManageAssetViewModel.InputSource(wallet: constructor.wallet,source:constructor.source),
            output: ()
        )
        
        setupSearchBar()
        setupTable()
        
        startMonitorNetworkStatusIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        
        //This is the key point to keep search bar visible while search results vc is presented.
        definesPresentationContext = true
    }
    
    deinit {
        notifier?(viewModel.parseSelectedSelectionsToAsset())
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
        searchController.searchBar.placeholder = dls.manageAsset_searchBar_search_token_and_contract
        manageBtn.setTitleForAllStates(dls.manageAsset_btn_manage)
        headerLabel.text = dls.manageAsset_label_myAsset
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_1, barTint: theme.palette.nav_bg_1)
        changeLeftBarButtonToDismissToRoot(
            tintColor: theme.palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack")
        )
        
        changeNavShadowVisibility(false)
        
        manageBtn.set(textColor: theme.palette.nav_item_1,
                      font: UIFont.owRegular(size: 16))
        
        headerLabel.set(textColor: theme.palette.label_sub,
                        font: .owRegular(size: 10))
    }
    
    private func setupSearchBar() {
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchResultsUpdater = searchResultVC
        navigationItem.searchController = searchController
    }
    
    private func setupTable() {
        tableView.register(ManageAssetTableViewCell.nib, forCellReuseIdentifier: ManageAssetTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.coinSels.asObservable().subscribe(onNext: {
            [unowned self] _ in self.tableView.reloadData()
        })
        .disposed(by: bag)
    }
    
    
    @objc private func doManage() {
        showManageActionSheet()
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

extension ManageAssetViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.refreshDataSource()
    }
}

// MARK: - Manage Action Sheet
extension ManageAssetViewController {
    func showManageActionSheet() {
        let dls = LM.dls
        let cancel = UIAlertAction.init(title: dls.g_cancel, style: .cancel, handler: nil)
        let hideEmptyAsset = UIAlertAction.init(
            title: dls.manageAsset_actoinSheet_hideEmptyAsset,
            style: .default) { [unowned self] (_) in
            self.viewModel.hideEmptyAmtSelections()
            self.tableView.reloadData()
        }
        
        let remainAmtSortStr: String
        let alphabetSortStr: String
        
        let sortType = AssetSortingManager.getSortOption()
        switch sortType {
        case .alphabetic:
            remainAmtSortStr = dls.manageAsset_actoinSheet_sortByAssetAmt
            alphabetSortStr = dls.manageAsset_actoinSheet_sortAlphabatically_cancel
        case .assetAmt:
            remainAmtSortStr = dls.manageAsset_actoinSheet_sortByAssetAmt_cancel
            alphabetSortStr = dls.manageAsset_actoinSheet_sortAlphabatically
        case .none:
            remainAmtSortStr = dls.manageAsset_actoinSheet_sortByAssetAmt
            alphabetSortStr = dls.manageAsset_actoinSheet_sortAlphabatically
        }
        
        let remainAmtSort = UIAlertAction.init(title: remainAmtSortStr, style: .default) {
            [unowned self]
            (_) in
            let newSortType: AssetSortingManager.Sort
            if sortType == .assetAmt {
                newSortType = .none
            }else {
                newSortType = .assetAmt
            }
            
            AssetSortingManager.setSorting(newSortType)
            self.viewModel.updateSortingType(sort: newSortType)
        }
        
        
        let alphabetSort = UIAlertAction.init(title: alphabetSortStr, style: .default) {
            [unowned self]
            (_) in
            let newSortType: AssetSortingManager.Sort
            if sortType == .alphabetic {
                newSortType = .none
            }else {
                newSortType = .alphabetic
            }
            
            AssetSortingManager.setSorting(newSortType)
            self.viewModel.updateSortingType(sort: newSortType)
        }
        
        let delete = UIAlertAction.init(title: dls.manageAsset_actoinSheet_removeAsset,
                                        style: .destructive) {
            [unowned self] (_) in
            self.switchToEditingMode(isEditing: true)
        }
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(cancel)
        alert.addAction(hideEmptyAsset)
        alert.addAction(remainAmtSort)
        alert.addAction(alphabetSort)
        alert.addAction(delete)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func switchToEditingMode(isEditing: Bool) {
        tableView.setEditing(isEditing, animated: true)
        let palette = TM.instance.theme.value.palette
        let dls = LM.dls
        if isEditing {
            let btn = createRightBarButton(
                target: self,
                selector: #selector(completeEditing),
                image: nil,
                title: dls.g_done,
                toColor: palette.nav_item_1,
                shouldClear: true,
                size: CGSize.init(width: 50, height: 44)
            )
            
            btn.set(color: palette.nav_item_1, font: UIFont.owRegular(size: 16))
        }else {
            let btn = createRightBarButton(
                target: self,
                selector: #selector(doManage),
                image: nil,
                title: dls.manageAsset_btn_manage,
                toColor: .black,
                shouldClear: true,
                size: CGSize.init(width: 50, height: 44)
            )
            
            btn.set(color: palette.nav_item_1, font: UIFont.owRegular(size: 16))
            manageBtn = btn
        }
    }
    
    @objc fileprivate func completeEditing() {
        switchToEditingMode(isEditing: false)
    }
}

//MARK: - UITableViewDelegate
extension ManageAssetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let sel = viewModel.coinSels.value[indexPath.row]
        if sel.coin!.isDeletable {
            return .delete
        }else {
            return .none
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coinSels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ManageAssetTableViewCell.cellIdentifier()) as! ManageAssetTableViewCell
        let sel = viewModel.coinSels.value[indexPath.row]
        cell.config(sel: sel, onChangeSel: { [unowned self] (isSelected) in
            self.viewModel.updateSelectState(of: sel, isSelected: isSelected)
            self.tableView.reloadData()
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let sel = viewModel.coinSels.value[indexPath.row]
        return sel.coin!.isDeletable
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard viewModel.deleteCoinSel(idxRow: indexPath.row) else { return }
//        tableView.deleteRows(at: [indexPath], wit.h: .fade)
    }
}
