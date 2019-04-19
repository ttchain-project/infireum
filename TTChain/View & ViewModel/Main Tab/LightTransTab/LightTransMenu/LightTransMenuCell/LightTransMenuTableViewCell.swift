//
//  LightTransMenuTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

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
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func setupUI() {
        self.bgView.cornerRadius = 8
        self.coinNameLabel.set(textColor: .white, font: .owMedium(size: 20))
        self.coinAmountLabel.set(textColor: .white, font: .owRegular(size: 18))
        self.transferButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_send"),text: LM.dls.light_withdraw_btn_title)
        self.depositButton.set(color: .white, font: .owRegular(size: 12), image: #imageLiteral(resourceName: "light_receive"),text: LM.dls.light_deposit_btn_title)
    }
    
    func config(asset:Asset, transferAction:@escaping ((Asset) -> ()), depositAction:@escaping ((Asset) -> ())) {
        self.bgView.setGradientColor(color1: UIColor.init(red: 8, green: 74, blue: 89)?.cgColor, color2: UIColor.init(red: 24, green: 173, blue: 212)?.cgColor)
        self.coinNameLabel.text = asset.coin?.inAppName
        self.coinAmountLabel.text = asset.amount?.decimalValue.asString(digits: 8)
        self.transferButton.rx.tapGesture().asDriver().drive(onNext: { _ in
            transferAction(asset)
        }).disposed(by: disposeBag)
        
        self.depositButton.rx.tapGesture().asDriver().drive(onNext: { _ in
            depositAction(asset)
        }).disposed(by: disposeBag)
    }
}
