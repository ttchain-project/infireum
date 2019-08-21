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
    @IBOutlet weak var searchBar: UISearchBar!
    
    typealias Constructor = Void
    var viewModel: ChatPersonListViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchFriendsList()
    }

    func config(constructor: Void) {
        self.view.layoutSubviews()
        
        let searchDriver = Observable.combineLatest(
            self.searchBar.rx.text,
            self.searchBar.rx.textDidEndEditing.startWith(())
            ).map {_ in return self.searchBar.text ?? ""}.distinctUntilChanged().asDriver(onErrorJustReturn: "")
        
        viewModel = ViewModel.init(input: ChatPersonListViewModel.InputSource(searchTextInOut: searchDriver), output: ())
        initTableView()
        self.bindTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }

    func initTableView() {
        tableView.register(InviteTableViewCell.nib, forCellReuseIdentifier: InviteTableViewCell.nameOfClass)
        tableView.register(FriendTableViewCell.nib, forCellReuseIdentifier: FriendTableViewCell.nameOfClass)
        tableView.backgroundColor = .clear
        tableView.rx.setDelegate(self).disposed(by: bag)
        
        self.searchBar.rx.cancelButtonClicked.asDriver().drive(onNext: { _ in
            self.searchBar.endEditing(true)
        }).disposed(by: bag)
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
                let config = UserProfileViewController.Config.init(purpose: UserProfileViewController.Purpose.friendRequest, user: model)
                let viewController = UserProfileViewController.navInstance(from: config)
                self.present(viewController, animated: true)
            case 1:
                let model = self.viewModel.friendsList.value[indexPath.row]
                let viewController = ChatViewController.navInstance(from: ChatViewController.Config(roomType: RoomType.pvtChat, chatTitle: model.nickName, roomID: model.roomId,chatAvatar:model.avatarUrl, uid: model.uid,entryPoint:.chatList))
                self.present(viewController, animated: true)
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
        view.backgroundColor = theme.palette.bgView_main
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
        if section == 0 && self.viewModel.friendRequestList.value.count == 0 {
            return 0
        }
        return 35.0
    }
}
