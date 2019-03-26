//
//  ReceiptTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/29.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class ReceiptTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
        
    }

    func setup() {
        
        dateLabel.set(textColor: .black, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .black, font: .owDemiBold(size: 16))

        self.messageContent.set(textColor: .black, font: .owMedium(size: 16))
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.profilePicImageView.cornerRadius = 20.0
        self.bgView.cornerRadius = 5.0
        
    }
    
    var bag :DisposeBag = DisposeBag.init()
    @IBOutlet var senderConstraint: NSLayoutConstraint!
    @IBOutlet var receiverConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageContent: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag.init()
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: String?, leftImageAction:@escaping ((String) -> Void)) {
      
        dateLabel.text = message.timestamp.string()
        self.messageContent.text = LM.dls.chat_room_receipt
        
        if message.isUserSender() {
            self.profilePicImageView.isHidden = true
            self.dateLabel.textAlignment = .right
            self.senderConstraint.isActive = false
            self.receiverConstraint.isActive = true
            self.senderNameLabel.text = ""
        }else {
            self.profilePicImageView.isHidden = false
            self.dateLabel.textAlignment = .left
            self.senderConstraint.isActive = true
            self.receiverConstraint.isActive = false
            self.profilePicImageView.setProfileImage(image: leftImage,tempName:message.senderName)
            self.senderNameLabel.text = message.senderName
            
        }
        self.profilePicImageView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
    }
 
}
