//
//  SettingMenuViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI
import RxDataSources
import Cartography

final class SettingMenuViewController: KLModuleViewController, KLVMVC,MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    var viewModel: SettingMenuViewModel!
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: (), output: ())
        self.configTableView()
        self.bindTableView()
        self.setUpLangSelectView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    typealias ViewModel = SettingMenuViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Void

//    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView:UITableView!
    
    let pickerView: UIPickerView = UIPickerView.init()
    private let pickerResponder = UITextField.init()

//    private var settingTableHeader : SettingHeaderViewController = {return SettingHeaderViewController.instance()}()
    private lazy var hud: KLHUD = {
        return KLHUD.init(type: .spinner,
                          frame: CGRect.init(
                            origin: .zero,
                            size: CGSize.init(
                                width: 100,
                                height: 100
                            )
            )
        )
    }()
    
    private lazy var clearHUD: KLHUD = {
        let hud = KLHUD.init(
            type: KLHUD.HUDType.spinner,
            frame: CGRect.init(origin: .zero,
                               size: CGSize.init(width: 100, height: 100)),
            descText: LM.dls.myIdentity_hud_exiting
        )
        
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func configTableView() {
        tableView.register(cellType: SettingsTabTableViewCell.self)
        tableView.register(cellType: ExportWalletSettingsTableViewCell.self)
//        let base = UIView.init()
//        base.backgroundColor = .clear
//        base.addSubview(settingTableHeader.view)
//        base.frame = CGRect.init(origin: .zero, size: CGSize(width: self.tableView.width, height: 120))
//        constrain(settingTableHeader.view) { (view) in
//            let sup = view.superview!
//            view.edges == sup.edges
//        }
//        tableView.tableHeaderView = base
        
//        settingTableHeader.settingButton.rx.klrx_tap.drive(onNext:{ [weak self] in
//            let vc = ProfileViewController.instance(from: ProfileViewController.Constructor(purpose: ProfileViewController.Purpose.SettingProfile))
//            vc.hidesBottomBarWhenPushed = true
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: settingTableHeader.bag)
    }
    
    
    func bindTableView() {

        self.viewModel.settingsArray.bind(to: self.tableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by:bag)
        self.tableView.delegate = self
        tableView.rx.modelSelected(SettingType.self).subscribe(onNext: { (type) in
            switch type {
            case .Address:
                self.toAddressBook()
            case .BackupAccount:
                self.toBackupIdetityMnemonicView(of: nil)
            case .Currency:
                self.toFiatSelectView()
            case .Language:
                self.pickerResponder.becomeFirstResponder()
            case .DeleteAccount:
                self.clear()
            case .ExportBTCWallet:
                self.handleWalletExport(forChain: .btc)
            case .ExportETHWallet:
                self.handleWalletExport(forChain: .eth)
            case .Notification:
                self.notificationSetting()
            case .VersionCheck:
                self.startCheckVersion()
            }
        }).disposed(by: bag)
        
    }
    
    private func setUpLangSelectView() {
        pickerResponder.inputView = pickerView
        self.view.addSubview(pickerResponder)
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.tab_setting
        self.tableView.reloadData()
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        
        tableView.backgroundColor = palette.nav_bg_clear
        view.backgroundColor = palette.bgView_main
    }
    
    private func toFiatSelectView() {
        let vc = ChangePrefFiatViewController.instance(from: ChangePrefFiatViewController.Config(identity: Identity.singleton!))
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc)
    }
    
    private func toEditIdentity() {
        let nav = IdentityViewController.navInstance(from: IdentityViewController.Config(identity: Identity.singleton!))
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func toAddressBook() {
        let nav = AddressBookViewController.navInstance(from: AddressBookViewController.Config(identity: Identity.singleton!, purpose: .browse))
        
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func toAgreement(title:String, content:String) {
        let nav = AgreementMeViewController.navInstance(from: AgreementMeViewController.Config(identity: Identity.singleton!,text:content,title:title))
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func toQA() {
        let nav = QAViewController.navInstance(from: QAViewController.Config(identity: Identity.singleton!))
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func startCheckVersion() {
        let dls = LM.dls
        hud.updateType(.spinner, text: dls.me_hud_checking)
        hud.startAnimating(inView: self.view)
        VersionChecker.sharedInstance.getVersion()
            .subscribe(onSuccess: {
                [unowned self]
                result in
                self.hud.stopAnimating()
                switch result {
                case .failed(error: let err):
                    self.showAPIErrorResponsePopUp(from: err,
                                                   cancelTitle: dls.g_confirm)
                case .success(let versions):
                    self.showAlertOfLatestVersion(versions.latest)
                }
            })
            .disposed(by: bag)
    }
    
    private func showAlertOfLatestVersion(_ latestVersion: String) {
        let curVersion = C.Application.version
        let compareResult = VersionChecker.Helper.compare(version: curVersion, toAnotherVersion: latestVersion)
        let alertTitle: String
        let actionTitle: String
        let handler: () -> Void
        
        let dls = LM.dls
        switch compareResult {
        case .new, .same:
            alertTitle = dls.me_alert_already_latest_version_title
            actionTitle = dls.g_confirm
            handler = {}
        case .old:
            alertTitle = dls.me_alert_able_to_update_version_title
            actionTitle = dls.g_update
            handler = {
                let url = URL.init(string: C.Application.ipaUrlStr)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let message = String.init(
            format: dls.me_alert_version_content(curVersion, latestVersion)
        )
        
        let alert = UIAlertController.init(title: alertTitle,
                                           message: message,
                                           preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: actionTitle,
                                        style: .default,
                                        handler: { _ in handler() })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func clear() {
        //NOTE: As we need to check the pwd, but pwd is related to wallet.
        //      Since there's no pwd for identity now, must make sure that all
        //      the pwds are same, so we can guarantee that the system has no change
        //      pwd features yet.
       
        guard let identity = Identity.singleton, let wallets = identity.wallets?.array as? [Wallet] else {
            return
        }
        
        let systemWallets = wallets.filter { $0.isFromSystem }
        let pwdSet = Set.init(systemWallets.map { $0.ePwd! })
        let pwdHintSet = Set.init(systemWallets.map { $0.pwdHint! })
        
        //Pwd count check is in here, if the check failed,
        //system might add some new pwd change feature in it,
        //so the logic in here should be modified.
        guard pwdSet.count == 1 else { return errorDebug(response: ()) }
        guard pwdHintSet.count == 1 else { return errorDebug(response: ()) }
        let sampleWallet = systemWallets[0]
        
        
        showClearIdentityNoteAlert()
            .flatMap { [unowned self] _ -> Single<String> in
                self.askUserInputPwdBeforeClear(withHint: pwdHintSet.first)
            }
            .subscribe(onSuccess: {
                [unowned self] (pwd) in
                if sampleWallet.isWalletPwd(rawPwd: pwd) {
                    self.clearIdentity()
                }else {
                    let dls = LM.dls
                    self.showSimplePopUp(with: "",
                                         contents: dls.myIdentity_error_pwd_is_wrong,
                                         cancelTitle: dls.g_cancel,
                                         cancelHandler: nil)
                }
            })
            .disposed(by: bag)
        
    }
    
    private func showClearIdentityNoteAlert() -> Single<Bool> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_clearIdentity_title,
                message: dls.myIdentity_alert_clearIdentity_ensure_wallet_backup_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel) {
                                                (_) in
                                                //Just to terminate the sequence
                                                handler(.error(GTServerAPIError.apiReject))
            }
            
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .destructive) {
                                                (_) in
                                                handler(.success(true))
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func askUserInputPwdBeforeClear(withHint hint: String?) -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_clearIdentity_verify_pwd_title,
                message: dls.myIdentity_alert_clearIdentity_verify_pwd_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .destructive) {
                                                (_) in
                                                if let pwd = textField.text, pwd.count > 0 {
                                                    handler(.success(pwd))
                                                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:(hint != nil) ? dls.qrCodeImport_alert_placeholder_pwd(hint!) : dls.myIdentity_placeholder_pwd)
                textField = tf
                textField.isSecureTextEntry = true
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    private func clearIdentity() {
        guard let identity = Identity.singleton else {
            return
        }
        clearHUD.startAnimating(inView: self.view)
        identity.clear()
        TTNotificationHandler.deregisterIMUserFromNotification()
        IMUserManager.manager.clearIMUser()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            [unowned self] in
            self.clearHUD.updateType(KLHUD.HUDType.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")),
                                     text: LM.dls.myIdentity_hud_exited)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                [unowned self] in
                self.clearHUD.stopAnimating()
                OWRxNotificationCenter.instance.notifyIdentityCleared()
            })
        }
    }
    
    private func toBackupIdetityMnemonicView(of mnemonic: String?) {
        let vc = IdentityBackupTypeChooseViewController.navInstance(mnemonic: mnemonic)
        
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let message:String  = ""
            let composePicker = MFMailComposeViewController()
            composePicker.mailComposeDelegate = self
            composePicker.delegate = self
            composePicker.setToRecipients(["service@ttchainplus.io"])
            composePicker.setSubject("")
            composePicker.setMessageBody(message, isHTML: false)
            self.present(composePicker, animated: true, completion: nil)
        } else {
            self .showErrorMessage()
        }
    }
    
    func showErrorMessage() {
        let alertMessage = UIAlertController(title: "Could not sent email", message: "Check if your device has email support!", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title:"Okay", style: UIAlertActionStyle.default, handler: nil)
        alertMessage.addAction(action)
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    
    //MARK: - Mail Composer Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension SettingMenuViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Lang.supportLangs.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Lang.supportLangs[row].localizedName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLang = Lang.supportLangs[row]
        let selectedLanguage = Lang.init(rawValue: selectedLang.rawValue)
        LM.instance.lang.accept(selectedLanguage ?? Lang.default)
    }
}

extension SettingMenuViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 45))
        let label = UILabel(frame: CGRect(x: 18, y: 16, width: UIScreen.main.bounds.size.width - 36, height: 18))
        label.set(textColor: .navyBlue, font: .owRegular(size: 14))
        label.text = self.viewModel.dataSource[section].categoryTitle
        view.addSubview(label)
        view.backgroundColor = TM.palette.bgView_main
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 10))
        view.backgroundColor = TM.palette.bgView_main
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

}

