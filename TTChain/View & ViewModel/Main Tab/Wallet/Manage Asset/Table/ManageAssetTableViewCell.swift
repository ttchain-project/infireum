//
//  ManageAssetTableViewCell.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/27.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class ManageAssetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var contractLabel: UILabel!
    
    @IBOutlet weak var selectSwitch: UISwitch!
    @IBOutlet weak var sepline: UIView!
    
    fileprivate var onChangeSel: ((Bool) -> Void)?
    private var isDeletable: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectSwitch.addTarget(
            self, action: #selector(selectChanged), for: .valueChanged
        )
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(sel: CoinSelection, onChangeSel: @escaping (Bool) -> Void) {
        icon.image = sel.coin!.iconImg
        
        let palette = TM.instance.theme.value.palette
        nameLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 14.5))
        fullnameLabel.set(textColor: palette.label_sub, font: .owRegular(size: 10.9))
        contractLabel.set(textColor: palette.specific(color: .owSilver), font: .owRegular(size: 10.9))
        sepline.backgroundColor = palette.sepline
        
        nameLabel.text = sel.coin?.inAppName
        fullnameLabel.text = sel.coin?.fullname
        contractLabel.text =  sel.coin?.contract
        selectSwitch.isOn = sel.isSelected
        self.isDeletable = sel.coin?.isDeletable ?? true
        selectSwitch.isHidden = !isDeletable
        
        
        self.onChangeSel = onChangeSel
    }
    
    @objc func selectChanged() {
        let isSelected = selectSwitch.isOn
        onChangeSel?(isSelected)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if isDeletable {
            selectSwitch.isHidden = editing
        }
        
        super.setEditing(editing, animated: animated)
    }
}
