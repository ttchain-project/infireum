//
//  ChatHistoryTableViewCell.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class ChatHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        backgroundColor = .clear
        self.coverImageView.cornerRadius = coverImageView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(model: CommunicationListModel) {
        self.coverImageView.af_setImage(withURL: URL.init(string:model.img)!)
        self.titleLabel.text = model.displayName
        self.descriptionLabel.text = model.lastMessage
        self.countLabel.isHidden = true
        self.dateLabel.text = self.getDateFromString(dateString: model.updateTime)
    }

    private func getDateFromString(dateString: String) -> String {
        guard let date = DateFormatter.date(from: dateString, withFormat: C.IMDateFormat.dateFormatForIM) else {
            return ""
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.timeString()
        } else {
            return date.dateString()
        }
    }
    
}
