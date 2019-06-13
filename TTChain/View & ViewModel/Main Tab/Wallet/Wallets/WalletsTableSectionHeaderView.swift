//
//  WalletsTableSectionHeaderView.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletsTableSectionHeaderView : UITableViewHeaderFooterView {
    
    var bag = DisposeBag()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var fiatValue: UILabel!
    
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
