//
//  ExportWalletPrivateKeyViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa
import Cartography

final class ExportWalletPrivateKeyTabmanViewController:UIViewController, RxThemeRespondable, RxLangRespondable {
    
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    var bag:DisposeBag = DisposeBag()
    
    private lazy var vcs: [UIViewController] = {
        return []
    }()
    
    static func navInstance(of wallet: Wallet) -> UINavigationController {
        let vc = xib(vc: ExportWalletPrivateKeyTabmanViewController.self)
        let nav = UINavigationController.init(rootViewController: vc)
        vc.config(wallet: wallet)
        return nav
    }
    
    static func instance(of wallet: Wallet) -> ExportWalletPrivateKeyTabmanViewController {
        let vc = xib(vc: ExportWalletPrivateKeyTabmanViewController.self)
        vc.config(wallet: wallet)
        return vc
    }
    
    private var wallet: Wallet!
    private var items: [TMBarItem] = []
    @IBOutlet weak var precautionLabel: UILabel!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    private func config(wallet: Wallet) {
        self.view.layoutIfNeeded()
        self.wallet = wallet
        self.vcs = createPages()

        setupUI()
        monitorLang { [unowned self] (lang) in
           let dls = lang.dls
            self.title = dls.exportPKey_title
            self.segmentedController.setTitle(dls.exportPKey_tab_privateKey, forSegmentAt: 0)
            self.segmentedController.setTitle(dls.exportPKey_tab_qrcode, forSegmentAt: 1)
            self.precautionLabel.text = dls.precaution_before_exporting_msg
        }
        
        monitorTheme { (theme) in
            self.config(with: theme.palette)
            self.precautionLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 20))
        }
    }
    
    private func items(with dls: DLS) -> [TMBarItem] {
        return [dls.exportPKey_tab_privateKey, dls.exportPKey_tab_qrcode].map {
            (name) -> TMBarItem in
            let item = TMBarItem.init(title: name)
            return item
        }
    }
    
    private func setupUI () {
        self.segmentedController.cornerRadius = self.segmentedController.height/2
        self.segmentedController.borderColor = .yellowGreen
        self.segmentedController.tintColor = .yellowGreen
        self.segmentedController.borderWidth = 1
        self.segmentedController.rx.value.asDriver().drive(onNext:{[unowned self] segment in
            self.setChildView(vc: self.vcs[segment])
        }).disposed(by:bag)
        self.segmentedController.selectedSegmentIndex = 0

    }
    
    private func setChildView(vc:UIViewController) {
        if self.childViewControllers.count > 0 {
            _ = self.childViewControllers.map {
                willMove(toParentViewController: nil)
                $0.view.removeFromSuperview()
                $0.removeFromParentViewController()
            }
        }
        self.addChildViewController(vc)
        self.containerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        constrain(vc.view) { (v) in
            let s = v.superview!
            v.top == s.top
            v.bottom == s.bottom
            v.leading == s.leading
            v.trailing == s.trailing
        }
    }
    
    private func config(with palette: OfflineWalletThemePalette) {
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
    }
    
    private func createPages() -> [UIViewController] {
        let vc1 = WalletPrivateKeyInfoViewController.instance(from: WalletPrivateKeyInfoViewController.Config(wallet: wallet)
        )
        let vc2 = WalletPKeyQRCodeViewController.instance(from: WalletPKeyQRCodeViewController.Config(wallet: wallet)
        )
        return [vc1, vc2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
