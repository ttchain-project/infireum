//
//  ChatViewController.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import IQKeyboardManagerSwift

final class ChatViewController: KLModuleViewController, KLVMVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardView: ChatKeyboardView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewToHideKeyboard: UIView!
    private lazy var profileBarButtonButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "iconCommunicationUserDark.png"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            switch self.viewModel.input.roomType {
            case .group, .channel:
                guard let userGroupInfoModel = self.viewModel.groupInfoModel.value else { return }
                let viewModel = GroupInformationViewModel(userGroupInfoModel: userGroupInfoModel)
                let viewController = GroupInformationViewController.init(viewModel: viewModel)
                self.show(viewController, sender: nil)
            case .pvtChat: return
            }
        }).disposed(by: bag)
        return barButtonButton
    }()
    
    let IQKeyboardManagerEnableStatus = IQKeyboardManager.shared.enable
    private var friendInfoModel: FriendInfoModel?
    var viewModel: ChatViewModel!
    var bag: DisposeBag = DisposeBag()

    private var isNavigatingToUserProfile: Bool = false
    struct Config {
        var roomType:RoomType
        var chatTitle:String
        var roomID:String
        var chatAvatar:UIImage?
    }
    
    typealias Constructor = Config
    
    func config(constructor: ChatViewController.Config) {
        view.layoutIfNeeded()
        //
        viewModel = ViewModel.init(
            input: ChatViewModel.Input.init(
                roomType: constructor.roomType,
                chatTitle: constructor.chatTitle,
                roomID: constructor.roomID,
                chatAvatar: constructor.chatAvatar,
                messageText: self.keyboardView.textField
            ),
            output: ())
        
        initTableView()
        initKeyboardView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        bindViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        setUpScrennShotDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = IQKeyboardManagerEnableStatus
        isNavigatingToUserProfile = false
    }

    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_2)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 18))
        changeNavShadowVisibility(true)
        tableView.backgroundColor = palette.nav_bg_clear
        changeLeftBarButton(target: self, selector: #selector(backButtonTapped), tintColor: palette.nav_item_2, image:#imageLiteral(resourceName: "arrowNavBlack") )
        self.viewToHideKeyboard.backgroundColor = palette.bgView_main
        navigationItem.rightBarButtonItem = viewModel.input.roomType == .pvtChat ? nil : profileBarButtonButton
        navigationItem.rightBarButtonItem?.tintColor = palette.nav_item_2
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.title = self.viewModel.input.chatTitle
    }
    
    func initTableView() {
        tableView.register(ChatMessageTableViewCell.nib, forCellReuseIdentifier: ChatMessageTableViewCell.nameOfClass)
    }
    
    func bindViewModel() {
        
        viewModel.messages.bind(to: tableView.rx.items(cellIdentifier: ChatMessageTableViewCell.cellIdentifier(), cellType: ChatMessageTableViewCell.self)) {[unowned self]
            row, record, cell in
                switch self.viewModel.input.roomType {
                case .group,.channel:
                    cell.config(forMessage: record, leftImage: self.viewModel.memberAvatarMapping[record.userName ?? ""], leftImageAction: { id in
                        guard let friendModel = self.viewModel.getFriendsModel(for: record.userName ?? "") else {
                            return
                        }
                        self.toUserProfileVC(forFriend: friendModel)

                    })
                case .pvtChat:
                    cell.config(forMessage: record, leftImage: self.viewModel.input.chatAvatar , leftImageAction: { id in
                        guard let friendModel = self.viewModel.getFriendsModel(for: record.userName ?? "") else {
                            return
                        }
                        self.toUserProfileVC(forFriend: friendModel)
                        
                    })
                }
            }
            .disposed(by: bag)
        
        viewModel.shouldScrollToBottom.asObservable().subscribe(onNext: {[unowned self] in
            self.tableView.scrollToLastRow()
        })
            .disposed(by: bag)
        
        viewModel.shouldRefreshCellsForDataUpdate.asObservable().subscribe(onNext: {[unowned self] in
            self.tableView.reloadData()
        }).disposed(by: bag)
        
        self.viewModel.privateChat.isPrivateChatOn
            .asObservable().map { status in
                if status {
                    self.keyboardView.privateChatDurationTitleLabel.text = "Private Chat:" + self.viewModel.privateChat.privateChatDuration!.title
                }else {
                    self.keyboardView.privateChatDurationTitleLabel.text = ""
                }
                return !status
            }
            .bind(to: self.keyboardView.privateChatBannerView.rx.isHidden)
            .disposed(by: bag)
        Observable.just(self.viewModel.privateChat.privateChatDuration).asObservable().subscribe(onNext: { (duration) in
            
        }).disposed(by: bag)
    }
    
    @objc func backButtonTapped() {
        self.viewModel.postChatSection()
        self.viewModel.timerSub?.dispose()
        self.navigationController?.popViewController(animated: true)
    }
    
    func initKeyboardView() {
        
        
        keyboardView.config(input: ChatKeyboardView.Input(),
                            output: ChatKeyboardView.Output.init(didChangeViewHeight: { (value) in
                                self.view.setNeedsLayout()
                                self.keyboardViewHeight.constant = value
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.view.layoutIfNeeded()
                                })
                            }, onSelectChatFunction: { [unowned self]function in
                                switch function.type {
                                case .startSecretChat:
                                    self.toChatSecretViewController()
                                default:
                                    print("Pending implementation")
                                }
                            }))
        
        
        keyboardView
            .sendButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: {[unowned self] in
                self.viewModel.sendMessage()
                self.keyboardView.textField.text = ""
                self.keyboardView.textField.sendActions(for: .valueChanged)

            })
            .disposed(by: bag)
        
        keyboardView.textField.rx.controlEvent([.editingDidBegin,.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { _ in
              self.tableView.scrollToLastRow()
            })
            .disposed(by: bag)
        
    }
    
    func toChatSecretViewController() {
        let vc = PrivateChatSettingViewController.instance(from: PrivateChatSettingViewController.Config(selectedDurationIfAny:self.viewModel.privateChat.privateChatDuration, privateModeStatusIfAny:self.viewModel.privateChat.isPrivateChatOn.value))
        
        vc.onChatSecretChoicesComplete.asObservable().subscribe(onNext: {[unowned self] (duration, isSelected) in
            self.viewModel.privateChat.privateChatDuration = duration
            self.viewModel.privateChat.isPrivateChatOn.accept(isSelected)
        }).disposed(by: bag)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func toUserProfileVC(forFriend friend: FriendModel) {
        //This flag is a terrible hack, since we are reloading the data of the table constantly,
        //we keep getting multiple event for action on cell component
        //Hence to avoid the multiple VC pushes.
        //Hopefully this changes to websocket implementation in future. At that time, remove this comment and save me from misery!!
        if isNavigatingToUserProfile {
            return
        }
        self.isNavigatingToUserProfile = true
        var purpose : UserProfileViewController.Purpose
        if friend is GroupMemberModel {
            let friends = friend as! GroupMemberModel
            purpose = friends.isFriend! ? .myFriend : .notMyFriend
        }else {
            purpose = .myFriend
        }
        let config = UserProfileViewController.Config.init(purpose: purpose, user: friend)
        let viewController = UserProfileViewController.instance(from: config)
        self.show(viewController, sender: nil)
    }
    
    private func setUpView() {
        
    }
    
    private func setUpScrennShotDetection() {
        NotificationCenter.default.rx.notification(Notification.Name.UIApplicationUserDidTakeScreenshot).subscribe(onNext: {
            [unowned self] _ in
            if self.viewModel.privateChat.isPrivateChatOn.value {
                DLogInfo("User Capture screen with private chat.")
                
            }
        }).disposed(by: bag)
    }
}

extension UITableView {
    func scrollToLastRow() {
        if self.numberOfRows() > 0 {
            let indexPath = IndexPath.init(row: self.numberOfRows() - 1, section: 0)
            DispatchQueue.main.async {
                self.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
}

