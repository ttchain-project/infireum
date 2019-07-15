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

class TransRecordListTabViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable,PageboyViewControllerDataSource, TMBarDataSource {
    
    
    
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
    private var items: [TMBarItem] = []
    
    private func config(transRecords: [TransRecord], asset: Asset) {
        self.transRecords = transRecords
        self.asset = asset
        typealias TTBar = TMBarView<TMHorizontalBarLayout, TTTabManButton, TMBarIndicator.None>
        vcs = createPages()
        let bar = TTBar()
        dataSource = self

        bar.layout.alignment = .center
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentMode = .fit
        bar.backgroundView.style = TMBarBackgroundView.Style.flat(color: .licorice)
        self.items = self.items(with: LM.dls)

        addBar(bar, dataSource: self, at: .top)
        
        monitorTheme { (theme) in
            self.config(with: theme.palette)
            self.view.backgroundColor = theme.palette.nav_bg_clear
        }
    }
    
    private func items(with dls: DLS) -> [TMBarItem] {
        return [dls.assetDetail_tab_total,
                dls.assetDetail_btn_withdrawal,
                dls.assetDetail_receive,
                dls.assetDetail_tab_fail]
            .map {
                (name) -> TMBarItem in
                let item = TMBarItem.init(title: name)
                return item
            }
    }
    
    private func config(with palette: OfflineWalletThemePalette) {
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
    }
    
    private func createPages() -> [TransRecordListViewController] {
        let totalVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .total))
        let withdrawalVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .withdrawal))
        let depositVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .deposit))
        let failedVC = TransRecordListViewController.instance(from: TransRecordListViewController.Config(
                asset: asset, records: transRecords, type: .failed))
        
        return [totalVC, withdrawalVC, depositVC, failedVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return self.items[index]
    }
}

extension TransRecordListTabViewController {
    func updateRecords(_ records: [TransRecord]) {
        vcs.forEach { (vc) in
            vc.updateRecords(records)
        }
    }
}
