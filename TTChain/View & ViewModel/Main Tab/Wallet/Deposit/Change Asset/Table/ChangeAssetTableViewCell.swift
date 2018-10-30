//
//  ChangeAssetTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/25.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChangeAssetTableViewCell: UITableViewCell, Rx {
    
    private var amtDisposables: Disposable?
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
    @IBOutlet weak var sepline: UIView!
    @IBOutlet weak var check: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(asset: Asset, amtSource: Observable<BehaviorRelay<Decimal?>>, isSelected: Bool) {
        bag = DisposeBag.init()
        
        let amtStr = amtSource
            .switchLatest()
            .map {
                amt -> String in
                if let _amt = amt {
                    return _amt.asString(digits: C.Coin.min_digit,
                                         force: true,
                                         maxDigits: Int(asset.coin!.digit),
                                         digitMoveCondition: { Decimal.init(string: $0)! != _amt }
                                        )
                                        .disguiseIfNeeded()
                }else {
                    return "--"
                }
            }
        
        let remainAmtStr = LM.instance.lang.map {
            _ in
            return LM.dls.changeAsset_label_remainAmt
        }
        
        Observable.combineLatest(remainAmtStr, amtStr)
            .map { $0 + $1 }
            .bind(to: amtLabel.rx.text)
            .disposed(by: bag)
        
        if let coin = asset.coin {
            config(coin: coin)
        }else {
            let coinPred = Coin.genPredicate(fromIdentifierType: .str(keyPath: #keyPath(Coin.identifier), value: asset.coinID!))
            guard let coin = DB.instance.get(type: Coin.self, predicate: coinPred, sorts: nil)?.first else {
                return errorDebug(response: ())
            }
            
            config(coin: coin)
        }
        
        LM.instance.lang.subscribe(onNext: {
            [unowned self] in self.config(lang: $0)
        })
        .disposed(by: bag)
        
        TM.instance.theme.subscribe(onNext: {
            [unowned self] in self.config(theme: $0)
        })
        .disposed(by: bag)
        
        check.isHidden = !isSelected
    }
    
    private func config(coin: Coin) {
        nameLabel.text = coin.inAppName
        icon.image = coin.iconImg
    }
    
    private func config(lang: Lang) {
        return
    }
    
    private func config(theme: Theme) {
        nameLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 14.5))
        amtLabel.set(textColor: theme.palette.label_sub, font: .owRegular(size: 12))
        sepline.backgroundColor = theme.palette.sepline
    }
    
}
