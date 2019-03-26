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
        profilePics.layer.cornerRadius = 20

        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: String?, leftImageAction:@escaping ((String) -> Void)) {
        dateLabel.text = message.timestamp.string()
        if message.isUserSender() {
            self.profilePics.isHidden = true
            self.dateLabel.textAlignment = .right
            self.senderConstraint.isActive = true
            self.receiverConstraint.isActive = false
            self.senderNameLabel.text = ""
            self.msgImageView.backgroundColor = UIColor.init(red: 137, green: 216, blue: 128)
            
        }else {
            self.profilePics.isHidden = false
            self.dateLabel.textAlignment = .left
            self.senderConstraint.isActive = false
            self.receiverConstraint.isActive = true
            self.profilePics.setProfileImage(image: leftImage, tempName: message.senderName)

            self.senderNameLabel.text = message.senderName
            
        }
        self.profilePics.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
        
        guard let url = URL.init(string: message.msg) else {
            return
        }
        if case .voiceMessage = message.msgType {
            self.msgImageView.image = #imageLiteral(resourceName: "voice_message_icon")
        }else {
            self.msgImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "no_image"))
        }

    }
}
