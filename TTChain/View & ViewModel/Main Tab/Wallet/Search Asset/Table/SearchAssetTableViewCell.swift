//
//  SearchAssetTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/28.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import AlamofireImage

class SearchAssetTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var contractLabel: UILabel!
    
    @IBOutlet weak var inSelectionButton: UIButton!
    @IBOutlet weak var sepline: UIView!
    
    fileprivate var onChangeInSelectionOrNot: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        inSelectionButton.addTarget(
            self, action: #selector(selectChanged), for: .touchUpInside
        )
        
        inSelectionButton.setTitle(nil, for: .normal)
        inSelectionButton.setImage(#imageLiteral(resourceName: "btnAddBlackNormal"), for: .normal)
        inSelectionButton.setTitle(nil, for: .selected)
        inSelectionButton.setImage(#imageLiteral(resourceName: "btnCancelGreyNormal"), for: .selected)
        
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(
        source: SearchAssetViewModel.CoinSource,
        isInSelection: Bool,
        isRemovable: Bool,
        onChangeInSelectionOrNot: @escaping (Bool) -> Void) {
        
        icon.image = nil
        switch source.type {
        case .local(let coin):
            icon.image = coin.iconImg
        case .remote(let source):
            if let url = URL.init(string: source.iconUrlStr) {
                icon.af_setImage(withURL: url)
            }
        }
        
        let palette = TM.instance.theme.value.palette
        nameLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 14.5))
        fullnameLabel.set(textColor: palette.label_sub, font: .owRegular(size: 10.9))
        contractLabel.set(textColor: palette.specific(color: .owSilver), font: .owRegular(size: 10.9))
        sepline.backgroundColor = palette.sepline
        
        nameLabel.text = source.type.name
        fullnameLabel.text = source.type.fullname
        contractLabel.text =  source.type.contract
        inSelectionButton.isSelected = isInSelection
        inSelectionButton.isHidden = !isRemovable
        
        
        self.onChangeInSelectionOrNot = onChangeInSelectionOrNot
    }
    
    @objc func selectChanged() {
//        inSelectionButton.isSelected = !inSelectionButton.isSelected
        onChangeInSelectionOrNot?(!inSelectionButton.isSelected)
    }
    
}
