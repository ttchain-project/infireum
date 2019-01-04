//
//  ChatListViewController.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatListViewController: KLModuleViewController, KLVMVC {
    var viewModel: ChatListViewModel!
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        self.viewModel = ChatListViewModel.init(
            input: ChatListViewModel.Input(chatSelected: self.tableView.rx.itemSelected.asDriver().map { $0.row }),
            output: ChatListViewModel.Output(selectedChat: { [unowned self] model in self.chatSelected(forModel: model) })
        )
        initNavigationBarItems()
        initTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
    }
    
    typealias ViewModel = ChatListViewModel
    
    typealias Constructor = Void
    
    @IBOutlet weak var tableView: UITableView!
    
    var bag: DisposeBag = DisposeBag()
    
    var popover: UIPopoverPresentationController? = nil
    
    var moreBarButtonItem: UIBarButtonItem? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        if IMUserManager.manager.userLoginStatus.value == .deviceIDNotMatched {
            showTransferAlert()
        } else {
            self.viewModel.getCommunicationList()
        }
    }
    
    func showTransferAlert() {
        let alertController = UIAlertController.init(title: LM.dls.chat_list_alert_recover_message_history_title, message: LM.dls.chat_list_alert_recover_message_history_message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = LM.dls.chat_list_placeholder_recover_message_history
        }
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.chat_list_alert_recover_message_history_create, style: .default, handler: { (action) in
            IMUserManager.manager.createUserForIM()
        }))
        
        alertController.addAction(UIAlertAction.init(title: LM.dls.chat_list_alert_recover_message_history_recover, style: .default, handler: { (action) in
            if let textFields = alertController.textFields, let text = textFields[0].text, text.count > 0 {
                IMUserManager.manager.recoverUser(withPassword: text, handle: { [weak self] (isSuccess) in
                    guard let `self` = self else { return }
                    if isSuccess {
                        self.viewModel.getCommunicationList()
                    } else {
                        EZToast.present(on: self, content: "還原失敗")
                        self.showTransferAlert()
                    }
                })
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func chatSelected(forModel model:CommunicationListModel) {
        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: model.roomType, chatTitle: model.displayName, roomID: model.roomId,chatAvatar:model.avatar))
        self.navigationController?.pushViewController(vc)
    }
    
    
    func initNavigationBarItems() {
        let friendBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconCommunicationUserDark").withRenderingMode(UIImageRenderingMode.alwaysTemplate), style: UIBarButtonItemStyle.done, target: self, action: nil)
        friendBarButtonItem.tintColor = .white
        moreBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconHorizontalDark").withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.done, target: self, action: nil)

        navigationItem.rightBarButtonItems = [moreBarButtonItem!, friendBarButtonItem]
        
//        navigationController?.navigationBar.backgroundImage(for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage.init(color: UIColor.init(hex: 0xD6D6D6)!, size: CGSize(width: 1.0, height: 1.0))
        
        
        moreBarButtonItem?.rx.tap.asDriver().drive(onNext: {
            self.popExtendMenu()
        }).disposed(by: bag)
        friendBarButtonItem.rx.tap.asDriver().drive(onNext: {
            self.toFriendList()
        }).disposed(by: bag)
    }
    
    func initTableView() {
        tableView.register(ChatHistoryTableViewCell.nib, forCellReuseIdentifier: ChatHistoryTableViewCell.cellIdentifier())
    }
    
    func bindViewModel() {
        viewModel.communicationList.bind(to: tableView.rx.items(cellIdentifier: ChatHistoryTableViewCell.cellIdentifier(), cellType: ChatHistoryTableViewCell.self)) {
            row, record, cell in
            cell.config(model: record)
            }
            .disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))

        tableView.backgroundColor = palette.nav_bg_clear
        view.backgroundColor = palette.bgView_main
    }
    
    override func renderLang(_ lang: Lang) {
//        let dls = lang.dls
//        title = dls.chat_list_title
    }
    
    @objc func settingsButtonTapped() {
    
    }
    @objc func toFriendList() {
        let viewController = FriendListContainerViewController.instance()
        self.show(viewController, sender: nil)
    }

    
    @objc func popExtendMenu() {
        let viewController = xib(vc: ChatExtendFunctionMenuViewController.self)
        
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize.init(width: 145, height: 99 + 12)
        viewController.startMonitorLangIfNeeded()
        if let popViewController = viewController.popoverPresentationController {
            popViewController.barButtonItem = moreBarButtonItem
            popViewController.permittedArrowDirections = .any
            popViewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        
        viewController.tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            viewController.tableView.deselectRow(at: indexPath, animated: true)
            viewController.dismiss(animated: true, completion: {
                guard let item = ExtendItem.init(rawValue: indexPath.row) else { return }
                switch item {
                case .sweepQRCode:     self.show(MyQRCodeViewController.instance(), sender: self)
                case .manageGroup:
//                    let constructor = ManageGroupViewController.Constructor.init(purpose: .create)
//                    let viewController = ManageGroupViewController.instance(from: constructor)
//                    self.show(viewController, sender: nil)
                    let viewModel = GroupInformationViewModel()
                    let viewController = GroupInformationViewController.init(viewModel: viewModel)
                    self.show(viewController, sender: nil)
                case .inviteFriend:     self.show(InviteFriendViewController.instance(), sender: self)
                case .searchGroup:     self.show(SearchGroupViewController.instance(), sender: self)
                case .redEnvelope:     self.show(RedEnvelopeViewController.instance(), sender: self)
                case .userProfile:
                    let user = IMUserManager.manager.userModel.value ?? IMUser.init(uID: String(), nickName: String(), introduction: String(), headImg: nil)
                    let model = FriendRequestInformationModel.init(imUser: user)
                    let config = UserProfileViewController.Config.init(purpose: UserProfileViewController.Purpose.myself, user: model)
                    let viewController = UserProfileViewController.instance(from: config)
                    self.show(viewController, sender: nil)
                }
            })
            self.tabBarController?.tabBar.isHidden = true
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
    }
    
    
}

extension ChatListViewController: UIPopoverPresentationControllerDelegate {
    
    // UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ChatListViewController {
    enum ExtendItem: Int {
        case manageGroup = 0
        case inviteFriend = 1
        case userProfile = 2
        case sweepQRCode = 3
        case searchGroup = 4
        case redEnvelope = 5
    }
}

/*
 // MARK: UITableViewDataSource
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return 2
 }
 
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 return 70
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "ChatHistoryTableViewCell") as! ChatHistoryTableViewCell
 
 
 cell.titleLabel.text = "Hopeseed 官方帐号"
 cell.coverImageView.image = UIImage.init(named: "userPresetS")
 cell.descriptionLabel.text = "您好，欢迎来到HopeSeed"
 cell.dateLabel.text = "上午 11:45"
 cell.countLabel.text = "\(indexPath.row + 1)"
 
 return cell
 }
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 tableView.deselectRow(at: indexPath, animated: true)
 
 let viewController = ChatViewController.instance(from: ChatViewController.Config(roomName: "789"))
 //        let viewController2 = UserProfileViewController.instance(from: UserProfileViewController.Config())
 //
 navigationController?.show(viewController, sender: nil)
 }
 */
