//
//  ChatMessageTableViewCell.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/25.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatMessageTableViewCell: UITableViewCell, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var leftSpeakerContentView:  UIView!
    @IBOutlet weak var leftAvatarImageView:         UIImageView!
    @IBOutlet weak var leftValueContentView:        UIView!
    @IBOutlet weak var leftMessageLabel:            UILabel!
    @IBOutlet weak var rightSpeakerContentView: UIView!
    @IBOutlet weak var rightValueContentView:       UIView!
    @IBOutlet weak var rightMessageLabel:           UILabel!
    
    @IBOutlet weak var leftDateLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var rightDateLabel: UILabel!
    @IBOutlet weak var profilePicBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bag = DisposeBag.init()
    }
    func setupUI () {
        leftSpeakerContentView.backgroundColor = .clear
        leftAvatarImageView.layer.cornerRadius = 20.0
        leftAvatarImageView.layer.masksToBounds = true
        leftValueContentView.backgroundColor = .white
        leftValueContentView.layer.cornerRadius = 5.0
        leftValueContentView.layer.masksToBounds = true
        
        rightSpeakerContentView.backgroundColor = .clear
        rightValueContentView.backgroundColor = UIColor.init(red: 137, green: 216, blue: 128)
        rightValueContentView.layer.cornerRadius = 5.0
        rightValueContentView.layer.masksToBounds = true
        
        leftDateLabel.set(textColor: .black, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .black, font: .owDemiBold(size: 16))
        rightDateLabel.set(textColor: .black, font: .owMedium(size: 14))
        
        leftMessageLabel.set(textColor: .black,font :.owRegular(size: 18))
        rightMessageLabel.set(textColor: .black,font :.owRegular(size: 18))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(forMessage message:MessageModel, leftImage: UIImage?, leftImageAction:@escaping ((String) -> Void)) {
        if message.senderId == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId {
            self.configForSender(message: message)
        }else {
            self.configForLeft(message: message, leftImage: leftImage)
            
        }
        self.profilePicBtn.rx.tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
    }
    
    private func configForSender(message:MessageModel) {
        self.rightMessageLabel.text = message.msg
        self.rightDateLabel.text = message.timestamp.string()
        self.rightSpeakerContentView.isHidden = false
        self.leftSpeakerContentView.isHidden = true
        
    }
    
    private func configForLeft(message:MessageModel,leftImage: UIImage?) {
        self.leftMessageLabel.text = message.msg
        self.leftDateLabel.text = message.timestamp.string()
        self.leftAvatarImageView.image = leftImage ?? #imageLiteral(resourceName: "no_image")
        
        self.rightSpeakerContentView.isHidden = true
        self.leftSpeakerContentView.isHidden = false
        self.senderNameLabel.text = message.senderName
    }
}
