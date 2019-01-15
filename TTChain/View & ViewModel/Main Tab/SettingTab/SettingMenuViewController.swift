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

final class SettingMenuViewController: KLModuleViewController, KLVMVC,MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    var viewModel: SettingMenuViewModel!
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: (), output: ())
        self.configCollectionView()
        self.bindCollectionView()
        self.setUpLangSelectView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    typealias ViewModel = SettingMenuViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Void

    @IBOutlet weak var collectionView: UICollectionView!
    
    let pickerView: UIPickerView = UIPickerView.init()
    private let pickerResponder = UITextField.init()

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
    func configCollectionView() {
        
        collectionView.register(SettingMenuCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier())
     
        collectionView.register(SettingMenuHeaderCollectionReusableView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className)
        
//        collectionView.delegate = self
    }
    
    func bindCollectionView() {
        viewModel.datasource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: indexPath) as! SettingMenuCollectionViewCell
            cell.setupCell(model:settingModel)
            return cell
        }
        viewModel.datasource.configureSupplementaryView = { (datasource, cv, kind, indexpath) in
            if (kind == UICollectionElementKindSectionHeader) {
                let headerView = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexpath) as!  SettingMenuHeaderCollectionReusableView
                headerView.setup(title:"Title")
                return headerView
            }
            return UICollectionReusableView()
        }
        MarketTestHandler.shared.settingsArray
            .bind(to: collectionView.rx.items(
                dataSource: viewModel.datasource)
            )
            .disposed(by: bag)

        collectionView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let settingModel: MarketTestTabModel = MarketTestHandler.shared.settingsArray.value[indexPath.section].items[indexPath.row] as! MarketTestTabModel
            if settingModel.isExternalLink , settingModel.url != nil{
                if UIApplication.shared.canOpenURL(settingModel.url!) {
                    UIApplication.shared.open(settingModel.url!, options: [:], completionHandler: nil)
                }
            }else {
                self.handleNavigation(model: settingModel)
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
        self.title = "Setting"
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        
        collectionView.backgroundColor = palette.nav_bg_clear
        view.backgroundColor = palette.bgView_main
    }
    
    func handleNavigation(model:MarketTestTabModel) {
        guard let url = model.url else {
            return
        }
        if url.scheme == "app" {
            let key = url.absoluteString.replacingOccurrences(of: "app://", with: "")
            switch key {
            case "safety":
                toExportWalletPKey()
            case "notify":break
            case "common_addr":
                toAddressBook()
            case "update":
                startCheckVersion()
            case "delete":
                clearIdentity(Identity.singleton!)
            case "userQrCode":
                self.backup(identity: Identity.singleton!)
            case "currency":
                self.toFiatSelectView()
            case "language":
                self.pickerResponder.becomeFirstResponder()
            case "pin":break
            case "agreement":
                toAgreement(title: model.title, content: model.content)
            case "about":
                toAgreement(title: model.title, content: model.content)
            case "help":
                toAgreement(title: model.title, content: model.content)
            case "suggestion":
                sendMail()
            default:
                break
            }
        }
    }
    
    private func toFiatSelectView() {
        let vc = ChangePrefFiatViewController.instance(from: ChangePrefFiatViewController.Config(identity: Identity.singleton!))
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
    
    private func clearIdentity(_ identity: Identity) {
        clearHUD.startAnimating(inView: self.view)
        identity.clear()
        
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
    
    
    private func backup(identity: Identity) {
        //NOTE: As we need to check the pwd, but pwd is related to wallet.
        //      Since there's no pwd for identity now, must make sure that all
        //      the pwds are same, so we can guarantee that the system has no
        //      pwd-updating features yet.
        
        guard let wallets = identity.wallets?.array as? [Wallet] else {
            return
        }
        
        let systemWallets = wallets.filter { $0.isFromSystem }
        let pwdSet = Set.init(systemWallets.map { $0.ePwd! })
        guard pwdSet.count == 1 else { return }
        let sampleWallet = systemWallets[0]
        let pwdHintSet = Set.init(systemWallets.map { $0.pwdHint! })
        guard pwdHintSet.count == 1 else { return errorDebug(response: ()) }
        
        askUserInputPwdBeforeBackup(withHint: pwdHintSet.first)
            .subscribe(onSuccess: { [unowned self] (pwd) in
                let dls = LM.dls
                if sampleWallet.isWalletPwd(rawPwd: pwd) {
                    guard let mnemonic = systemWallets[0].attemptDecryptMnemonic(withRawPwd: pwd) else {
                        self.showSimplePopUp(
                            with: dls.myIdentity_error_unable_to_decrypt_mnemonic,
                            contents: "",
                            cancelTitle: dls.g_confirm,
                            cancelHandler: nil
                        )
                        
                        return errorDebug(response: ())
                    }
                    
                    self.toBackupIdetityMnemonicView(of: mnemonic)
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
    
    private func askUserInputPwdBeforeBackup(withHint hint: String?) -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.myIdentity_alert_backup_identity_title,
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
    
    private func toBackupIdetityMnemonicView(of mnemonic: String) {
        let vc = IdentityBackupTypeChooseViewController.navInstance(mnemonic: mnemonic)
        
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private func toExportWalletPKey() {
        let alert = UIAlertController.init(title: "Export Wallet",
                                           message: "Choose a wallet to export",
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
    
    func handleWalletExport(forChain chain:ChainType) {
        switch chain {
        case .btc,.eth:
            let pred = Wallet.genPredicate(fromIdentifierType: .num(keyPath: #keyPath(Wallet.chainType), value: chain.rawValue))
            guard let wallets = DB.instance.get(type: Wallet.self, predicate: pred, sorts: nil), wallets.count > 0 else {
                return
            }
            
            let vc = ExportWalletPrivateKeyTabmanViewController.instance(of: wallets[0])
            self.navigationController?.pushViewController(vc)
        default:
            print("t")
        }
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
        let alertMessage = UIAlertController(title: "could not sent email", message: "check if your device have email support!", preferredStyle: UIAlertControllerStyle.alert)
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

extension SettingMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 80)/4
        let height = width + 30
        let size = CGSize.init(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 5, left: 20, bottom: 5, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: self.view.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexPath) as!  SettingMenuHeaderCollectionReusableView
            headerView.setup(title:"Title")
            headerView.backgroundColor = UIColor.gray
            headerView.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: 40)
            return headerView
        }else {
            return UIView() as! UICollectionReusableView
        }
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
