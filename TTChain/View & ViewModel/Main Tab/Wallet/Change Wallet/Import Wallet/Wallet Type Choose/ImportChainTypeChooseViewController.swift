//
//  ImportChainTypeChooseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/5.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ImportChainTypeChooseViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var walletIcon: UIImageView!
    @IBOutlet weak var chainTypeTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    typealias Constructor = Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias ViewModel = ImportChainTypeChooseViewModel
    var viewModel: ImportChainTypeChooseViewModel!
    
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        setupTableView()
        
        viewModel = ViewModel.init(
            input: ImportChainTypeChooseViewModel.InputSource(
                typeRowSelectInput: tableView.rx.itemSelected.asDriver().map { $0.row }
            ),
            output: ()
        )
        
        bindTableView()
        bindViewModel()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(
            ImportChainTypeChooseTableViewCell.nib,
            forCellReuseIdentifier: ImportChainTypeChooseTableViewCell.cellIdentifier()
        )
    }
    
    private func bindTableView() {
        viewModel.mainCoins
            .bind(to: tableView.rx.items(
                cellIdentifier: ImportChainTypeChooseTableViewCell.cellIdentifier(),
                cellType: ImportChainTypeChooseTableViewCell.self)
            ) {
                row, coin, cell in
                cell.config(mainCoin: coin)
            }
            .disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.onSelectMainCoin.drive(onNext: {
            [unowned self] in self.toImportWallet(withMainCoinID: $0.walletMainCoinID!)
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
        chainTypeTitleLabel.text = dls.importWallet_typeChoose_title
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        
        title = nil
        changeBackBarButton(toColor: palette.nav_item_1,
                            image: #imageLiteral(resourceName: "arrowNavBlack"),
                            title: nil)
        
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        chainTypeTitleLabel.set(textColor: palette.label_main_1,
                                 font: .owMedium(size: 18))
    }
    
    //MARK: - Routing
    private func toImportWallet(withMainCoinID mainCoinID: String) {
        let vc = ImportWalletViaPrivateKeyViewController.instance(from: ImportWalletViaPrivateKeyViewController.Config(mainCoinID: mainCoinID, defaultPKey: nil))
        navigationController?.pushViewController(vc)
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
