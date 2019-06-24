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
    @IBOutlet weak var selectMessageButton: UIButton!
    @IBOutlet weak var selectMessageButtonWidth: NSLayoutConstraint!
    
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
        leftValueContentView.layer.cornerRadius = 16.0
        leftValueContentView.layer.masksToBounds = true
        
        rightSpeakerContentView.backgroundColor = .clear
        rightValueContentView.backgroundColor = .yellowGreen
        rightValueContentView.layer.cornerRadius = 16.0
        rightValueContentView.layer.masksToBounds = true
        
        leftDateLabel.set(textColor: TM.palette.label_sub, font: .owMedium(size: 12))
        senderNameLabel.set(textColor: TM.palette.label_sub, font: .owDemiBold(size: 12))
        rightDateLabel.set(textColor: TM.palette.label_sub, font: .owMedium(size: 12))
        
        leftMessageLabel.set(textColor: .black,font :.owRegular(size: 14))
        rightMessageLabel.set(textColor: .white,font :.owRegular(size: 14))
        
        self.selectMessageButtonWidth.constant = 0

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(forMessage message:MessageModel, leftImage: String?, leftImageAction:@escaping ((String) -> Void)) {
        self.selectMessageButtonWidth.constant = 0
        if message.isUserSender() {
            self.configForSender(message: message)
        }else {
            self.configForLeft(message: message, leftImage: leftImage)
            
        }
        self.profilePicBtn.rx.tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
    }
    
    private func configForSender(message:MessageModel) {
        
        if case .urlMessage = message.msgType {
            self.setupForURL(message: message.msg,label:rightMessageLabel)
        }else {
            self.rightMessageLabel.text = message.msg
        }
        
        self.rightDateLabel.text = message.timestamp.string()
        self.rightSpeakerContentView.isHidden = false
        self.leftSpeakerContentView.isHidden = true
        
    }
    
    private func configForLeft(message:MessageModel,leftImage: String?) {
        
        if case .urlMessage = message.msgType {
            self.setupForURL(message: message.msg,label:leftMessageLabel)
        }else {
            self.leftMessageLabel.text = message.msg
        }
        self.leftDateLabel.text = message.timestamp.string()
        self.leftAvatarImageView.setProfileImage(image: leftImage, tempName: message.senderName)

        self.rightSpeakerContentView.isHidden = true
        self.leftSpeakerContentView.isHidden = false
        self.senderNameLabel.text = message.senderName
    }
    
    func setDataForForwarSelection(message:MessageModel, leftImage: String?,messageSelected:@escaping ((MessageModel) -> Void)) {
        self.selectMessageButton.isSelected = message.isMessageSelected
        self.selectMessageButton.rx.tap.asDriver().drive(onNext: { _ in
            self.selectMessageButton.isSelected = !self.selectMessageButton.isSelected
            messageSelected(message)
        }).disposed(by: bag)
        self.config(forMessage: message, leftImage: leftImage) { (_) in
            
        }
       
        self.selectMessageButtonWidth.constant = 36
    }
    
    private func setupForURL(message:String,label : UILabel)  {
        if let urlMessageRange = message.checkForURL() {
            let attribute = NSMutableAttributedString.init(string: message)
            attribute.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: urlMessageRange)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: urlMessageRange)
            label.attributedText = attribute
        }else {
            label.text = message

        }
    }
}
