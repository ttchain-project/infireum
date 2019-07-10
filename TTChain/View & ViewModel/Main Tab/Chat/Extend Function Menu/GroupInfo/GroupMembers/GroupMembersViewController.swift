//
//  GroupMembersViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/9.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class GroupMembersViewController: KLModuleViewController,KLVMVC {

    var bag: DisposeBag = DisposeBag()
    struct Config {
        let groupInfo:UserGroupInfoModel
    }
    
    typealias ViewModel = GroupMembersViewModel
    var viewModel: GroupMembersViewModel!
    typealias Constructor = Config
    func config(constructor: GroupMembersViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = GroupMembersViewModel.init(input: GroupMembersViewModel.Input(groupId: constructor.groupInfo.groupID, groupMembers: constructor.groupInfo.membersArray ?? []), output: ())
        self.setupTableView()
        if constructor.groupInfo.groupOwnerUID != IMUserManager.manager.userModel.value?.uID {
            self.addMemberView.isHidden = true
        }
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    @IBOutlet weak var addMemberLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var addMemberView:UIView! {
        didSet {
            addMemberView.rx.klrx_tap.drive(onNext: {[unowned self] in
                self.presentAddGroupMemberView()
            }).disposed(by: bag)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func renderTheme(_ theme: Theme) {
        self.tableView.backgroundColor = .clear
        self.view.backgroundColor = theme.palette.bgView_main
        self.addMemberView.backgroundColor = .clear
        self.addMemberLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
    }
    override func renderLang(_ lang: Lang) {
        self.addMemberLabel.text = lang.dls.group_invite_member_title
        self.title = lang.dls.group_member_mgmgt_title
    }
    
    func setupTableView() {
        self.tableView.register(cellType: FriendTableViewCell.self)
        self.viewModel.groupMembers.bind(to: self.tableView.rx.items) { (tv, row, model) in
            let cell = tv.dequeueReusableCell(with: FriendTableViewCell.self, for: IndexPath.init(row: row, section: 0))
            cell.descriptionLabel.text = model.nickName
            cell.avatarImageView.setProfileImage(image: model.avatarUrl, tempName: model.nickName)
            return cell
        }.disposed(by: bag)
        
        self.tableView.rx.setDelegate(self).disposed(by: bag)
    }
    
    private func presentAddGroupMemberView() {
        
        let viewModel = SearchMemberViewModel.init(groupMemberId: self.viewModel.input.groupId)
        let viewController = SearchMemberViewController(viewModel: viewModel)
        viewModel.output.selectedFriends.subscribe(onNext: {
            [unowned self] models in
            viewController.pop(sender: self)
        }).disposed(by: self.bag)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

extension GroupMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

}
