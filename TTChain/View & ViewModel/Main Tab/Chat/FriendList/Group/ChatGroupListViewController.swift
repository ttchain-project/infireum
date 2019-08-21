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
    
    typealias Constructor = Void

    //
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    //
    private let refresher = UIRefreshControl.init()

    var viewModel: GroupChatListViewModel!
    var bag: DisposeBag = DisposeBag()
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchGroupList()
    }
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        let searchDriver = Observable.combineLatest(
            self.searchBar.rx.text,
            self.searchBar.rx.textDidEndEditing.startWith(())
            ).map {_ in return self.searchBar.text ?? ""}.distinctUntilChanged().asDriver(onErrorJustReturn: "")

        
        viewModel = ViewModel.init(input:ViewModel.InputSource(searchTextInOut: searchDriver),
                                   output: GroupChatListViewModel.Output(onShowingHUD: {status in
                                    if status {
                                        self.hud.startAnimating(inView:self.view)
                                    }else {
                                        self.hud.stopAnimating()
                                    }
                                   }))
        viewModel.output.messageSubject.bind(to: self.rx.message).disposed(by: bag)

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
        
        self.searchBar.rx.cancelButtonClicked.asDriver().drive(onNext: { _ in
            self.searchBar.endEditing(true)
        }).disposed(by: bag)
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
        let vc = ChatViewController.navInstance(from: ChatViewController.Config(roomType: model.isPrivate ? .group : .channel, chatTitle: model.groupName, roomID: model.imGroupId, chatAvatar: model.headImg, uid: nil,entryPoint:.chatList))
        present(vc, animated: true)
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
        if section == 0 && self.viewModel.groupRequestList.value.count == 0 {
            return 0
        }
        return 35.0
    }
}
