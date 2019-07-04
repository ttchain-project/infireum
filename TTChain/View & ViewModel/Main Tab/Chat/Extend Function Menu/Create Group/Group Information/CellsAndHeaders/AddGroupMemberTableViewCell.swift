//
//  AddGroupMemberTableViewCell.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift

class AddGroupMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    
    var viewModel: AddGroupMemeberTableViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            disposeBag = DisposeBag()
            nicknameLabel.text = viewModel.output.nickname
            avatarImageView.setProfileImage(image: viewModel.output.avatarImage, tempName: viewModel.output.nickname)
            viewModel.output.isSelected.map({ $0 ? #imageLiteral(resourceName: "radioButtonOn.png") : #imageLiteral(resourceName: "radioButtonOff.png") }).bind(to: selectedImageView.rx.image).disposed(by: disposeBag)
        }
    }
}
