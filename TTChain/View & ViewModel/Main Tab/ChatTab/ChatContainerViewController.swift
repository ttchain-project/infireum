//
//  ChatContainerViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/20.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

enum ChatTabs {
    case Message
    case Friends
    case Groups
}

final class ChatContainerViewController: KLModuleViewController,KLVMVC {
   
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Void
    typealias ViewModel = ChatTabViewModel
    var viewModel: ChatContainerViewController.ViewModel!
    func config(constructor: Void) {
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var groupsButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var scanQRCodeButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    var currentChildVC:UIViewController!
    var currentTab:ChatTabs!
    override func renderLang(_ lang: Lang) {
        messagesButton.setTitleForAllStates(lang.dls.chat_msg_tab_title)
        friendsButton.setTitleForAllStates(lang.dls.friend)
        groupsButton.setTitleForAllStates(lang.dls.tab_social)

    }
    override func renderTheme(_ theme: Theme) {
        messagesButton.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        friendsButton.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        groupsButton.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        messagesButton.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
        friendsButton.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
        groupsButton.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
    }
    
    func bindUI() {
        
    }
    
    func handleSelection(forTab tab:ChatTabs) {
        self.currentTab = tab
        switch tab {
        case .Message:
            configureChildView(forVC: self.getChatListViewController())
            DLogDebug()
        case .Friends:
            DLogDebug()
        case .Groups:
            DLogDebug()
        }
    }
    
    func getChatListViewController() -> ChatListViewController{
        let vc = ChatListViewController.instance(from: ())
        return vc
    }
    func configureChildView(forVC vc:UIViewController) {
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
        self.currentChildVC = vc
    }
}


