//
//  CommunityManagementViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/8/7.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CommunityManagementViewController: UIViewController, KLInstanceSetupViewController {
    static func instance(from constructor: CommunityManagementViewController.Constructor) -> Self {
        let vc = xib(vc: self)
        vc.config(constructor: constructor)
        return vc
    }
    
    static func navInstance(from constructor: CommunityManagementViewController.Constructor) -> UINavigationController {
        let vc = xib(vc: self)
        let nav = UINavigationController.init(rootViewController: vc)
        vc.config(constructor: constructor)
        return nav
    }
    
    func config(constructor: CommunityManagementViewController.Config) {
        self.view.layoutIfNeeded()
        self.didUpdatePostStatus = constructor.didUpdatePostStatus
        self.postMessageAdminBtn.isSelected = constructor.postMsgStatus
        postMessageAdminBtn.rx.tap.scan(constructor.postMsgStatus){state, _ in
            self.didUpdatePostStatus(!state)
            self.postMessageAdminBtn.isSelected = !self.postMessageAdminBtn.isSelected
            return !state
            }.asObservable().subscribe().disposed(by: bag)
    }
    
    typealias Constructor = Config
    
    struct Config {
        var postMsgStatus:Bool
        var didUpdatePostStatus:((Bool) -> Void)
    }
    
    var didUpdatePostStatus:((Bool) -> Void)!

    var bag = DisposeBag()
    
    @IBOutlet weak var postMessageAdminBtn: UIButton! {
        didSet {
            postMessageAdminBtn.setTitleForAllStates(LM.dls.only_admin_post_title)
            postMessageAdminBtn.set(textColor: TM.palette.label_main_1, font: .owRegular(size:14))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = LM.dls.chat_community_mgmt_label
    }
}
