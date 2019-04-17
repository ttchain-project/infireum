//
//  IdentityQRCodeImportTableViewHeader.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class IdentityQRCodeImportTableViewHeader: UITableViewHeaderFooterView, RxThemeRespondable, RxLangRespondable, Rx {
    
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
            self.titleLabel.set(textColor: theme.palette.specific(color: .owAzure),
                                font: .owRegular(size: 12))
            self.contentView.backgroundColor = theme.palette.specific(color: .owWhite)
        }
    }
    
    enum HeaderType {
        case system
        case imported
    }
    
    func config(headerType: HeaderType) {
        let dls = LM.dls
        switch headerType {
        case .system:
            icon.image = #imageLiteral(resourceName: "iconListProfileBlueNormal")
            titleLabel.text = dls.qrCodeImport_list_user_system_wallets
        case .imported:
            icon.image = #imageLiteral(resourceName: "iconListImportBlueNormal")
            titleLabel.text = dls.qrCodeImport_list_imported_wallets
        }
    }
    
}
