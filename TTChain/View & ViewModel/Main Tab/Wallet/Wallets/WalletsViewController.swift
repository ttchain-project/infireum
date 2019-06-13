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
        
        viewModel.dataSource.configureCell = { [weak self] (dataSource, tv, indexPath, asset) -> WalletsTableViewCell in
            guard let `self` = self else {
                return WalletsTableViewCell()
            }
            let cell = tv.dequeueReusableCell(with: WalletsTableViewCell.self, for: indexPath)
            cell.titleLabel.text = asset.wallet?.name
            
            let amtSource = self.viewModel.amt(ofAsset: asset).asObservable()
            let fiatValueSource = self.viewModel.fiatValue(ofAsset: asset).asObservable()
            let fiatSource = self.viewModel.fiat.asObservable()
            
            amtSource
                .flatMapLatest { $0 }
                .map {
                    amt -> String in
                    guard let _amt = amt else {
                        return "--"
                    }
                    return _amt
                        .asString(digits: C.Coin.min_digit,
                                  force: true,
                                  maxDigits: Int(asset.coin!.digit),
                                  digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                        .disguiseIfNeeded()
                    //                .asString(digits: Int(coin.digit)).disguiseIfNeeded()
                }
                .bind(to: cell.assetBalance.rx.text)
                .disposed(by: cell.bag)
            
            Observable.combineLatest(
                fiatValueSource.flatMapLatest { $0 },
                fiatSource
                )
                .map {
                    fiatValue, fiat -> String in
                    return fiat.fullSymbol + (fiatValue?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--")
                }
                .bind(to: cell.fiatValue.rx.text)
                .disposed(by: cell.bag)
            return cell
        }
        
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

        headerView.titleLabel.text = sectionModel.header.inAppName
        headerView.expandButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
            self.viewModel.updateSectionModel(forSection: section)
            headerView.expandButton.isSelected = !headerView.expandButton.isSelected
        }).disposed(by: headerView.bag)
        headerView.expandButton.isSelected = sectionModel.isShowing
        headerView.imageView.image = sectionModel.header.iconImg
        let amtSource = self.viewModel.totalAssetAmtForCoin(coin: sectionModel.header)
        
            amtSource
            .flatMapLatest { $0 }
            .map {
                amt -> String in
                guard let _amt = amt else {
                    return "--"
                }
                
                return _amt
                    .asString(digits: C.Coin.min_digit,
                              force: true,
                              maxDigits: Int(sectionModel.header.digit),
                              digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                    .disguiseIfNeeded()
                //                .asString(digits: Int(coin.digit)).disguiseIfNeeded()
            }
            .bind(to: headerView.totalBalance.rx.text)
            .disposed(by: bag)
        
        
        let fiatValSrc = self.viewModel.totalAssetAmtForCoin(coin: sectionModel.header)
        
        Observable.combineLatest(
            fiatValSrc.flatMapLatest { $0 },
            FiatManager.instance.fiat.asObservable()
            )
            .map {
                fiatValue, fiat -> String in
                return fiat.fullSymbol + (fiatValue?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--")
            }
            .bind(to: headerView.fiatValue.rx.text)
            .disposed(by: bag)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
