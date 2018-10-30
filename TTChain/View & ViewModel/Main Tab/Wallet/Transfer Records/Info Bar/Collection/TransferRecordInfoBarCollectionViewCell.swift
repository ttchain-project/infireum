//
//  TransferRecordInfoBarCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

class TransferRecordInfoBarCollectionViewCell: UICollectionViewCell, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var baseView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.cornerRadius = 16
        let palette = TM.palette
        baseView.backgroundColor = palette.btn_bgFill_enable_bg
        contentLabel.set(textColor: palette.btn_bgFill_enable_text, font: .owMedium(size: 12))
        
    }
    
    func config(contentName: String) {
        self.setNeedsDisplay()
        self.layoutIfNeeded()
        contentLabel.text = contentName
    }

}
