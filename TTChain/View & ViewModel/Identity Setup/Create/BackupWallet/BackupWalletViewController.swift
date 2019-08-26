//
//  BackupWalletViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class BackupWalletViewController: KLModuleViewController,KLVMVC {
    var viewModel: BackupWalletViewModel!
    typealias ViewModel = BackupWalletViewModel
    
    var bag:DisposeBag = DisposeBag()

    typealias Constructor = Config
    
    struct Config {
        var name:String
        var pwd:String
        var pwdHint:String
    }
    
    func config(constructor: BackupWalletViewController.Config) {
        self.view.layoutIfNeeded()
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.confirmButton.isHidden = true
        self.viewModel = BackupWalletViewModel.init(input: BackupWalletViewModel.Input(name:constructor.name, pwd:constructor.pwd, pwdHint:constructor.pwdHint), output: BackupWalletViewModel.OutputSource())
        self.bindUI()
        self.viewModel.createIdentity()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    lazy var hud: KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            descText: LM.dls.createID_hud_creating,
            spinnerColor: TM.palette.hud_spinner,
            textColor: TM.palette.hud_text
        )
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showQRCodeBtn: UIButton! {
        didSet {
            showQRCodeBtn.roundBothSides()
        }
    }
    @IBOutlet weak var qrCodemsgLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var backQRCodeMessageLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func renderTheme(_ theme: Theme) {
        let p = theme.palette
        self.showQRCodeBtn.set(color: p.btn_bgFill_enable_text, font: .owRegular(size:14), backgroundColor: p.bg_fill_new)
        self.backQRCodeMessageLabel.set(textColor: p.label_main_1, font: .owRegular(size: 14))
        self.titleLabel.set(textColor: p.label_main_1, font: .owRegular(size: 16))
        self.qrCodemsgLabel.set(textColor: .owPinkRed, font: .owRegular(size: 14))
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
    
    override func renderLang(_ lang: Lang) {
        self.skipButton.setTitleForAllStates(lang.dls.qrcodeExport_alert_btn_skip)
        self.confirmButton.setTitleForAllStates(lang.dls.g_confirm)
        self.titleLabel.text = lang.dls.backupWallet_sourceChoose_label_use_identity_qrcode
        self.backQRCodeMessageLabel.text = lang.dls.backup_qrcode_message_label
        self.showQRCodeBtn.setTitleForAllStates(lang.dls.show_qr_code)
        self.qrCodemsgLabel.text = lang.dls.backupWallet_label_subNote
    }
    
    func bindUI() {
        
        self.viewModel.output.bottomButtonIsEnabled
            .bind(to:self.skipButton.rx.isEnabled)
            .disposed(by:bag)
        
        self.viewModel.output.animateHUDSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (status) in
            if status {
                self.hud.startAnimating(inView: self.view)
            }else {
                self.hud.stopAnimating()
            }
        }).disposed(by: bag)
        
        self.viewModel.output.errorMessageSubject.bind(to:self.rx.message).disposed(by: bag)
        
        self.skipButton.rx.klrx_tap.drive(onNext:{
            
            let vc = SkipBackupWarningViewController.init(completion: { (status) in
                self.dismiss(animated: false, completion: nil)
                if !status {
                    self.toMainTab()
                }
            })
            self.present(vc, animated: false, completion: nil)
        }).disposed(by: bag)
        
        self.confirmButton.rx.klrx_tap.drive(onNext:{
            self.toMainTab()
        }).disposed(by: bag)
        
        self.showQRCodeBtn.rx.klrx_tap.drive(onNext:{
            self.startQRCodeBackupFlow()
        }).disposed(by: bag)
        
        self.viewModel.output.qrcodeImage
            .observeOn(MainScheduler.instance).map { image -> UIImage? in
                self.skipButton.isHidden = image != nil
                self.confirmButton.isHidden = image == nil
                return image
            }
            .bind(to:self.qrCodeImageView.rx.image)
            .disposed(by:bag)
    }

    private var flow: IdentityQRCodeEncryptionFlow?
    private func startQRCodeBackupFlow() {
        flow = IdentityQRCodeEncryptionFlow.start(
            launchType: .create,
            identity: Identity.singleton!,
            onViewController: self,
            onComplete: { [weak self] result in
                switch result {
                case .createOwnQRCode(let content):
                    self?.viewModel.createQRCode(fromContent:content)
//                case .skipped:
//                    self?.toMainTab()
                default:
                    break
                }
                self?.flow = nil
        })
    }

    func toMainTab() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMainTab()
    }
}
