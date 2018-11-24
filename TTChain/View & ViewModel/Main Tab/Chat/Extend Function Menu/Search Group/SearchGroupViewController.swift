//
//  SearchGroupViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/26.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchGroupViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    var viewModel: DepositViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    func config(constructor: Void) {
        monitorLang { (lang) in
            self.title = "Search Public Groups"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        tabBarController?.tabBar.isHidden = true
    }


}
