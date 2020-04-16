//
//  WalletsTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletsTableViewCell: UITableViewCell {

    var bag = DisposeBag()
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assetBalance: UILabel!
    @IBOutlet weak var fiatValue: UILabel!
    
    func config(asset:Asset, amtSource:Observable<BehaviorRelay<Decimal?>>,fiatValueSource:Observable<BehaviorRelay<Decimal?>>,fiatSource:Observable<Fiat>) {
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
                              maxDigits: 8,
                              digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                    .disguiseIfNeeded()
                //                .asString(digits: Int(coin.digit)).disguiseIfNeeded()
            }
            .bind(to: self.assetBalance.rx.text)
            .disposed(by: self.bag)
        
        Observable.combineLatest(
            fiatValueSource.flatMapLatest { $0 },
            fiatSource
            )
            .map {
                fiatValue, fiat -> String in
                return fiat.fullSymbol + (fiatValue?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--")
            }
            .bind(to: self.fiatValue.rx.text)
            .disposed(by: self.bag)
        
        self.titleLabel.text = asset.wallet?.name

    }
}
