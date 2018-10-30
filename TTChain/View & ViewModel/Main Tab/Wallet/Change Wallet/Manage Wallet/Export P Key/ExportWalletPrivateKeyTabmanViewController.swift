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

final class ExportWalletPrivateKeyTabmanViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable, PageboyViewControllerDataSource {
    
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
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
    
    private func config(wallet: Wallet) {
        self.wallet = wallet
        vcs = createPages()
        self.bar.style = .buttonBar
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.indicator.preferredStyle = TabmanIndicator.Style.line
            appearance.style.background = Tabman.TabmanBar.BackgroundView.Style.solid(color: UIColor.clear)
            switch bar.style {
            case .scrollingButtonBar:
                appearance.layout.itemDistribution = .leftAligned
            default:
                appearance.layout.itemDistribution = .centered
            }
            
            //            appearance.indicator.color = UIColor.eeAquaBlue
            appearance.indicator.lineWeight = .thin
            appearance.indicator.useRoundedCorners = true
            //            appearance.state.selectedColor = UIColor.eeAquaBlue
            //            appearance.state.color = UIColor.eeAquaBlue.withAlphaComponent(0.5)
            appearance.layout.height = TabmanBar.Height.explicit(value: 44)
        })
        
        reloadPages()
        
        monitorLang { [unowned self] (lang) in
            self.bar.items = self.items(with: lang.dls)
            self.config(with: lang.dls)
        }
        
        monitorTheme { (theme) in
            self.bar.appearance?.indicator.color = theme.palette.label_main_1
            self.bar.appearance?.state.selectedColor = theme.palette.label_main_1
            self.bar.appearance?.state.color = theme.palette.label_sub
            self.config(with: theme.palette)
        }
    }
    
    private func config(with dls: DLS) {
        title = dls.exportPKey_title
    }
    
    private func items(with dls: DLS) -> [TabmanBar.Item] {
        return [dls.exportPKey_tab_privateKey, dls.exportPKey_tab_qrcode].map {
            (name) -> TabmanBar.Item in
            let item = Item.init(title: name)
            return item
        }
    }
    
    private func config(with palette: OfflineWalletThemePalette) {
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
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
        dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return vcs.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return vcs[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
}
