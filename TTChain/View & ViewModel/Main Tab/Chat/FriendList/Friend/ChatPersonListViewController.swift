//
//  ChatPersonListViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChatPersonListViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Config {
        var searchTextInOut: ControlProperty<String?>
        var searchStatus: BehaviorRelay<Bool>
    }
    
    typealias Constructor = Config
    var viewModel: ChatPersonListViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func config(constructor: ChatPersonListViewController.Config) {
        self.view.layoutSubviews()
        viewModel = ViewModel.init(input: ChatPersonListViewModel.InputSource(searchTextInOut: constructor.searchTextInOut,searchModeStatus:constructor.searchStatus), output: ())
        self.bindTableView()
        initTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }

    func initTableView() {
        tableView.register(InviteTableViewCell.nib, forCellReuseIdentifier: InviteTableViewCell.nameOfClass)
        tableView.register(FriendTableViewCell.nib, forCellReuseIdentifier: FriendTableViewCell.nameOfClass)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        
        // didSelected
        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
    }
    
    func bindTableView() {
        viewModel.dataSource.configureCell = {
            (datasource, tv, indexPath, friendModel) in
            
            switch (indexPath.section) {
            case 0:
                let cell = tv.dequeueReusableCell(withIdentifier: InviteTableViewCell.nameOfClass) as! InviteTableViewCell
                cell.config(friendRequestModel: friendModel as? FriendRequestInformationModel, onFriendRequestAction: { [weak self](requestResponse) in
                    guard let wSelf = self else {
                        return
                    }
                    wSelf.viewModel.handleFriendRequest(withStatus: requestResponse, forModel: friendModel as! FriendRequestInformationModel)
                })
                return cell
            case 1:
                let cell = tv.dequeueReusableCell(withIdentifier: FriendTableViewCell.nameOfClass) as! FriendTableViewCell
                cell.friendModel = friendModel as? FriendInfoModel
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        self.tableView.rx.itemSelected.asObservable().subscribe(onNext: { (indexPath) in
            switch indexPath.section {
            case 0:
                let model = self.viewModel.friendRequestList.value[indexPath.row]
                let config = UserProfileViewController.Config.init(purpose: UserProfileViewController.Purpose.notMyFriend, user: model)
                let viewController = UserProfileViewController.instance(from: config)
                self.navigationController?.pushViewController(viewController)
            case 1:
                let model = self.viewModel.friendsList.value[indexPath.row]
                let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: RoomType.pvtChat, chatTitle: model.nickName, roomID: model.roomId,chatAvatar:model.avatarUrl, uid: model.uid,entryPoint:.chatList))
                    self.navigationController?.pushViewController(vc)
            default:
                print("chat person item selected wron index")
            }
        }).disposed(by: bag)
        
        viewModel
            .sections
            .bind(to: tableView.rx.items(
                dataSource: viewModel.dataSource)
            )
            .disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = .white
        view.addSubview(statusBarView)
        
        view.backgroundColor = theme.palette.bgView_main
        tabBarController?.hidesBottomBarWhenPushed = true

    }
    override func renderLang(_ lang: Lang) {
        
    }
}

extension ChatPersonListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        self.viewModel.sections.map { $0[section] }.map { $0.title }.bind(to: label.rx.text).disposed(by: bag)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(label)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(18)-[view]-(18)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": label]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(12)-[view]-(6)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": label]))
        
        monitorTheme { (theme) in
            label.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 15))
            view.backgroundColor = theme.palette.bgView_sub
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
}
