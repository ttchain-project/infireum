//
//  ChatGroupListViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChatGroupListViewController: KLModuleViewController, KLVMVC {
    
    //
    struct Config {
        var searchTextInOut: ControlProperty<String?>
        var searchStatus: BehaviorRelay<Bool>
    }
    
    typealias Constructor = Config

    //
    @IBOutlet weak var tableView: UITableView!
    
    
    //
    private let refresher = UIRefreshControl.init()

    var viewModel: GroupChatListViewModel!
    var bag: DisposeBag = DisposeBag()
    
//    var items: [UserGroupInfoModelSection] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func config(constructor: ChatGroupListViewController.Config) {
        self.view.layoutIfNeeded()
        viewModel = ViewModel.init(input:ViewModel.InputSource(searchTextInOut: constructor.searchTextInOut,searchModeStatus:constructor.searchStatus), output: ())
        self.bindTableView()
        initTableView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    func initTableView() {
        tableView.register(GroupInviteTableViewCell.nib, forCellReuseIdentifier: GroupInviteTableViewCell.nameOfClass)
        tableView.register(GroupChatTableViewCell.nib, forCellReuseIdentifier: GroupChatTableViewCell.nameOfClass)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        
        // didSelected
        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let group = self.viewModel.groupList.value[indexPath.row]
            self.chatSelected(forModel: group)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
    }
    
    func bindTableView() {
        viewModel.dataSource.configureCell = {
            (datasource, tv, indexPath, groupModel) in
            
            switch (indexPath.section) {
            case 0:
                let cell = tv.dequeueReusableCell(withIdentifier: GroupInviteTableViewCell.nameOfClass) as! GroupInviteTableViewCell
                cell.config(groupRequestModel: groupModel, onGroupRequestAction: { [weak self](response) in
                    guard let wSelf = self else {
                        return
                    }
                    wSelf.viewModel.handleGroupRequest(withAction:response, forModel: groupModel)
                })
                return cell
            case 1:
                let cell = tv.dequeueReusableCell(withIdentifier: GroupChatTableViewCell.nameOfClass) as! GroupChatTableViewCell
                cell.groupModel = groupModel
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        viewModel
            .sections
            .bind(to: tableView.rx.items(
                dataSource: viewModel.dataSource)
            )
            .disposed(by: bag)
        
    }
    
    override func renderLang(_ lang: Lang) {
        
    }
    
    override func renderTheme(_ theme: Theme) {
        view.backgroundColor = theme.palette.bgView_main
    }
    
    private func chatSelected(forModel model: UserGroupInfoModel) {
        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: model.isPrivate ? .group : .channel, chatTitle: model.groupName, roomID: model.imGroupId, chatAvatar: model.headImg, uid: nil,entryPoint:.chatList))
        show(vc, sender: self)
    }
}

extension ChatGroupListViewController: UITableViewDelegate {
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
