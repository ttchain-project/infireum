//
//  ImportSuccessViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/8/27.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ImportSuccessViewController: KLModuleViewController, KLVMVC {
    var viewModel: ImportSuccessViewModel!
    
    func config(constructor: ImportSuccessViewController.Config) {
        self.view.layoutIfNeeded()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        Observable.of(constructor.wallets).bind(to: tableView.rx.items) {
            tv,row,wallet in
            let cell: ImportedWalletsTableViewCell = tv.dequeueReusableCell(withClass: ImportedWalletsTableViewCell.self)
            cell.walletName.text = wallet.name
            cell.walletAddress.text = wallet.address
            return cell
        }.disposed(by: bag)
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    typealias ViewModel = ImportSuccessViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    struct Config {
        let wallets:[Wallet]
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(nibWithCellClass: ImportedWalletsTableViewCell.self)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletsListView: UIView! {
        didSet {
            walletsListView.isHidden = true
        }
    }
    @IBOutlet weak var importSuccessView: UIView!
    @IBOutlet weak var loginSuccessLabel: UILabel!
    @IBOutlet weak var welcomLabel: UILabel!
    
    @IBOutlet weak var viewImportedWalletsButton: UIButton! {
        didSet {
            viewImportedWalletsButton.rx.klrx_tap.drive(onNext: {
                self.walletsListView.isHidden = false
                self.importSuccessView.isHidden = true
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.rx.klrx_tap.drive(onNext: {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showMainTab()
            }).disposed(by: bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func renderLang(_ lang: Lang) {
        doneButton.setTitleForAllStates(lang.dls.g_confirm)
        titleLabel.text = lang.dls.imported_wallets
        loginSuccessLabel.text = lang.dls.login_success
        welcomLabel.text = lang.dls.welcome_back
    }
    override func renderTheme(_ theme: Theme) {
        loginSuccessLabel.font = UIFont.owRegular(size:16)
        welcomLabel.font = UIFont.owRegular(size:13)
        titleLabel.font = UIFont.owRegular(size:16)
    }
}

