//
//  AddWalletViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/1.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddWalletViewController: KLModuleViewController, KLVMVC {
    
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Void
    typealias ViewModel = AddWalletViewModel
    var viewModel: AddWalletViewModel!
    
    var hud = KLHUD.init(
        type: .spinner,
        frame: CGRect.init(
            origin: .zero,
            size: CGSize.init( width: 100,height: 100)))
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        self.viewModel = AddWalletViewModel.init(input: (), output: ())
        self.setupTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func renderTheme(_ theme: Theme) {
       
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)

    }
    
    override func renderLang(_ lang: Lang) {
        self.title = lang.dls.create_new_wallet
    }
    func setupTableView() {
        self.tableView.register(nibWithCellClass: ExportWalletSettingsTableViewCell.self)
        self.tableView.register(nib: AddWalletSectionHeaderView.nib, withHeaderFooterViewClass: AddWalletSectionHeaderView.self)
        self.tableView.delegate = self
        self.viewModel.animatableSectionModel.bind(to: self.tableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: bag)
        
        self.tableView.rx.itemSelected.asDriver().drive(onNext: { (indexPath) in
            let model = self.viewModel.animatableSectionModel.value[indexPath.section]
            switch (model.model.action,model.items[indexPath.row].walletType) {
                case (.create,let chainType):
                self.createWallet(forChainType: chainType)
                case (.import,.btc):
                self.toImportWallet(withMainCoinID: Coin.btc_identifier)
                case (.import,.eth):
                self.toImportWallet(withMainCoinID: Coin.eth_identifier)
            default:
                break
            }
        }).disposed(by: bag)
    }
    
}

extension AddWalletViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddWalletSectionHeaderView.nameOfClass) as! AddWalletSectionHeaderView
        let sectionModel = self.viewModel.animatableSectionModel.value[section]
        headerView.rx.klrx_tap.drive(onNext: { _ in
            self.viewModel.updateSection(section: section)
        }).disposed(by: headerView.bag)
        headerView.config(section: sectionModel.model)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}

extension AddWalletViewController {
    fileprivate func createWallet(forChainType chain:ChainType) {
        
        let predForWallet = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: chain.rawValue))
        guard let wallets = DB.instance.get(type: Wallet.self, predicate: predForWallet, sorts: nil) else {
            return
        }
        guard let wallet = wallets.filter ({ $0.isFromSystem }).first else {
            return
        }
        
        askUserInputPwdBeforeBackup(withHint: wallet.pwdHint)
            .subscribe(onSuccess: { [unowned self] (pwd) in
                let dls = LM.dls
                if wallet.isWalletPwd(rawPwd: pwd) {
                    guard let mnemonic = wallet.attemptDecryptMnemonic(withRawPwd: pwd) else {
                        self.showSimplePopUp(
                            with: dls.myIdentity_error_unable_to_decrypt_mnemonic,
                            contents: "",
                            cancelTitle: dls.g_confirm,
                            cancelHandler: nil
                        )
                        
                        return errorDebug(response: ())
                    }
                    self.startWalletCreation(forChain: chain, mnemonic: mnemonic, pwd: pwd, pwdHint: wallet.pwdHint!)
                }else {
                    self.showSimplePopUp(
                        with: "",
                        contents: dls.myIdentity_error_pwd_is_wrong,
                        cancelTitle: dls.g_cancel,
                        cancelHandler: nil
                    )
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func askUserInputPwdBeforeBackup(withHint hint: String?) -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.create_new_wallet,
                message: dls.myIdentity_alert_input_pwd_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .default) {
                                                (_) in
                                                if let pwd = textField.text, pwd.count > 0 {
                                                    handler(.success(pwd))
                                                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:(hint != nil) ? dls.qrCodeImport_alert_placeholder_pwd(hint!) : dls.myIdentity_placeholder_pwd)
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    func startWalletCreation(forChain chain: ChainType, mnemonic:String, pwd:String, pwdHint:String) {
        self.hud = KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init( width: 100,height: 100)))
        
        self.hud.startAnimating(inView: self.view)
        
        WalletCreator.createNewWallet(forChain: chain, mnemonic: mnemonic, pwd: pwd, pwdHint: pwdHint, isSystemWallet:false)
            .subscribe(onSuccess: { [unowned self] (status) in
                self.hud.stopAnimating()
                OWRxNotificationCenter.instance.notifyWalletsImported()
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: bag)
    }
    
    fileprivate func toImportWallet(withMainCoinID mainCoinID: String) {
        let vc = ImportWalletViaPrivateKeyViewController.instance(from: ImportWalletViaPrivateKeyViewController.Config(mainCoinID: mainCoinID, defaultPKey: nil))
        navigationController?.pushViewController(vc)
    }
}
