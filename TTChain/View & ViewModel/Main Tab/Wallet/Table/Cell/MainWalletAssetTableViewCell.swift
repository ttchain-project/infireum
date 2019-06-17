//
//  MainWalletAssetTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage


class MainWalletAssetTableViewCell: UITableViewCell, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetAmtLabel: UILabel!
    @IBOutlet weak var assetFiatValueLabel: UILabel!
    @IBOutlet weak var sepline: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    private func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        assetNameLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 14.5))
        assetAmtLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 16.3))
        assetFiatValueLabel.set(textColor: palette.label_sub, font: .owRegular(size: 10.9))
        sepline.backgroundColor = palette.sepline
        self.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(coin: Coin, amtSource: Observable<BehaviorRelay<Decimal?>>, fiatValueSource: Observable<BehaviorRelay<Decimal?>>, fiatSource: Observable<Fiat>) {
        bag = DisposeBag.init()
        
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
                          maxDigits: Int(coin.digit),
                          digitMoveCondition: { Decimal.init(string: $0)! != _amt })
                .disguiseIfNeeded()
//                .asString(digits: Int(coin.digit)).disguiseIfNeeded()
        }
        .bind(to: assetAmtLabel.rx.text)
        .disposed(by: bag)
        
        Observable.combineLatest(
            fiatValueSource.flatMapLatest { $0 },
            fiatSource
            )
            .map {
                fiatValue, fiat -> String in
                return fiat.fullSymbol + (fiatValue?.asString(digits: 2, force: true).disguiseIfNeeded() ?? "--")
            }
            .bind(to: assetFiatValueLabel.rx.text)
            .disposed(by: bag)
        
        assetNameLabel.text = coin.inAppName!
        if let data = coin.icon,
            let img = UIImage.init(data: data as Data) {
            icon.image = img
        }else {
            //TODO: Might add some alamofire image fetch here.
            icon.image = #imageLiteral(resourceName: "iconListNoimage")
        }
        
        TM.instance.theme.subscribe(onNext: {
            [unowned self] in self.renderTheme($0)
        })
        .disposed(by: bag)
    }
    
}
