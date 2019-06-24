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
        self.view.layoutIfNeeded()
        self.hideDefaultNavBar()
        self.navigationController?.isNavigationBarHidden = true

        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        self.bindUI()
        self.handleSelection(forTab: .Message)
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
        self.messagesButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.messagesButton.isSelected {
                return
            }
            self.handleSelection(forTab: .Message)
        }).disposed(by: bag)
        self.friendsButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.friendsButton.isSelected {
                return
            }
            self.handleSelection(forTab: .Friends)
        }).disposed(by: bag)
        self.groupsButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.groupsButton.isSelected {
                return
            }
            self.handleSelection(forTab: .Groups)
        }).disposed(by: bag)
        
        self.createButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            switch self.currentTab! {
            case .Friends:
                let vc = InviteFriendViewController.navInstance()
                self.navigationController?.present(vc, animated: true, completion: nil)
            case .Groups:
                let viewModel = GroupInformationViewModel()
                let navController = UINavigationController.init(rootViewController:GroupInformationViewController.init(viewModel: viewModel))
                self.navigationController?.present(navController, animated: true, completion: nil)
            default:
                return
            }
        }).disposed(by: bag)
        
        self.scanQRCodeButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            guard let uid = IMUserManager.manager.userModel.value?.uID else {
                return
            }
            let vc = UserIMQRCodeViewController.navInstance(from: UserIMQRCodeViewController.Config(uid:uid, title:LM.dls.myQRCode))
            self.navigationController?.present(vc,animated:true,completion: nil)
        }).disposed(by: bag)
        
        self.profileButton.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            let viewController = ProfileViewController.navInstance()
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    func handleSelection(forTab tab:ChatTabs) {
        self.currentTab = tab
        self.messagesButton.isSelected = false
        self.groupsButton.isSelected = false
        self.friendsButton.isSelected = false
        self.createButton.isHidden = false
        switch tab {
        case .Message:
            self.messagesButton.isSelected = true
            configureChildView(forVC: self.getChatListViewController())
            self.createButton.isHidden = true
        case .Friends:
            self.friendsButton.isSelected = true
            configureChildView(forVC: self.getFriendListController())

        case .Groups:
            self.groupsButton.isSelected = true
            configureChildView(forVC: self.getGroupListController())
        }
    }
    
    func getChatListViewController() -> ChatMessageListViewController{
        let vc = ChatMessageListViewController.instance()
        return vc
    }
    func getFriendListController() -> ChatPersonListViewController {
        return ChatPersonListViewController.instance()
    }
    func getGroupListController() -> ChatGroupListViewController {
        return ChatGroupListViewController.instance()
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


