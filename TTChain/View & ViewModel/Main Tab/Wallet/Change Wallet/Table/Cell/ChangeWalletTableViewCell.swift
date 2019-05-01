//
//  ChangeWalletTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/30.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ChangeWalletTableViewCell: UITableViewCell, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var walletBGImgView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddrLabel: UILabel!
    @IBOutlet weak var addrCopyBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineLabel: UILabel!
    
    private var onCopyAddrTap: (() -> Void)?
    private var onSettingsTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        contentView.backgroundColor = .clear
        renderMainViewShadow()
        
        bag = DisposeBag.init()
        offlineView.rx
            .enableCircleSided()
            .disposed(by: bag)
        
        Driver.merge(
            addrCopyBtn.rx.tap.asDriver()
        )
            .drive(onNext: {
                [unowned self] in
                self.copyAddr()
            })
            .disposed(by: bag)
        
        settingsBtn.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.toSettings()
            })
            .disposed(by: bag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(wallet: Wallet, onAddrTap: @escaping () -> Void, onSettingsTap: @escaping () -> Void, isNetworkReachable: Bool, isAbleToSelect: Bool) {
        let palette = TM.palette
        walletBGImgView.image = img(ofMainCoinID: wallet.walletMainCoinID!)
        walletNameLabel.set(textColor: palette.label_main_2, font: .owMedium(size: 16.3))
        walletAddrLabel.set(textColor: palette.label_main_2, font: .owRegular(size: 12))
        addrCopyBtn.setPureImage(color: palette.label_main_2, image: #imageLiteral(resourceName: "btnListCopyNormal"))
        settingsBtn.setPureImage(color: palette.label_main_2, image: #imageLiteral(resourceName: "btnSettingNormal"))
        
//        let dls = LM.dls
        walletNameLabel.text = wallet.name
        
        walletAddrLabel.lineBreakMode = .byTruncatingMiddle
        walletAddrLabel.text = wallet.address
        offlineLabel.text = LM.dls.changeWallet_label_offline
        offlineLabel.set(textColor: palette.label_sub, font: .owRegular(size: 10))
        offlineView.backgroundColor = palette.bgView_main
        offlineView.isHidden = isNetworkReachable
        
        self.onCopyAddrTap = onAddrTap
        self.onSettingsTap = onSettingsTap
        
        self.contentView.alpha = isAbleToSelect ? 1 : 0.4
    }
    
    @objc private func copyAddr() {
        onCopyAddrTap?()
    }
    
    @objc private func toSettings() {
        onSettingsTap?()
    }
    
    private func renderMainViewShadow() {
        mainView.clipsToBounds = false
        
        mainView.shadowColor = UIColor.init(red: 31, green: 49, blue: 72)?.withAlphaComponent(0.12)
        mainView.shadowRadius = 2
        mainView.shadowOpacity = 1
        mainView.shadowOffset = CGSize.init(width: 0, height: 3)
    }
    
    private func img(ofMainCoinID mainCoinID: String) -> UIImage {
        let coin = Coin.getCoin(ofIdentifier: mainCoinID)!
        switch coin.owChainType {
        case .btc:
            return #imageLiteral(resourceName: "bgBtcWalletColor")
        case .eth,.ttn:
            return #imageLiteral(resourceName: "bgEthWalletColor")
        case .cic:
            if mainCoinID == Coin.cic_identifier {
                return #imageLiteral(resourceName: "bgCicWalletColor")
            }else if mainCoinID == Coin.guc_identifier {
                return #imageLiteral(resourceName: "bgGuCwalletColor")
            }else {
                return #imageLiteral(resourceName: "bgGuCwalletColor")
            }
        }
        
    }
}
