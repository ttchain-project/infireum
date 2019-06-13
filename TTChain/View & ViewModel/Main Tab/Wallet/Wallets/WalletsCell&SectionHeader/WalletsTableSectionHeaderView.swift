//
//  WalletsTableSectionHeaderView.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletsTableSectionHeaderView : UITableViewHeaderFooterView {
    
    var bag = DisposeBag()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var fiatValue: UILabel!
    
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(sectionModel:SectionOfTable, amtSource:BehaviorRelay<BehaviorRelay<Decimal?>>,fiatValSrc:BehaviorRelay<BehaviorRelay<Decimal?>>) {
        
        self.titleLabel.text = sectionModel.header.inAppName
        self.expandButton.isSelected = sectionModel.isShowing
        self.imageView.image = sectionModel.header.iconImg

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
            .bind(to: self.totalBalance.rx.text)
            .disposed(by: self.bag)
        
        Observable.combineLatest(
            fiatValSrc.flatMapLatest { $0 },
            FiatManager.instance.fiat.asObservable()
            )
            .map {
                fiatValue, fiat -> String in
                return fiat.fullSymbol + (fiatValue?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--")
            }
            .bind(to: self.fiatValue.rx.text)
            .disposed(by: self.bag)
    }
    
}
