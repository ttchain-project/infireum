//
//  ManageWalletViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ManageWalletViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var walletInfoBase: UIView!
    @IBOutlet weak var walletNameLabel: UILabel!
//    @IBOutlet weak var editWalletNameBtn: UIButton!
//    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var walletNameEditIcon: UIImageView!
    
    @IBOutlet weak var pwdHintBase: UIView!
    @IBOutlet weak var pwdHintIcon: UIImageView!
    @IBOutlet weak var pwdHintTitleLabel: UILabel!
    @IBOutlet weak var pwdHintIndicator: UIImageView!
    
    @IBOutlet weak var exportPKeyBase: UIView!
    @IBOutlet weak var exportPKeyHintIcon: UIImageView!
    @IBOutlet weak var exportPKeyHintTitleLabel: UILabel!
    @IBOutlet weak var exportPKeyHintIndicator: UIImageView!
    
//    @IBOutlet weak var deleteBtn: UIButton!

    var bag: DisposeBag = DisposeBag.init()
    typealias ViewModel = ManageWalletViewModel
    var viewModel: ManageWalletViewModel!
    
    struct Config {
        let wallet: Wallet
    }
    
    typealias Constructor = Config
    
    func config(constructor: ManageWalletViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: ManageWalletViewModel.InputSource(
                wallet: constructor.wallet,
                managePwdHintInput: pwdHintBase.rx.klrx_tap,
                exportPKeyInput: exportPKeyBase.rx.klrx_tap,
                editNameInput: walletInfoBase.rx.klrx_tap.asDriver()
            ),
            output: ()
        )
        
        updateDeleteBtnVisibility(forWallet: constructor.wallet)
        bindBtnAction()
        bindViewModel()
    }
    
    private func updateDeleteBtnVisibility(forWallet wallet: Wallet) {
//        deleteBtn.isHidden = wallet.isFromSystem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindBtnAction() {
//        deleteBtn.rx.tap.asDriver()
//            .drive(onNext: {
//                [weak self]
//                 _ in
//                self?.presentWalletDeletePwdValidation()
//            })
//            .disposed(by: bag)
    }
    
    private func bindViewModel() {
//        viewModel.isAbleToExportPKey.map { !$0 }.bind(to: exportPKeyBase.rx.isHidden).disposed(by: bag)
        viewModel.wallet.map { $0.name }.bind(to: walletNameLabel.rx.text).disposed(by: bag)
//        viewModel.wallet.map { $0.address }.bind(to: walletAddressLabel.rx.text).disposed(by: bag)
        
        viewModel.startEditName.drive(onNext:{
            [unowned self] in
            self.startEditWalletName($0)
        })
        .disposed(by: bag)
        
        viewModel.startExportPKey.asObservable()
            .flatMapLatest {
                [unowned self] in self.verifyPwd($0, descTitle: LM.dls.walletManage_alert_exportPKey_title)
            }
            .subscribe(onNext:  {
                [unowned self]
                wallet, isVerified in
                if isVerified {
                    self.toExportWalletPKey(wallet: wallet)
                }else {
                    self.showSimplePopUp(with: LM.dls.walletManage_error_pwd,
                                         contents: "",
                                         cancelTitle: LM.dls.g_confirm,
                                         cancelHandler: nil)
                }
            })
            .disposed(by: bag)
        
        viewModel.startManagePwdHint.drive(onNext:{
            [unowned self] in
            self.toManagePwdHint(wallet: $0)
        })
            .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.walletManage_title
        pwdHintTitleLabel.text = dls.walletManage_label_pwdHint
        exportPKeyHintTitleLabel.text = dls.walletManage_label_exportPKey
        
//        deleteBtn
//            .setTitleForAllStates(dls.walletManage_btn_delete_wallet)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        
        view.backgroundColor = palette.bgView_sub
        
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1,
                                           image: #imageLiteral(resourceName: "arrowNavBlack"),
                                           title: nil)

        changeNavShadowVisibility(true)
        
        walletNameLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
