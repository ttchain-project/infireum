//
//  UnknownFileTableViewCell.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/30.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class UnknownFileTableViewCell: UITableViewCell {

    var bag: DisposeBag = DisposeBag.init()
    @IBOutlet weak var profilePics: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet var senderConstraint: NSLayoutConstraint!
    @IBOutlet var receiverConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
        // Initialization code
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
        
        dateLabel.set(textColor: .black, font: .owMedium(size: 14))
        senderNameLabel.set(textColor: .black, font: .owDemiBold(size: 16))
        profilePics.layer.cornerRadius = 20
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    func setMessage(forMessage message:MessageModel, leftImage: String?, leftImageAction:@escaping ((String) -> Void)) {
        dateLabel.text = message.timestamp.string()
        if message.isUserSender() {
            self.profilePics.isHidden = true
            self.dateLabel.textAlignment = .right
            self.senderNameLabel.text = ""
            self.bgView.backgroundColor = UIColor.init(red: 137, green: 216, blue: 128)
            
        }else {
            self.profilePics.isHidden = false
            self.dateLabel.textAlignment = .left
            self.profilePics.setProfileImage(image: leftImage, tempName: message.senderName)
            self.senderNameLabel.text = message.senderName
            self.bgView.backgroundColor = UIColor.white

        }
        self.profilePics.rx.klrx_tap.asDriver().drive(onNext: { _ in
            leftImageAction(message.messageId)
        }).disposed(by: bag)
        
        if let url = URL.init(string: message.msg)  {
            self.fileNameLabel.text = url.lastPathComponent
        }else {
            self.fileNameLabel.text = message.msg
        }
            self.msgImageView.image = #imageLiteral(resourceName: "iconFileColor")
        }
}
