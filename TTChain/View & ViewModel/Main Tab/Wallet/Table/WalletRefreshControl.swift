//
//  WalletRefreshControl.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/3/9.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import Cartography

class WalletRefreshControl: UIRefreshControl {

    var isAnimating: Bool = false
    fileprivate let indicator: UIActivityIndicatorView = UIActivityIndicatorView.init()
    fileprivate let statusLabel: UILabel = UILabel.init()
    fileprivate let dateLabel: UILabel = UILabel.init()
    
    var lastUpdatedDate: Date = Date.init() {
        didSet {
            let format = "HH:mm:ss"
//            dateLabel.text = LS.funds_refresh_lastUpdatedDate.format(with: DateFormatter.dateString(from: lastUpdatedDate, withFormat: format))
            
            dateLabel.text = DateFormatter.dateString(from: lastUpdatedDate, withFormat: format)
        }
    }
    
    enum Status {
        case pulling
        case overpulled
        case loading
        case finished
    }
    
    override init() {
        super.init()
        
        tintColor = .clear
        
        statusLabel.textColor = .owBlack
        dateLabel.textColor = .owBlack
        statusLabel.font = UIFont.owRegular(size: 16)
        dateLabel.font = UIFont.owRegular(size: 16)
        
        switchStatus(.pulling)
        
        indicator.hidesWhenStopped = false
        indicator.activityIndicatorViewStyle = .gray
//        indicator.color = .red
        
        addSubview(statusLabel)
        addSubview(dateLabel)
        addSubview(indicator)
        
        constrain(statusLabel) { (label) in
            let sup = label.superview!
            label.bottom == sup.centerY - 2
            label.leading == sup.centerX * 0.65
        }
        
        constrain(dateLabel, statusLabel) { (date, status) in
            date.top == status.bottom + 4
            date.leading == status.leading
        }
        
        constrain(indicator, statusLabel) { (ind, status) in
            let sup = ind.superview!
            ind.centerY == sup.centerY
            ind.trailing == status.leading - 20
            ind.width == 30
            ind.height == 30
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        indicator.startAnimating()
        switchStatus(.loading)
    }
    
    override func sendActions(for controlEvents: UIControlEvents) {
        super.sendActions(for: controlEvents)
        switch controlEvents {
        case UIControlEvents.valueChanged:
            indicator.startAnimating()
            switchStatus(.loading)
        default:
            break
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        switchStatus(.finished)
        indicator.stopAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.switchStatus(.pulling)
        }
        
    }
    
    private func switchStatus(_ status: Status) {
        let dls = LM.dls
        switch status {
        case .pulling:
            statusLabel.text = dls.walletOverview_refresher_status_pulling
        case .overpulled:
            statusLabel.text = dls.walletOverview_refresher_status_overpulled
        case .loading:
            statusLabel.text = dls.walletOverview_refresher_status_loading
        case .finished:
            statusLabel.text = dls.walletOverview_refresher_status_finished
            lastUpdatedDate = Date.init()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
