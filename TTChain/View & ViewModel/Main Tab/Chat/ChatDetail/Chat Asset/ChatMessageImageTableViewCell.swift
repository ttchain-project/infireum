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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        
        self.msgImageView.layer.borderWidth = 5.0
        self.msgImageView.layer.borderColor = UIColor.white.cgColor
        dateLabel.set(textColor: .gray, font: .owMedium(size: 9))
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: UIImage?, leftImageAction:@escaping ((String) -> Void)) {
        dateLabel.text = message.timestamp.string()
        if message.senderId == RocketChatManager.manager.rocketChatUser.value?.rocketChatUserId {
            self.profilePics.isHidden = true
        }else {
            self.profilePics.isHidden = false
        }
        self.profilePics.rx.tapGesture().asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
        

        
        guard let url = URL.init(string: message.msg) else {
            return
        }
        self.msgImageView.af_setImage(withURL: url, placeholderImage: UIImage.init())
    }
}
