//
//  TransferRecordMultipleOptionBarCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift

class TransferRecordCancellableOptionBarCollectionViewCell: UICollectionViewCell, Rx {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var bag: DisposeBag = DisposeBag.init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cancelBtn.isUserInteractionEnabled = false
        cancelBtn.setImageForAllStates(#imageLiteral(resourceName: "btnCancelWhiteNormal"))
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func config(withContent content: String, isSelected: Bool) {
        let palette = TM.palette
        
        let textColor = isSelected ? palette.btn_bgFill_enable_text : palette.label_main_1
        let bgColor = isSelected ? palette.btn_bgFill_enable_bg : palette.specific(color: .clear)
        let font = isSelected ? UIFont.owMedium(size: 12) : UIFont.owRegular(size: 12)
        infoLabel.set(textColor: textColor, font: font)
        baseView.backgroundColor = bgColor
        
        infoLabel.text = content
        
        cancelBtn.isHidden = !isSelected
        
//        bag = DisposeBag.init()
        baseView.cornerRadius = 16
        
        self.setNeedsDisplay()
        self.layoutIfNeeded()
    }
    
}
