//
//  FriendsListViewController.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

final class FriendsListViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable,PageboyViewControllerDataSource {
    
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
    struct Config {
        var searchTextInOut: ControlProperty<String?>
        var searchStatus: BehaviorRelay<Bool>
    }
    private lazy var vcs: [UIViewController] = {
        return []
    }()
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config
    
    var configVar : Config!
    
    
    static func instance(searchTextInOut:ControlProperty<String?>, searchStatus: BehaviorRelay<Bool>) -> FriendsListViewController {
        let vc = xib(vc: FriendsListViewController.self)
        vc.config(constructor: FriendsListViewController.Config.init(searchTextInOut: searchTextInOut, searchStatus: searchStatus))
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = LM.dls.contact_title
        self.dataSource = self

        self.bar.items = [Item(title: LM.dls.contact_individual), Item(title: LM.dls.contact_group)]

        bar.appearance = TabmanBar.Appearance.init({ (appearance) in
            appearance.layout.itemDistribution = TabmanBar.Appearance.Layout.ItemDistribution.leftAligned
            appearance.layout.minimumItemWidth = 0.5 * UIScreen.main.bounds.width
            appearance.layout.interItemSpacing = 0.0
            appearance.layout.edgeInset = 0.0
            
            appearance.indicator.color = UIColor.white
            
            appearance.indicator.bounces = true
            
            appearance.style.background = TabmanBar.BackgroundView.Style.solid(color:UIColor.owIceCold)
            appearance.bottomSeparator.color = UIColor.init(hex: 0xd6d6d6, transparency: 0.5)
        })
    }
    
    func config(constructor: Config) {
        self.configVar = constructor

        vcs = createPages()
        let palette = TM.palette
//        renderNavBar(tint: palette.nav_bg_1, barTint: palette.nav_bg_1)
        changeBackBarButton(toColor: palette.nav_item_1, image:#imageLiteral(resourceName: "arrowNavBlack"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    private func createPages() -> [UIViewController] {
        let vc1 = ChatPersonListViewController.instance(from: ChatPersonListViewController.Config(searchTextInOut: self.configVar.searchTextInOut,searchStatus:self.configVar.searchStatus))

        let vc2 = ChatGroupListViewController.instance(from: ChatGroupListViewController.Config(searchTextInOut: self.configVar.searchTextInOut,searchStatus:self.configVar.searchStatus))
        return [vc1, vc2]
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
//        let vc = vcs[index]
//        _nextPage.accept(vc.nextPage)
//        _refresh.accept(vc.onRefresh)
    }
    
    public func enableSearchMode() {
        
    }
    
    public func searchRecords(forKey key:String) {
        
    }
}
