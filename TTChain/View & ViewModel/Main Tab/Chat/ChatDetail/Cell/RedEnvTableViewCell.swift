//
//  RedEnvTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/25.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class RedEnvTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }

    func setup() {
        
        dateLabel.set(textColor: .black, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .black, font: .owDemiBold(size: 16))
        
        self.messageContent.set(textColor: .white, font: .owMedium(size: 16))
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.profilePicImageView.cornerRadius = 20.0
        self.bgView.cornerRadius = 5.0
       
        let color1 = UIColor(red:254,green: 135,blue: 98)?.cgColor
        let color2 = UIColor(red:230,green: 75,blue: 75)?.cgColor
//            self.gradientView.setGradientColor(color1:color1, color2: color2)
        self.bgView.setGradientColor(color1:color1, color2: color2)
    }
    
    @IBOutlet weak var gradientView: UIView!
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
    
    func setMessage(forMessage message:MessageModel, leftImage: UIImage?, leftImageAction:@escaping ((String) -> Void)) {
        
        dateLabel.text = message.timestamp.string()
        self.messageContent.text = message.msg
        
        if message.senderId == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId {
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
            self.profilePicImageView.image = leftImage ?? #imageLiteral(resourceName: "no_image")
            self.senderNameLabel.text = message.senderName
            
        }
        self.profilePicImageView.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
    }
}
