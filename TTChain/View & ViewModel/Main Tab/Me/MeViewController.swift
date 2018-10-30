//
//  MeViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MeViewController: KLModuleViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editNameBtn: UIButton!
    
    @IBOutlet weak var addressBookBase: UIView!
    @IBOutlet weak var addressBookLabel: UILabel!
    @IBOutlet weak var addressSepline: UIView!
    
    @IBOutlet weak var settingsBase: UIView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var settingsSepline: UIView!
    
    @IBOutlet weak var qaBase: UIView!
    @IBOutlet weak var qaLabel: UILabel!
    @IBOutlet weak var qaSepline: UIView!
    
    @IBOutlet weak var agreementBase: UIView!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var agreeSepline: UIView!
    
    @IBOutlet weak var checkUpdateBase: UIView!
    @IBOutlet weak var checkUpdateLabel: UILabel!
    @IBOutlet weak var checkUpdateSepline: UIView!
    
    static func instance() -> MeViewController {
        return xib(vc: self)
    }
    
    private var contentLabels: [UILabel] {
        return [addressBookLabel, qaLabel, agreementLabel, settingsLabel, checkUpdateLabel]
    }
    
    private var seplines: [UIView] {
        return [addressSepline, qaSepline, agreeSepline, settingsSepline, checkUpdateSepline]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindBaseActions()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
        refreshUserName()
        observIdentityUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        editNameBtn.setTitleForAllStates(dls.me_btn_edit)
        addressBookLabel.text = dls.me_label_common_used_addr
        qaLabel.text = dls.me_label_qa
        agreementLabel.text = dls.me_label_agreement
        settingsLabel.text = dls.me_label_settings
        checkUpdateLabel.text = dls.me_label_check_update
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        nameLabel.set(textColor: palette.label_main_2, font: .owMedium(size: 16))
        editNameBtn.set(color: palette.label_main_2, font: UIFont.owMedium(size: 12), image: #imageLiteral(resourceName: "btnListEditWhiteNormal"))
        contentLabels.forEach { (label) in
            label.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        }
        seplines.forEach { (sepline) in
            sepline.backgroundColor = palette.sepline
        }
    }
    
    private func bindBaseActions() {
        editNameBtn.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in self.toEditIdentity()
            })
            .disposed(by: bag)
        
        addressBookBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.toAddressBook()
        })
            .disposed(by: bag)
        
        settingsBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.toSettings()
        })
            .disposed(by: bag)
        
        agreementBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.toAgreement()
        })
            .disposed(by: bag)
        
        qaBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.toQA()
        })
            .disposed(by: bag)
        
        checkUpdateBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.startCheckVersion()
        })
            .disposed(by: bag)
    }
    
    private func observIdentityUpdate() {
        OWRxNotificationCenter.instance.onUpdateIdentity
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.refreshUserName()
            })
            .disposed(by: bag)
    }
    
    private func toEditIdentity() {
        let nav = IdentityViewController.navInstance(from: IdentityViewController.Config(identity: Identity.singleton!))
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func toAddressBook() {
        let nav = AddressBookViewController.navInstance(from: AddressBookViewController.Config(identity: Identity.singleton!, purpose: .browse))
        
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    private func toAgreement() {
        let nav = AgreementMeViewController.navInstance(from: AgreementMeViewController.Config(identity: Identity.singleton!))
        tabBarController?.present(nav, animated: true, completion: nil)
        
    }
    
    private func toQA() {
        let nav = QAViewController.navInstance(from: QAViewController.Config(identity: Identity.singleton!))
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    private func toSettings() {
        let nav = SettingsViewController.navInstance(from: SettingsViewController.Config(identity: Identity.singleton!)
        )
        
        tabBarController?.present(nav, animated: true, completion: nil)
    }
    
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
    
    private func refreshUserName() {
        nameLabel.text = Identity.singleton!.name
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
