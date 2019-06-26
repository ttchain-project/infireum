//
//  ChatMessageListViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/20.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class ChatMessageListViewController: KLModuleViewController,KLVMVC {
   
    
    typealias Constructor = Void
    var bag: DisposeBag = DisposeBag()
    typealias ViewModel = ChatMsgListViewModel
    var viewModel: ChatMsgListViewModel!
   
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        
        let searchDriver = Observable.combineLatest(
            self.searchBar.rx.text,
            self.searchBar.rx.textDidEndEditing.startWith(())
            ).map {_ in return self.searchBar.text ?? ""}.distinctUntilChanged().asDriver(onErrorJustReturn: "")
        
        self.viewModel = ViewModel.init(input: ChatMsgListViewModel.Input(chatSelected: self.tableView.rx.itemSelected.asDriver().map { $0 },
                                                                          chatRefresh: self.refreshControl.rx.controlEvent(.valueChanged).asDriver(),
                                                                          searchText: searchDriver),
                                        output: ChatMsgListViewModel.Output(selectedChat: {model in
                                            
                                        }, onShowingHUD:{ status in
                                            if status {
                                                self.hud.startAnimating(inView: self.view)
                                            }else {
                                                self.hud.stopAnimating()
                                            }
                                        }))
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        setupTableView()
        bindUI()
    }
    
    let refreshControl = UIRefreshControl.init()

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.getCommunicationList()
    }
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    func setupTableView() {
        self.tableView.addSubview(self.refreshControl)
        tableView.register(ChatHistoryTableViewCell.nib, forCellReuseIdentifier: ChatHistoryTableViewCell.cellIdentifier())
    }
    override func renderTheme(_ theme: Theme) {
        
    }
    override func renderLang(_ lang: Lang) {
        
    }
    
    func bindUI() {
        self.viewModel.communicationList.bind(to: self.tableView.rx.items) ({ (tv, index, model) -> ChatHistoryTableViewCell in
            let cell = tv.dequeueReusableCell(withClass: ChatHistoryTableViewCell.self)
            cell.config(model: model)
            return cell
        }).disposed(by: bag)
        
        self.tableView.rx.modelSelected(CommunicationListModel.self).asObservable().subscribe(onNext: { (model) in
            let vc = ChatViewController.navInstance(from: ChatViewController.Config(roomType: model.roomType, chatTitle: model.displayName, roomID: model.roomId,chatAvatar:model.img, uid: model.privateMessageTargetUid,entryPoint:.chatList))
            self.present(vc, animated: true, completion: nil)

        }).disposed(by: bag)
        
        self.searchBar.rx.cancelButtonClicked.asDriver().drive(onNext: { _ in
            self.searchBar.endEditing(true)
        }).disposed(by: bag)
    }
}
