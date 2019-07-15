//
//  SearchMemberViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift

class SearchMemberViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { searchBar.rx.text.orEmpty.bind(to: viewModel.input.searchText).disposed(by: disposeBag) }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(cellType: AddGroupMemberTableViewCell.self)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.rx.itemSelected.map({ $0.row }).bind(to: viewModel.input.tableViewItemSelected).disposed(by: disposeBag)
            tableView.rx.itemDeselected.map({ $0.row }).bind(to: viewModel.input.tableViewItemDeselected).disposed(by: disposeBag)
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(cellType: AddGroupMemberCollectionViewCell.self)
            collectionView.rx.itemSelected.map({ $0.row }).bind(to: viewModel.input.collectionViewItemSelected).disposed(by: disposeBag)
        }
    }
    
    lazy var hud:KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            spinnerColor: TM.palette.hud_spinner
        )
    }()
    
    private let viewModel: SearchMemberViewModel
    private let disposeBag = DisposeBag()
    private lazy var confirmBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: LM.dls.g_confirm, style: .plain, target: self, action: nil)
        
        viewModel.output.addGroupMemberCollectionViewCellModels
            .map({ $0.count > 0 ? LM.dls.g_ok + "( \($0.count) )" : LM.dls.g_ok })
            .bind(to: barButtonItem.rx.title).disposed(by: disposeBag)
        
        viewModel.output.addGroupMemberCollectionViewCellModels
            .map({ $0.count > 0 })
            .bind(to: barButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.viewModel.input.confirmButtonSubject.onNext(())
        }).disposed(by: disposeBag)
        
        return barButtonItem
    }()
    
    init(viewModel: SearchMemberViewModel) {
        self.viewModel = viewModel
        super.init(nibName: SearchMemberViewController.className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpRx()
    }
    
    private func setUpView() {
        navigationItem.rightBarButtonItem = confirmBarButtonItem
    }
    
    private func setUpRx() {
        viewModel.output.addGroupMemberTableViewCellModels.bind(to: tableView.rx.items(cellIdentifier: AddGroupMemberTableViewCell.className, cellType: AddGroupMemberTableViewCell.self)) {
            _, source, cell in
            cell.viewModel = source
            }.disposed(by: disposeBag)
        
        viewModel.output.addGroupMemberCollectionViewCellModels.bind(to: collectionView.rx.items(cellIdentifier: AddGroupMemberCollectionViewCell.className, cellType: AddGroupMemberCollectionViewCell.self)) {
            _, source, cell in
            cell.viewModel = source
            }.disposed(by: disposeBag)
        
        viewModel.input.hudAnimationSubject.subscribe { (event) in
            if let status = event.element,status  {
                self.hud.startAnimating(inView:self.view)
            }else {
                self.hud.stopAnimating()
            }
        }.disposed(by: disposeBag)
        
        self.viewModel.output.errorMessageSubject.bind(to:self.rx.message).disposed(by:disposeBag)
    }
}
