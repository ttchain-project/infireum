//
//  AddWalletSectionHeaderView.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/1.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class AddWalletSectionHeaderView: UITableViewHeaderFooterView {
    
    var bag = DisposeBag()
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.set(textColor: .cloudBurst, font: .owMedium(size: 16))
    }
    func config(section:AddWalletSection) {
        self.titleLabel.text = section.title
        self.imgView.image = section.isShowing ? #imageLiteral(resourceName: "btn_close.png") : #imageLiteral(resourceName: "btn_open.png")
    }
}
