//
//  ImportedWalletTableHeaderView.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/30.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImportedWalletTableHeaderView: UITableViewHeaderFooterView, RxThemeRespondable, RxLangRespondable, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    var themeBag: DisposeBag = DisposeBag.init()
    var langBag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        themeBag = DisposeBag.init()
        langBag = DisposeBag.init()
//        addBtn.imageView?.contentMode = .scaleAspectFit
        monitorTheme { [unowned self] (theme) in
            self.titleLabel.set(textColor: theme.palette.label_main_2, font: .owRegular(size: 12))
            self.contentView.backgroundColor = theme.palette.specific(color: .owMarineBlue)
        }
        
        monitorLang { [unowned self] (lang) in
            let dls = lang.dls
            self.titleLabel.text = dls.changeWallet_label_wallets_imported
        }
    }
    
    func config(onCreate: @escaping () -> Void) {
        bag = DisposeBag.init()
//        addBtn.rx.enableCircleSided().disposed(by: bag)
//        addBtn.rx.tap.asDriver().drive(onNext: {
//            onCreate()
//        })
//        .disposed(by: bag)
        
        rx.klrx_tap.drive(onNext: {
            onCreate()
        })
        .disposed(by: bag)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
