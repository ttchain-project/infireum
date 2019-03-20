//
//  ChangeWalletViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/30.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChangeWalletViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        /// If this asset is provided, only wallets has this asset would be able to selected.
        let assetSupportLimit: Asset?
        let currentSelectedAsset:Asset?
    }
    
    typealias ViewModel = ChangeWalletViewModel
    typealias Constructor = Config
    
    var viewModel: ChangeWalletViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.rx.tap.asDriver().drive(onNext: {
                self.dismiss(animated: true, completion: nil)
            }).disposed(by:bag)
        }
        
    }
    //    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var onWalletSelect: Observable<Wallet> {
        return viewModel.onWalletSelect
    }
    
    var onAssetSelected:Observable<Asset> {
        return viewModel.onAssetSelected

    }
    private var selectedAsset:Asset?
    
    func config(constructor: Config) {
        view.layoutIfNeeded()
        self.selectedAsset = constructor.currentSelectedAsset!

        configTableView()
        
        viewModel = ViewModel.init(
            input: ChangeWalletViewModel.InputSource(
                assetSupportLimit: constructor.assetSupportLimit,
                walletSelectIdxPathInput: tableView.rx.itemSelected.asDriver()
            ),
            output: ()
        )
        
//        viewModel.datasource.configureCell = {
//            [unowned self]
//            source, tv, idxPath, wallet -> UITableViewCell in
//            //TODO: Config cell with wallet
//            let cell = tv.dequeueReusableCell(withIdentifier: ChangeWalletTableViewCell.cellIdentifier()) as! ChangeWalletTableViewCell
//            cell.config(
//                wallet: wallet,
//                onAddrTap: {
//                    [unowned self] in
//                    self.copiedAddr(ofWallet: wallet)
//                },
//                onSettingsTap: {
//                    [unowned self] in
//                    self.toSettings(withWallet: wallet)
//                },
//               isNetworkReachable: NetworkReachabilityHandler.instance.reachable.value.hasNetwork,
//               isAbleToSelect: self.viewModel.isAbleToSelectWallet(wallet)
//            )
//
//            return cell
//        }
//
//        viewModel
//            .sectionModelSources
//            .bind(to: tableView.rx.items(
//                dataSource: viewModel.datasource)
//            )
//            .disposed(by: bag)
        
        self.viewModel.assets.bind(to:self.tableView.rx.items) {
            tv,row,asset in
            var cell: SelectWalletTableViewCell
            cell = tv.dequeueReusableCell(withIdentifier: SelectWalletTableViewCell.cellIdentifier()) as! SelectWalletTableViewCell
            cell.setData(walletName: asset.wallet!.name!, coinName: asset.coin!.inAppName!, walletAmount: asset.amount!.decimalValue.asString(digits: 4), isSelected: asset.walletEPKey == self.selectedAsset!.walletEPKey)
            
                    cell.contentView.alpha = self.viewModel.isAbleToSelectWallet(withAsset: asset) ? 1 : 0.4
            
            return cell
        }.disposed(by: bag)
        
        setupUI()
        bindUI()
        
        startMonitorThemeIfNeeded()
        startMonitorNetworkStatusIfNeeded()
        observeWalletUpdateFromNotificationCenter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configTableView() {
        tableView.delegate = self
//        tableView.register(SystemWalletTableHeaderView.nib, forHeaderFooterViewReuseIdentifier: SystemWalletTableHeaderView.nameOfClass)
//        tableView.register(ImportedWalletTableHeaderView.nib, forHeaderFooterViewReuseIdentifier: ImportedWalletTableHeaderView.nameOfClass)
        tableView.register(SelectWalletTableViewCell.nib, forCellReuseIdentifier: SelectWalletTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func setupUI() {
//        dismissBtn.rx.enableCircleSided().disposed(by: bag)
    }
    
    private func bindUI() {
//        dismissBtn.rx.tap.asDriver()
//            .drive(onNext: {
//                [unowned self] in self.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: bag)
    }
    
//    override func renderLang(_ lang: Lang) {
//
//    }
    
    override func renderTheme(_ theme: Theme) {
//        dismissBtn.setPureImage(
//            color: theme.palette.btn_borderFill_enable_text,
//            image: #imageLiteral(resourceName: "imgNavHopeseedlogo"),
//            borderInfo: (color: theme.palette.specific(color: .owMarineBlue), width: 1)
//        )
    }
    
    private func observeWalletUpdateFromNotificationCenter() {
        OWRxNotificationCenter.instance.walletNameUpdate.subscribe(onNext: {
            [unowned self]
            _ in
            self.tableView.reloadData()
        })
        .disposed(by: bag)
        
        OWRxNotificationCenter.instance.walletImported.subscribe(onNext: {
            [unowned self] _ in
            self.viewModel.refreshWallets()
        })
        .disposed(by: bag)
    }
    
    override func handleNetworkStatusChange(_ status: NetworkStatus) {
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Some Simple Helpers
    private func copiedAddr(ofWallet wallet: Wallet) {
        UIPasteboard.general.string = wallet.address
        EZToast.present(on: self, content: LM.dls.g_toast_addr_copied)
    }
    
    private func toSettings(withWallet wallet: Wallet) {
        let vc = ManageWalletViewController.navInstance(from: ManageWalletViewController.Config(wallet: wallet))
        present(vc, animated: true, completion: nil)
    }

    private func toImportWallet() {
        
        if (self.viewModel.systemWallets.value.count + self.viewModel.importedWallets.value.count) >= C.Wallet.min_wallet{
            self.showSimplePopUp(with: "", contents: LM.dls.changeWallet_alert_import_fail, cancelTitle: LM.dls.g_confirm, cancelHandler: nil)
            return
        }
        
        let vc = xib(vc: ImportWalletTypeChooseViewController.self)
        let nav = UINavigationController.init(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}

extension ChangeWalletViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.001
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == viewModel.systemWalletSection {
//            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SystemWalletTableHeaderView.nameOfClass) as! SystemWalletTableHeaderView
//
//            return view
//        }else if section == viewModel.importedWalletSection {
//            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ImportedWalletTableHeaderView.nameOfClass) as! ImportedWalletTableHeaderView
//
//            view.config(onCreate: {
//                [unowned self] in
//                self.toImportWallet()
//            })
//
//            return view
//        }else {
//            return nil
//        }
//    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
}

