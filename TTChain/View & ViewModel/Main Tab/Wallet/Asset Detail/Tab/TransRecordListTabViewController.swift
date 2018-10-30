//
//  TransRecordListTabViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

class TransRecordListTabViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable, PageboyViewControllerDataSource {
    
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
    public lazy var nextPage: Driver<Void> = {
        return _nextPage
            .asDriver(onErrorJustReturn: Driver.never())
            .switchLatest()
            .debug("switch source")
    }()
    
    private lazy var _nextPage: PublishRelay<Driver<Void>> = {
        return PublishRelay.init()
    }()
    
    public lazy var refresh: Driver<Void> = {
           return _refresh
                    .asDriver(onErrorJustReturn: Driver.never())
                    .switchLatest()
    }()
    
    private lazy var _refresh: PublishRelay<Driver<Void>> = {
        return PublishRelay.init()
    }()
    
    public func stopRefresh() {
        if let idx = currentIndex {
            let vc = vcs[idx]
            vc.stopRefreshing()
        }
    }
    
    private var asset: Asset!
    
    private lazy var vcs: [TransRecordListViewController] = {
        return []
    }()
    
    static func navInstance(of transRecords: [TransRecord], asset: Asset) -> UINavigationController {
        let vc = xib(vc: TransRecordListTabViewController.self)
        let nav = UINavigationController.init(rootViewController: vc)
        vc.config(transRecords: transRecords, asset: asset)
        return nav
    }
    
    static func instance(of transRecords: [TransRecord], asset: Asset) -> TransRecordListTabViewController {
        let vc = xib(vc: TransRecordListTabViewController.self)
        vc.config(transRecords: transRecords, asset: asset)
        return vc
    }
    
    private var transRecords: [TransRecord]!
    
    private func config(transRecords: [TransRecord], asset: Asset) {
        self.transRecords = transRecords
        self.asset = asset
        
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
        }
        
        monitorTheme { (theme) in
            self.bar.appearance?.indicator.color = theme.palette.label_main_1
            self.bar.appearance?.state.selectedColor = theme.palette.label_main_1
            self.bar.appearance?.state.color = theme.palette.label_sub
            self.config(with: theme.palette)
        }
    }
    
    private func items(with dls: DLS) -> [TabmanBar.Item] {
        return [dls.assetDetail_tab_total,
                dls.assetDetail_btn_withdrawal,
                dls.assetDetail_tab_deposit,
                dls.assetDetail_tab_fail]
            .map {
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
    
    private func createPages() -> [TransRecordListViewController] {
        let totalVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .total
            )
        )
        
        let withdrawalVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .withdrawal
            )
        )
        
        let depositVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .deposit
            )
        )
        
        let failedVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .failed
            )
        )
        
        return [totalVC, withdrawalVC, depositVC, failedVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        automaticallyAdjustsChildViewInsets = false
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
    
    override func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: Int,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
        ) {
        let vc = vcs[index]
        _nextPage.accept(vc.nextPage)
        _refresh.accept(vc.onRefresh)
    }
}

extension TransRecordListTabViewController {
    func updateRecords(_ records: [TransRecord]) {
        vcs.forEach { (vc) in
            vc.updateRecords(records)
        }
    }
}
