//
//  ForwardListContainerViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

final class ForwardListContainerViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable,PageboyViewControllerDataSource {
    
    var langBag: DisposeBag = DisposeBag.init()
    
    var themeBag: DisposeBag = DisposeBag.init()
    var bag = DisposeBag.init()
    struct Config {
        var messageModel:MessageModel
    }
    var configVar : Config!

    private let forwardChatToSelection : PublishRelay<ChatListPage> = PublishRelay.init()
    
    var onForwardChatToSelection : Observable<(ChatListPage)> {
        return forwardChatToSelection.asObservable()
    }
    
    private lazy var vcs: [ForwardListViewController] = {
        return []
    }()

    static func instance(messageModel: MessageModel) -> ForwardListContainerViewController {
        let vc = xib(vc: ForwardListContainerViewController.self)
        vc.config(constructor: ForwardListContainerViewController.Config.init(messageModel:messageModel))
        return vc
    }
    
    func config(constructor: Config) {
        self.configVar = constructor
        
        vcs = createPages()
        let palette = TM.palette
        //        renderNavBar(tint: palette.nav_bg_1, barTint: palette.nav_bg_1)
        changeBackBarButton(toColor: palette.nav_item_1, image:#imageLiteral(resourceName: "arrowNavBlack"))
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
    
    func createPages() -> [ForwardListViewController]{
        let friendsVC = ForwardListViewController.instance(from: ForwardListViewController.Config(messageModel: self.configVar.messageModel, listType: .Friends))
        let groupVC = ForwardListViewController.instance(from: ForwardListViewController.Config(messageModel: self.configVar.messageModel, listType: .Group))
        let chatVC = ForwardListViewController.instance(from: ForwardListViewController.Config(messageModel: self.configVar.messageModel, listType: .Chat))
        
        return [friendsVC, groupVC, chatVC]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.bar.items = [Item(title: LM.dls.friend), Item(title: LM.dls.group),Item(title: LM.dls.chat_list_title)]
        
        bar.appearance = TabmanBar.Appearance.init({ (appearance) in
            appearance.layout.itemDistribution = TabmanBar.Appearance.Layout.ItemDistribution.leftAligned
            appearance.layout.minimumItemWidth = UIScreen.main.bounds.width/3
            appearance.layout.interItemSpacing = 0.0
            appearance.layout.edgeInset = 0.0
            
            appearance.indicator.color = UIColor.white
            
            appearance.indicator.bounces = true
            
            appearance.style.background = TabmanBar.BackgroundView.Style.solid(color:UIColor.owIceCold)
            appearance.bottomSeparator.color = UIColor.init(hex: 0xd6d6d6, transparency: 0.5)
        })
        
        // Do any additional setup after loading the view.
    }

    override func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: Int,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
        ) {
        let vc = vcs[index]
        vc.onForwardChatToSelection.asObservable().subscribe(onNext: { (model) in
            self.forwardChatToSelection.accept(model)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: vc.bag)
    }
}
