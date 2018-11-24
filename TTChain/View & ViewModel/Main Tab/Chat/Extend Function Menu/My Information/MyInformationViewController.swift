//
//  MyInformationViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/23.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MyInformationViewController: KLModuleViewController, KLVMVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }


    typealias Constructor = Void
    var viewModel: DepositViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    func config(constructor: Void) {
        monitorLang { (lang) in
            self.title = "個人信息"
        }
    }
}
