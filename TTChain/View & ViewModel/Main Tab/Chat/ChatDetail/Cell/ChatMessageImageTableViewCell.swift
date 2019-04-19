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
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectMessageButton: UIButton!
    @IBOutlet weak var selectMessageButtonWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
        self.selectMessageButtonWidth.constant = 0
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
        dateLabel.set(textColor: .black, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .black, font: .owDemiBold(size: 16))
        profilePics.layer.cornerRadius = 20

        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: String?, leftImageAction:@escaping ((String) -> Void)) {
        self.selectMessageButtonWidth.constant = 0

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
            self.msgImageView.backgroundColor = UIColor.white

        }
        self.profilePics.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
        
        guard let url = URL.init(string: message.msg) else {
            return
        }
        self.msgImageView.image = #imageLiteral(resourceName: "no_image")
        if case .voiceMessage = message.msgType {
            self.msgImageView.image = #imageLiteral(resourceName: "voice_message_icon")
            self.heightConstraint.constant = 48
            self.widthConstraint.constant = 48
        }else {
            self.msgImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "no_image"))
            self.heightConstraint.constant = 150
            self.widthConstraint.constant = 150
        }
    }
    
    func setDataForForwarSelection(message:MessageModel, leftImage: String?,messageSelected:@escaping ((MessageModel) -> Void)) {
        
        self.selectMessageButton.isSelected = message.isMessageSelected
        
        self.selectMessageButton.rx.tap.asDriver().drive(onNext: { _ in
            self.selectMessageButton.isSelected = !self.selectMessageButton.isSelected
            messageSelected(message)
        }).disposed(by: bag)
        
        self.setMessage(forMessage: message, leftImage: leftImage) { (_) in
            
        }
        self.selectMessageButtonWidth.constant = 36
    }
}
