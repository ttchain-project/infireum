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

final class ForwardListContainerViewController: TabmanViewController, RxThemeRespondable, RxLangRespondable,PageboyViewControllerDataSource, TMBarDataSource {
    
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
    private var items: [TMBarItem] = []
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
        typealias TTBar = TMBarView<TMHorizontalBarLayout, TTTabManButton, TMBarIndicator.None>

        let bar = TTBar()
        dataSource = self
        
        bar.layout.alignment = .center
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentMode = .fit
        bar.backgroundView.style = TMBarBackgroundView.Style.flat(color: .licorice)
        self.items = self.items(with: LM.dls)
        
        addBar(bar, dataSource: self, at: .top)
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

    private func items(with dls: DLS) -> [TMBarItem] {
        return [LM.dls.friend,LM.dls.group,LM.dls.chat_list_title].map {
            (name) -> TMBarItem in
            let item = TMBarItem.init(title: name)
            return item
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        }).disposed(by: vc.bag)
    }
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return self.items[index]
    }
}
