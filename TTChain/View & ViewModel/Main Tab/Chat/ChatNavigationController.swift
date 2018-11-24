//
//  ChatMain2ViewController.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit

class ChatNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = .white
        navigationBar.tintColor = .black
        
        //
        let statusView = UIView.init(frame: UIApplication.shared.statusBarFrame)
        statusView.backgroundColor = .white
        view.addSubview(statusView)
    }
}
