//
//  ForwardListViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources


final class ForwardListViewController: KLModuleViewController, KLVMVC {
    
    enum ListType {
        case Chat, Friends, Group
    }
    
    var viewModel: ForwardListViewModel!
    
    public let forwardChatToSelection : PublishRelay<ChatListPage> = PublishRelay.init()
    
    var onForwardChatToSelection : Observable<(ChatListPage)> {
        return forwardChatToSelection.asObservable()
    }

    func config(constructor: ForwardListViewController.Config) {
        self.view.layoutIfNeeded()
        
        self.viewModel = ViewModel.init(input: ForwardListViewModel.Input(listType: constructor.listType,
                                                                          messageModel: constructor.messageModel,
                                                                          selectionIndex: self.tableView.rx.itemSelected.asDriver().map {$0.row}),output:ForwardListViewModel.Output(selectedChat: { model in
                                                                            self.forwardChatToSelection.accept(model)
                                                                          }))
        
        self.configTableView()
    }
    
    typealias ViewModel = ForwardListViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias Constructor = Config
    
    struct Config {
        var messageModel:MessageModel
        var listType: ListType
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func configTableView() {
        tableView.register(FriendTableViewCell.nib, forCellReuseIdentifier: FriendTableViewCell.cellIdentifier())
        
        self.viewModel.forwardList.bind(to: tableView.rx.items(cellIdentifier: FriendTableViewCell.cellIdentifier(), cellType: FriendTableViewCell.self)) {
            row, model, cell in
            switch model {
            case is CommunicationListModel:
                let commModel = model as! CommunicationListModel
                cell.config(title: commModel.displayName, image:commModel.img)
            case is FriendModel:
                let friendModel = model as! FriendInfoModel
                cell.config(title: friendModel.nickName, image: friendModel.avatarUrl)
            case is UserGroupInfoModel:
                let groupModel = model as! UserGroupInfoModel
                cell.config(title: groupModel.groupName, image: groupModel.headImg)
            default:
                print("CommunicationListModel")
            }
        }.disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.forward
    }
    
}
