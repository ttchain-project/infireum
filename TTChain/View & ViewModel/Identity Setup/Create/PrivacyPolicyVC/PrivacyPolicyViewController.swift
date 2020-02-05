//
//  PrivacyPolicyViewController.swift
//  Infireum
//
//  Created by Ajinkya Sharma on 2019/7/12.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class PrivacyPolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var acceptStatus:((Bool) -> ())
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.set(textColor: .cloudBurst, font: .owMedium(size: 18))
            titleLabel.text = "《 Infireum Wallet隱私政策 》"
        }
    }
    @IBOutlet weak var contentLabel: UILabel! {
        didSet {
            contentLabel.set(textColor: .cloudBurst, font: .owMedium(size: 16))
            contentLabel.text = C.PrivacyPolicyString.content
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!{
        didSet {
            dateLabel.set(textColor: .cloudBurst, font: .owMedium(size: 12))
            dateLabel.text = "最近更新於：2018年12月18日"
        }
    }
    
    @IBOutlet weak var acceptButton: UIButton! {
        didSet {
            acceptButton.setTitleForAllStates(LM.dls.agree_bnt_title)
            acceptButton.rx.klrx_tap.drive(onNext:{self.acceptStatus(true)}).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var rejectButton: UIButton! {
        didSet {
            rejectButton.setTitleForAllStates(LM.dls.reject_request)
            rejectButton.rx.klrx_tap.drive(onNext:{self.acceptStatus(false)}).disposed(by: bag)

        }
    }
    
   
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    var bag:DisposeBag
    
    init(status:@escaping ((Bool) -> ())) {
        self.acceptStatus = status
        bag = DisposeBag()
        super.init(nibName: PrivacyPolicyViewController.nameOfClass, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PrivacyPolicyViewController :UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let verticalIndicator = scrollView.subviews.last as? UIImageView else {
            return
        }
        verticalIndicator.backgroundColor = UIColor.yellowGreen
    }
}
