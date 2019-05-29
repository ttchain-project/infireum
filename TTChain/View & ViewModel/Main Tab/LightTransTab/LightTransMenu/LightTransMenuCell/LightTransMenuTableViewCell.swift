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

class LightTransMenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        // Initialization code
    }

    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbol: UIImageView!
    @IBOutlet weak var coinAmountLabel: UILabel!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var gradView: UIView!
    
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
        self.gradView.cornerRadius = 8
        self.coinNameLabel.set(textColor: .white, font: .owMedium(size: 20))
        self.coinAmountLabel.set(textColor: .white, font: .owRegular(size: 18))
        self.backgroundColor = .clear
        self.gradView.backgroundColor = .clear
        self.bgView.backgroundColor = .clear
        
        LM.instance.lang.subscribe(onNext: {
            [unowned self] in self.configUI(lang: $0)
        })
            .disposed(by: disposeBag)
        
    }
    
    private func configUI(lang:Lang) {
        self.transferButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_send"),text: lang.dls.light_withdraw_btn_title)
        self.depositButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_receive"),text: lang.dls.light_deposit_btn_title)
    }
    
    func config(asset:Asset, amtSource:Observable<BehaviorRelay<Decimal?>>, transferAction:@escaping ((Asset) -> ()), depositAction:@escaping ((Asset) -> ())) {
        
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
        
        if asset.coinID == Coin.ttn_identifier {
            self.depositButton.isHidden = true
            self.transferButton.isHidden = true
        }
        
        if self.gradient != nil {
            return
        }
        switch asset.coinID {
        case Coin.ethn_identifier:
            self.gradient = self.gradView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "FFA734")!.cgColor, UIColor.init(hexString: "FFDB24")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
        case Coin.usdtn_identifier:
            self.gradient = self.gradView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "417C9E")!.cgColor,UIColor.init(hexString: "A6C1DC")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
        case Coin.btcn_identifier:
            self.gradient = self.gradView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "208588")!.cgColor,UIColor.init(hexString: "1CC491")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
        default:
            self.gradient = self.gradView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "098A95")!.cgColor,UIColor.init(hexString: "18ADD4")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
        }
        

    }
}
