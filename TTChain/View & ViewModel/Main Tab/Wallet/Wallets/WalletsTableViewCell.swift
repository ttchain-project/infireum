//
//  WalletsTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletsTableViewCell: UITableViewCell {

    var bag = DisposeBag()
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assetBalance: UILabel!
    @IBOutlet weak var fiatValue: UILabel!
    
    
}
