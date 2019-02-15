//
//  InviteTableViewCell.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InviteTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.height/2
            avatarImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resumeLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    var bag: DisposeBag = DisposeBag()
    var onFriendRequestAction: ((Bool) -> Void)?
    
    private var friendRequestModel: FriendRequestInformationModel = FriendRequestInformationModel() {
        didSet {
            self.avatarImageView.image = friendRequestModel.avatar
            self.nameLabel.text = friendRequestModel.nickName
            self.resumeLabel.text = friendRequestModel.message
            
            if friendRequestModel.avatar == nil, friendRequestModel.avatarUrl == nil {
                self.avatarImageView.image = ImageUntil.drawAvatar(text: friendRequestModel.nickName)
            } else {
                self.avatarImageView.af_setImage(withURL: friendRequestModel.avatarUrl!)
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        rejectButton.layer.cornerRadius = 3.0
        acceptButton.layer.cornerRadius = 3.0
        
        selectionStyle = .none
        
        initButton()
        
        let palette = TM.palette
        
        self.nameLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 18))
        self.resumeLabel.set(textColor: palette.label_main_1, font: .owMedium(size: 14))
        self.backgroundColor = .clear
        
        self.acceptButton.setTitle(LM.dls.accept_request, for: .normal)
        self.rejectButton.setTitle(LM.dls.reject_request, for: .normal)

    }

    func config(friendRequestModel: FriendRequestInformationModel?,
                onFriendRequestAction: @escaping (Bool) -> Void) {
        guard let friendRequest = friendRequestModel else {
            return
        }
        self.friendRequestModel = friendRequest
        self.onFriendRequestAction = onFriendRequestAction
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
                print(100)
                guard let weakSelf = self else {
                    return
                }
                weakSelf.onFriendRequestAction?(false)
            }).disposed(by: bag)
        
        
        acceptButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self](button) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.onFriendRequestAction?(true)
            }).disposed(by: bag)
    }
    
}
