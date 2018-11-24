//
//  MyQRCodeViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/23.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MyQRCodeViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    
    
//    let rocketChat = RocketChatWebSocket.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        tabBarController?.tabBar.isHidden = true
    }


    typealias Constructor = Void
    var viewModel: DepositViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    func config(constructor: Void) {
        
//        navigationBar?.topItem?.backBarButtonItem = UIBarButtonItem()
        
        monitorLang { (lang) in
            self.title = "我的二維碼"
        }
        
    }

    @IBAction func didPressed(_ sender: Any) {
        
        let username = "SongHua5"
        let password = "aaaa1324"
        
        let button = sender as? UIButton
        
//        if false {
//        } else if button == connectButton {
//            rocketChat.delegate = self
//            rocketChat.connectServer()
//        } else if button == addFriendButton {
//            rocketChat.ooioi()
//        } else if button == sendMessageButton {
//            rocketChat.send(string: "Test message")
//        } else if button == createRoomButton {
//            rocketChat.login2(email: "\(username)@mail.com", password: password)
//        } else if button == loginButton {
//            rocketChat.login(email: "\(username)@mail.com", password: password)
//        } else if button == registerButton {
//            rocketChat.registerNewUser(email: "\(username)@mail.com", name: username, password: password)
//        }
    }
    
    
    @IBAction func actionDisconnect(_ sender: Any) {
//        rocketChat.disconnect()
    }
}

