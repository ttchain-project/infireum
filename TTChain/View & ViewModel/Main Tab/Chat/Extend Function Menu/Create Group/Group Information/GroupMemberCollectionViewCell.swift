//
//  GroupMemberCollectionViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift

class GroupMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var closeImageView: UIImageView!
    
    private var disposeBag = DisposeBag()
    var viewModel: GroupMemberCollectionViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            disposeBag = DisposeBag()
            nicknameLabel.text = viewModel.output.text
            if viewModel.input.groupMemberModel != nil {
                avatarImageView.image = viewModel.output.avatarImage
            } else {
                if viewModel.output.avatarImage != nil {
                    avatarImageView.image = viewModel.output.avatarImage
                } else {
                    avatarImageView.image = #imageLiteral(resourceName: "iconCircleAdd.png")
                }
            }
            viewModel.output.closeButtonIsHidden.bind(to: closeImageView.rx.isHidden).disposed(by: disposeBag)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.height / 2
    }

}