//Export Wallet
extension SettingMenuViewController {
    
    private func toExportWalletPKey() {
        let alert = UIAlertController.init(title: LM.dls.walletManage_label_exportPKey,
                                           message: "",
                                           preferredStyle: .actionSheet)
        
        let actionETH = UIAlertAction.init(title: "ETH",
                                           style: .default,
                                           handler: { _ in
                                            self.handleWalletExport(forChain: .eth)
                                            
        })
        let actionBTC = UIAlertAction.init(title: "BTC",
                                           style: .default,
                                           handler: { _ in
                                            self.handleWalletExport(forChain: .btc)
        })
        
        let actionCancel = UIAlertAction.init(title: "Cancel",
                                              style: .cancel,
                                              handler: { _ in
                                                print("x")
        })
        
        
        alert.addAction(actionETH)
        alert.addAction(actionBTC)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func notificationSetting() {
        let alert = UIAlertController.init(title: LM.dls.settings_notification_title,
                                           message: "",
                                           preferredStyle: .actionSheet)
        
        let switchOnNotif = UIAlertAction.init(title: LM.dls.switch_on_notification_setting,
                                               style: .default,
                                               handler: { _ in
                                                TTNotificationHandler.registerIMUserForNotification()
                                                self.view.makeToast(LM.dls.g_success)
        })
        let switchOffNotif = UIAlertAction.init(title: LM.dls.switch_off_notification_setting,
                                                style: .default,
                                                handler: { _ in
                                                    TTNotificationHandler.deregisterIMUserFromNotification()
                                                    self.view.makeToast(LM.dls.g_success)
        })
        let actionCancel = UIAlertAction.init(title: LM.dls.g_cancel,
                                              style: .cancel,
                                              handler: { _ in
        })
        
        
        alert.addAction(switchOnNotif)
        alert.addAction(switchOffNotif)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleWalletExport(forChain chain:ChainType) {
        switch chain {
        case .btc,.eth:
            let pred = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: chain.rawValue))
            guard let wallets = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil), wallets.count > 0 else {
                return
            }
            if wallets.count == 1 {
                
                self.verifyPwdForExportWallet(wallets[0]).subscribe(onNext: { (wallet,status) in
                    if status {
                        let vc = ExportWalletPrivateKeyTabmanViewController.instance(of: wallet)
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc)
                    }else {
                        self.showSimplePopUp(with: LM.dls.walletManage_error_pwd,
                                             contents: "",
                                             cancelTitle: LM.dls.g_confirm,
                                             cancelHandler: nil)
                    }
                }).disposed(by: bag)
                
            }else {
                let actionSheet = UIAlertController.init(title: LM.dls.select_wallet_address, message: "", preferredStyle: .actionSheet)
                
                for wallet in wallets {
                    let title = (wallet.name)! + " - " + wallet.address!
                    let action = UIAlertAction.init(title: title, style: .default) { _ in
                        
                        self.verifyPwdForExportWallet(wallet).subscribe(onNext: {[weak self] (wallet,status) in
                            guard let `self` = self else {
                                return
                            }
                            if status {
                                let vc = ExportWalletPrivateKeyTabmanViewController.instance(of: wallet)
                                vc.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(vc)
                            }else {
                                self.showSimplePopUp(with: LM.dls.walletManage_error_pwd,
                                                     contents: "",
                                                     cancelTitle: LM.dls.g_confirm,
                                                     cancelHandler: nil)
                            }
                        }).disposed(by: self.bag)
                    }
                    actionSheet.addAction(action)
                }
                
                let cancelAction = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
                actionSheet.addAction(cancelAction)
                self.present(actionSheet, animated: true, completion: nil)
            }
        default:
            print("t")
        }
    }
    
    fileprivate func verifyPwdForExportWallet(_ wallet: Wallet) -> Observable<(Wallet, Bool)> {
        return Observable.create({ [unowned self] (observer) -> Disposable in
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.walletManage_alert_exportPKey_title,
                message: dls.walletManage_alert_exportPKey_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel, style: .cancel) {
                _ in
                observer.onCompleted()
            }
            
            let confirm = UIAlertAction.init(title: dls.g_confirm, style: .default) {
                (_) in
                let pwd = alert.textFields![0].text!
                let result = (wallet, wallet.isWalletPwd(rawPwd: pwd))
                observer.onNext(result)
                observer.onCompleted()
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(placeholder: dls.walletManage_alert_placeholder_exportPKey_pwd)
                tf.rx.text
                    .map { $0?.count ?? 0 }
                    .map { $0 > 0 }
                    .bind(to: confirm.rx.isEnabled)
                    .disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }).concat(Observable.never())
    }
}