//        walletAddressLabel.set(textColor: palette.label_sub, font: .owRegular(size: 14))
//        editWalletNameBtn.setPureImage(color: palette.application_main, image: #imageLiteral(resourceName: "btnListEditNormal"))
        
        pwdHintTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        exportPKeyHintTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        
//        deleteBtn.set(color: palette.specific(color: .owPinkRed),
//                      font: .owRegular(size: 17),
//                      backgroundColor: palette.bgView_main)
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

// MARK: - Routing
extension ManageWalletViewController {
    fileprivate func toManagePwdHint(wallet: Wallet) {
        let vc = PwdHintViewController.instance(from: PwdHintViewController.Config(wallet: wallet))
        navigationController?.pushViewController(vc)
    }
    
    fileprivate func toExportWalletPKey(wallet: Wallet) {
        let vc = ExportWalletPrivateKeyTabmanViewController.instance(of: wallet)
        navigationController?.pushViewController(vc)
    }
}

//MARK: - Export PKey Alert
extension ManageWalletViewController {
    fileprivate func verifyPwd(_ wallet: Wallet, descTitle: String) -> Observable<(Wallet, Bool)> {
        return Observable.create({ [unowned self] (observer) -> Disposable in
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: descTitle,
                message: dls.walletManage_alert_exportPKey_content,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel, style: .cancel) {
                _ in
                observer.onCompleted()
            }
            
            let confirm = UIAlertAction.init(title: dls.g_confirm, style: .default) {
                [unowned self]
                (_) in
                let pwd = alert.textFields![0].text!
                let result = (wallet, self.viewModel.checkInputIsWalletPwd(pwd))
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

// MARK: - Wallet Deletion
extension ManageWalletViewController {
    func deleteWalletAndDismiss() {
        let wallet = viewModel.input.wallet
        let context = DB.instance.managedObjectContext
        context.delete(wallet)
//        if DB.instance.update() {
            OWRxNotificationCenter.instance.notifyWalletDeleted(of: wallet)
//        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func presentWalletDeletePwdValidation() {
        verifyPwd(viewModel.input.wallet, descTitle: LM.dls.walletManage_alert_title_delete_wallet)
            .subscribe(onNext: {
                [unowned self]
                (wallet, success) in
                guard success else {
                    self.showSimplePopUp(with: LM.dls.walletManage_error_pwd,
                                         contents: "",
                                         cancelTitle: LM.dls.g_confirm,
                                         cancelHandler: nil)
                    return
                }
                
                self.deleteWalletAndDismiss()
            })
            .disposed(by: bag)
    }
}

// MARK: - Edit Name Alert
extension ManageWalletViewController {
    fileprivate func startEditWalletName(_ wallet: Wallet) {
        let dls = LM.dls
        let alert = UIAlertController.init(
            title: dls.walletManage_alert_changeWalletName_title,
            message: dls.walletManage_alert_changeWalletName_content,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction.init(title: dls.g_cancel,
                                        style: .cancel,
                                        handler: nil)
        
        let confirm = UIAlertAction.init(title: dls.g_confirm, style: .default) {
            [unowned self] (_) in
            let newName = alert.textFields![0].text!
            switch newName.ow_isValidWalletName {
            case .valid:
                self.viewModel.changeWalletName(to: newName)
            case .incorrectFormat(desc: let desc):
                self.showSimplePopUp(
                    with: dls.walletManage_error_walletName_invalidFormat_title,
                    contents: desc,
                    cancelTitle: dls.g_confirm,
                    cancelHandler: nil
                )
            }
        }
        
        alert.addTextField { [unowned self] (tf) in
            tf.delegate = self
            tf.set(placeholder: dls.walletManage_alert_placeholder_walletName_char_range)
            tf.rx.text
                .map {
                    text -> Bool in
                    if let _text = text {
                        return _text.count > 0 && _text.count <= 30
                    }else {
                        return false
                    }
                }
                .bind(to: confirm.rx.isEnabled)
                .disposed(by: self.bag)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ManageWalletViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let finalText: String
        if let text = textField.text {
            finalText = (text as NSString).replacingCharacters(in: range, with: string)
        }else {
            finalText = string
        }
        
        return !finalText.hasPrefix(" ")
    }
}
