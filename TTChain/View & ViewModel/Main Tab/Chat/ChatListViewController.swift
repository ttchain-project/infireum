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
            input: ChatListViewModel.Input(chatSelected: self.tableView.rx.itemSelected.asDriver().filter { $0.section == 2}.map { $0 }, chatRefresh: self.refresher.rx.controlEvent(.valueChanged).asDriver()),
            output: ChatListViewModel.Output(selectedChat: {[weak self] model in
                guard let `self` = self else {
                    return
                }
                self.chatSelected(forModel: model)
                }, onJoinGroup : { [weak self] message in
                    guard let `self` = self else {
                        return
                    }
                    self.showAlert(title: "", message: message)
                },onShowingHUD: { [weak self] status in
                    guard let `self` = self else {
                        return
                    }
                    if status {
                        self.hud.startAnimating(inView: self.view)
                    }else {
                        self.hud.stopAnimating()
                    }
            })
        )
        
        initTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
        bindElements()
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
        self.viewModel.onReceiveRecordsUpdateResponse.subscribe(onNext: { (_) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
        }).disposed(by: bag)
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
   
    private let refresher = UIRefreshControl.init()

    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
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

        self.tabBarController?.tabBar.isHidden = false
        
        if IMUserManager.manager.userLoginStatus.value == .deviceIDNotMatched {
            showTransferAlert()
        } else {
            self.viewModel.getList()
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
                        self.viewModel.getList()
                    } else {
                        let alertController = UIAlertController(title: LM.dls.backupChat_alert_password_mismatch, message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: LM.dls.g_ok, style: .default, handler: {
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
        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: model.roomType, chatTitle: model.displayName, roomID: model.roomId,chatAvatar:model.img, uid: model.privateMessageTargetUid))
        self.navigationController?.pushViewController(vc)
    }
    
    func bindElements() {
        self.qrcodeButton.rx.tap.asDriver()
            .drive(onNext: {
                _ in
                guard let uid = IMUserManager.manager.userModel.value?.uID else {
                    return
                }
                let vc = UserIMQRCodeViewController.instance(from: UserIMQRCodeViewController.Config(uid:uid, title:LM.dls.myQRCode))
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
        tableView.register(GroupInviteTableViewCell.nib, forCellReuseIdentifier: GroupInviteTableViewCell.cellIdentifier())
        tableView.register(InviteTableViewCell.nib, forCellReuseIdentifier: InviteTableViewCell.cellIdentifier())
        tableView.addSubview(refresher)
    }
    
    func bindViewModel() {
        
        viewModel.dataSource.configureCell = {
            (datasource, tv, indexPath, model) in
            
            switch (indexPath.section) {
            case 0:
                let cell = tv.dequeueReusableCell(withIdentifier: InviteTableViewCell.nameOfClass) as! InviteTableViewCell
                guard model is FriendRequestInformationModel else {
                    return cell
                }
                let friendRequestModel = model as! FriendRequestInformationModel
                
                cell.config(friendRequestModel: friendRequestModel, onFriendRequestAction: { [weak self](response) in
                    
                    guard let wSelf = self else {
                        return
                    }
                    wSelf.viewModel.handleFriendRequest(withStatus: response, forModel: friendRequestModel)
                })
                
                return cell
            case 1:
                let cell = tv.dequeueReusableCell(withIdentifier: GroupInviteTableViewCell.nameOfClass) as! GroupInviteTableViewCell
                guard model is UserGroupInfoModel else {
                    return cell
                }
                let groupModel = model as! UserGroupInfoModel
                cell.config(groupRequestModel: groupModel, onGroupRequestAction: { [weak self](response) in
                    guard let wSelf = self else {
                        return
                    }
                    wSelf.viewModel.handleGroupRequest(withAction:response, forModel: groupModel)
                })
                return cell
            case 2:
                let cell = tv.dequeueReusableCell(withIdentifier: ChatHistoryTableViewCell.nameOfClass) as! ChatHistoryTableViewCell
                
                guard model is CommunicationListModel else {
                    return cell
                }
                let chatListModel = model as! CommunicationListModel
                cell.config(model: chatListModel)
                cell.rx.longPressGesture().skip(1).subscribe(onNext: { (_) in
                    if chatListModel.roomType == .pvtChat {
                        self.showDeletePopUp(forChat: chatListModel)
                    }
                }).disposed(by: cell.disposeBag)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        viewModel
            .chatListSections
            .bind(to: tableView.rx.items(
                dataSource: viewModel.dataSource)
            )
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
        self.navigationItem.title = dls.tab_social
    }
    
    @objc func settingsButtonTapped() {
    
    }
    
    func toFriendList(purpose: FriendListContainerViewController.Purpose) {
        let viewController = FriendListContainerViewController.instance(from: FriendListContainerViewController.Constructor(purpose: purpose))
        self.show(viewController, sender: nil)
    }
    
    func showAddFriendsList() {
        
        let addAction = UIAlertAction.init(title: LM.dls.user_profile_button_add_friend, style: .default) { _ in
            self.show(InviteFriendViewController.instance(), sender: self)
        }
        let joinGroupAction = UIAlertAction.init(title: LM.dls.join_group, style: .default) { _ in
            self.showQRCodeVCForJoinGroup()
        }
        let createGroupAction = UIAlertAction.init(title: LM.dls.create_group, style: .default) { _ in
            let viewModel = GroupInformationViewModel()
            let viewController = GroupInformationViewController.init(viewModel: viewModel)
            self.show(viewController, sender: nil)
        }
        let cancelAction = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel) { _ in
            
        }
        let vc = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
        vc.addAction(addAction)
        vc.addAction(joinGroupAction)
        vc.addAction(createGroupAction)
        vc.addAction(cancelAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func showDeletePopUp(forChat chat: CommunicationListModel) {
        let alert = UIAlertController.init(title: LM.dls.chat_history_delete_chat_title, message: LM.dls.chat_history_delete_chat_message, preferredStyle: .alert)
        let actionYes = UIAlertAction.init(title: LM.dls.g_confirm, style: .default) {[weak self] _ in
            guard let `self` = self else {
                return
            }
            let parameter = DeleteChatHistoryAPI.Parameter.init(roomId: chat.roomId)
            Server.instance.deleteChatHistory(parameter: parameter).asObservable().subscribe(onNext: { result in
                switch result {
                case .failed(error: let error):
                    DLogError(error)
                case .success(let model):
                    if model.status {
                        self.viewModel.getCommunicationList()
                    }
                }
            }).disposed(by:self.bag)
        }
        let cancelAction = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        alert.addAction(actionYes)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func toEditProfile() {
        let viewController = ProfileViewController.instance()
        self.show(viewController, sender: nil)
    }
    
    func showQRCodeVCForJoinGroup() {
        
        let qrCode = OWQRCodeViewController.navInstance(from: OWQRCodeViewController._Constructor(
            purpose: .userId,
            resultCallback: { [weak self]
                (result, purpose, scanningType) in
                switch result {
                case .userId(let id):
                    print("ID",id)
                    guard self != nil else {
                        return
                    }
                    self?.viewModel.joinGroup(groupID: id)
                default: return
                }
            },
            isTypeLocked: true
        ))
        
        //            qrCodeVCNav = qrCode
        self.present(qrCode, animated: true, completion: nil)
    }
    
    
}

extension ChatListViewController: UIPopoverPresentationControllerDelegate {
    
    // UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}



