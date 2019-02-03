//
//  ChatMessageImageTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/24.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ChatMessageImageTableViewCell: UITableViewCell {

    var bag: DisposeBag = DisposeBag.init()
    @IBOutlet weak var profilePics: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet var senderConstraint: NSLayoutConstraint!
    @IBOutlet var receiverConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bag = DisposeBag.init()
    }
    
    func setup() {
        
        self.msgImageView.layer.borderWidth = 5.0
        self.msgImageView.layer.borderColor = UIColor.white.cgColor
        dateLabel.set(textColor: .gray, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .gray, font: .owDemiBold(size: 16))

        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: UIImage?, leftImageAction:@escaping ((String) -> Void)) {
        dateLabel.text = message.timestamp.string()
        if message.senderId == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId {
            self.profilePics.isHidden = true
            self.dateLabel.textAlignment = .right
            self.senderConstraint.isActive = true
            self.receiverConstraint.isActive = false
            self.senderNameLabel.text = ""
        }else {
            self.profilePics.isHidden = false
            self.dateLabel.textAlignment = .left
            self.senderConstraint.isActive = false
            self.receiverConstraint.isActive = true
            self.profilePics.image = leftImage ?? #imageLiteral(resourceName: "no_image")
            self.senderNameLabel.text = message.senderName

        }
        self.profilePics.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
        
        guard let url = URL.init(string: message.msg) else {
            return
        }
        self.msgImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "no_image"))
    }
}
