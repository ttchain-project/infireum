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
//        initNavigationBarItems()
        initTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
        bindElements()
    }
    
    typealias ViewModel = ChatListViewModel
    
    typealias Constructor = Void
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var qrcodeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var requestListButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
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
                        let alertController = UIAlertController(title: "钱包帐号与移转备份密码不符", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "好", style: .default, handler: {
                            _ in
                            self.showTransferAlert()
                        }))
                        self.present(alertController, animated: true, completion: nil)

                    }
                })
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func chatSelected(forModel model:CommunicationListModel) {
        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: model.roomType, chatTitle: model.displayName, roomID: model.roomId,chatAvatar:model.avatar, uid: model.privateMessageTargetUid))
        self.navigationController?.pushViewController(vc)
    }
    
    func bindElements() {
        self.qrcodeButton.rx.tap.asDriver()
            .drive(onNext: {
                _ in
                let model = FriendRequestInformationModel.init(imUser: IMUserManager.manager.userModel.value!)
                let vc = UserIMQRCodeViewController.instance(from: model)
                self.navigationController?.pushViewController(vc)
            })
            .disposed(by: bag)
        self.editButton.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.toEditProfile()
            })
            .disposed(by: bag)
        
        self.addButton.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.showAddFriendsList()
            })
            .disposed(by: bag)
        self.searchButton.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.toFriendList(purpose: .Search)
            })
            .disposed(by: bag)
        
        self.requestListButton.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.toFriendList(purpose: .Browse)
            })
            .disposed(by: bag)
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
        self.stackView.backgroundColor = UIColor.gray
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.chat_list_title
    }
    
    @objc func settingsButtonTapped() {
    
    }
    
    func toFriendList(purpose: FriendListContainerViewController.Purpose) {
        let viewController = FriendListContainerViewController.instance(from: FriendListContainerViewController.Constructor(purpose: purpose))
        self.show(viewController, sender: nil)
    }
    
    func showAddFriendsList() {
        
        let addAction = UIAlertAction.init(title: "Add a friend", style: .default) { _ in
            self.show(InviteFriendViewController.instance(), sender: self)
        }
//        let joinGroupAction = UIAlertAction.init(title: "Join A group", style: .default) { _ in
//
//        }
        let createGroupAction = UIAlertAction.init(title: "Create A Group", style: .default) { _ in
            let viewModel = GroupInformationViewModel()
            let viewController = GroupInformationViewController.init(viewModel: viewModel)
            self.show(viewController, sender: nil)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { _ in
            
        }
        let vc = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
        vc.addAction(addAction)
//        vc.addAction(joinGroupAction)
        vc.addAction(createGroupAction)
        vc.addAction(cancelAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func toSearchFriendList() {
        self.show(SearchGroupViewController.instance(), sender: self)
    }
    
    func toEditProfile() {
//        let user = IMUserManager.manager.userModel.value ?? IMUser.init(uID: String(), nickName: String(), introduction: String(), headImg: nil)
//        let model = FriendRequestInformationModel.init(imUser: user)
//        let config = UserProfileViewController.Config.init(purpose: UserProfileViewController.Purpose.myself, user: model)
        let viewController = ProfileViewController.instance()
        self.show(viewController, sender: nil)
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
