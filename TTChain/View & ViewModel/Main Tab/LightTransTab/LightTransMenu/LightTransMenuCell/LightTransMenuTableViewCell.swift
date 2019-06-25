//
//  LightTransMenuTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift

class LightTransMenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        // Initialization code
    }

    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var fiatAmountLabel: UILabel!
    @IBOutlet weak var coinSymbol: UIImageView!
    @IBOutlet weak var coinAmountLabel: UILabel!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var bgView: UIView!
//    @IBOutlet weak var gradView: UIView!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    
    private var gradient: CAGradientLayer!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func setupUI() {
//        self.gradView.cornerRadius = 8
        self.coinNameLabel.set(textColor: .white, font: .owMedium(size: 20))
        self.coinAmountLabel.set(textColor: .white, font: .owRegular(size: 18))
        self.addressLabel.set(textColor: .white, font: .owRegular(size: 15))
        fiatAmountLabel.set(textColor: .white, font: .owRegular(size: 14))
        self.backgroundColor = .clear
//        self.gradView.backgroundColor = .clear
        self.bgView.backgroundColor = .clear
        self.transferButton.cornerRadius = 16
        self.depositButton.cornerRadius = 16
        self.fiatAmountLabel.text = "≈$ 0.00"
        LM.instance.lang.subscribe(onNext: {
            [unowned self] in self.configUI(lang: $0)
        })
            .disposed(by: disposeBag)

    }
    
    private func configUI(lang:Lang) {
        self.transferButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_send"),text: lang.dls.light_withdraw_btn_title, borderInfo: (color: .summerSky    , width: 1))
        self.depositButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_receive"),text: lang.dls.light_deposit_btn_title,borderInfo: (color: .summerSky    , width: 1))
        
    }
    
    func config(asset:Asset, amtSource:Observable<BehaviorRelay<Decimal?>>, transferAction:@escaping ((Asset) -> ()), depositAction:@escaping ((Asset) -> ()),copyAction:@escaping((String)->())) {
        
        amtSource
            .flatMapLatest { $0 }
            .map {
                amt -> String in
                guard let _amt = amt else {
                    return "--"
                }
                
                return _amt
                    .asString(digits: 4,
                              force: true,
                              maxDigits: Int(asset.coin!.requiredDigit),
                              digitMoveCondition: { Decimal.init(string: $0)! != amt })
                //                .asString(digits: Int(coin.digit)).disguiseIfNeeded()
            }
            .bind(to: coinAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.coinNameLabel.text = asset.coin?.inAppName?.replacingOccurrences(of: "BTCN", with: "BTC")
        self.coinSymbol?.image = asset.coin?.iconImg
        
        self.transferButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
            transferAction(asset)
        }).disposed(by: disposeBag)
        
        self.depositButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
            depositAction(asset)
        }).disposed(by: disposeBag)
        
        if asset.coinID == Coin.ttn_identifier{
            self.depositButton.isHidden = true
            self.transferButton.isHidden = true
            addressView.isHidden = false
            self.bgView.backgroundColor = .cloudBurst
            addressLabel.text = asset.wallet?.address

        }else {
            self.depositButton.isHidden = false
            self.transferButton.isHidden = false
            addressView.isHidden = true
            addressLabel.text = asset.wallet?.address
            self.bgView.backgroundColor = .clear
        }
        
        self.copyButton.rx.klrx_tap.drive(onNext:{ _ in
            guard let address = asset.wallet?.address else {
                return
            }
            copyAction(address)
        }).disposed(by: disposeBag)
    }
}
