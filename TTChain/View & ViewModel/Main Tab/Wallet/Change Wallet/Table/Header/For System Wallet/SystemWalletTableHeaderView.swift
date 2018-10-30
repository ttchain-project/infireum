//
//  SystemWalletTableHeaderView.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/30.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

class SystemWalletTableHeaderView: UITableViewHeaderFooterView, RxThemeRespondable, RxLangRespondable, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        themeBag = DisposeBag.init()
        langBag = DisposeBag.init()
        
        monitorTheme { [unowned self] (theme) in
            self.titleLabel.set(textColor: theme.palette.label_main_2,
                                font: .owRegular(size: 12))
            self.contentView.backgroundColor = theme.palette.specific(color: .owMarineBlue)
        }
        
        monitorLang { [unowned self] (lang) in
            let dls = lang.dls
            self.titleLabel.text = dls.changeWallet_label_wallets_current_identity
        }
    }

}
