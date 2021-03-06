//
//  GroupInviteTableViewCell.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GroupInviteTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.cornerRadius = avatarImageView.height/2
            avatarImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    var onGroupRequestAction:((GroupAction) -> Void)?
    
    let bag : DisposeBag = DisposeBag.init()
    
    var groupRequestModel: UserGroupInfoModel = UserGroupInfoModel() {
        didSet {
            self.titleLabel.text = groupRequestModel.groupName
            self.avatarImageView.setProfileImage(image: groupRequestModel.headImg, tempName: groupRequestModel.groupName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rejectButton.layer.cornerRadius = 3.0
        acceptButton.layer.cornerRadius = 3.0
        
        let palette = TM.palette
        
        self.separatorView.backgroundColor = palette.sepline
        self.titleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        self.backgroundColor = .clear
        
        self.acceptButton.setTitle(LM.dls.accept_request, for: .normal)
        self.rejectButton.setTitle(LM.dls.reject_request, for: .normal)
        self.initButton()
        
    }

    func config(groupRequestModel: UserGroupInfoModel?,
                onGroupRequestAction: @escaping (GroupAction) -> Void) {
        guard let groupRequest = groupRequestModel else {
            return
        }
        self.groupRequestModel = groupRequest
        self.onGroupRequestAction = onGroupRequestAction
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initButton() {
        rejectButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: {[weak self] (button) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.onGroupRequestAction?(GroupAction.reject)
            }).disposed(by: bag)
        
        
        acceptButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self](button) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.onGroupRequestAction?(GroupAction.accept)
            }).disposed(by: bag)
    }

}
