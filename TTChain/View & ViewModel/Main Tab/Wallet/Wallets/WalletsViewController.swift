//
//  WalletsViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletsViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = WalletsViewModel
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        self.configTableView()
        self.viewModel = WalletsViewModel.init(input: WalletsViewModel.Input(), output: WalletsViewModel.Output())
        self.viewModel.sectionModelSources.bind(to: self.tableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: bag)

    }
    
    var bag: DisposeBag = DisposeBag()
    var viewModel:ViewModel!
    
    typealias Constructor = Void

    private func configTableView() {
        self.tableView.rx.setDelegate(self).disposed(by: bag)
        tableView.register(WalletsTableSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: WalletsTableSectionHeaderView.nameOfClass)
        self.tableView.register(cellType: WalletsTableViewCell.self)
        self.tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var tableView: UITableView!
    
}

extension WalletsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletsTableSectionHeaderView.nameOfClass) as! WalletsTableSectionHeaderView
        let sectionModel = self.viewModel.sectionModelSources.value[section]
        headerView.expandButton.rx.klrx_tap.drive(onNext: { _ in
            self.viewModel.updateSectionModel(forSection: section)
            headerView.expandButton.isSelected = !headerView.expandButton.isSelected
        }).disposed(by: headerView.bag)
        let amtSource = self.viewModel.totalAssetAmtForCoin(coin: sectionModel.header)
        let fiatValSrc = self.viewModel.totalFiatAmoutForCoin(coin: sectionModel.header)
        headerView.config(sectionModel:sectionModel,amtSource:amtSource,fiatValSrc:fiatValSrc)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
