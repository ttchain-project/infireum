//
//  MainViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

class MainViewController: KLModuleViewController {

    var vc: OWMnemonicViewController!
    
    @IBOutlet weak var base: UIView!
    @IBOutlet weak var vcHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vc = OWMnemonicViewController.instance(from: OWMnemonicViewController.Setup(
            targetMnemonic: "rose rocket invest real refuse margin festival danger anger border idle brown",
            sourceMnemonic: "rose rocket invest real refuse margin festival danger anger border idle brown",
            delete: { (str) in
                print("Delete \(str)")
        },
            match: { (match) in
                print("Match \(String(describing: match))")
        },
            requiredHeight: {
                [unowned self] (height) in
                self.vcHeight.constant = height
                self.view.layoutIfNeeded()
        },
            empty: nil
            )
        )
        
        addChildViewController(vc)
        base.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        constrain(vc.view) { (v) in
            let s = v.superview!
            v.top == s.top
            v.bottom == s.bottom
            v.leading == s.leading
            v.trailing == s.trailing
        }
        
        
        // Do any additional setup after loading the view.
//        let db = DB.instance
//        let setups: [(Coin) -> Void] = [
//        {
//            coin in
//            coin.identifier = "Identifier_BTC"
//            coin.fullname = "Bitcoin"
//            coin.name = "BTC"
//            coin.isActive = true
//            coin.isDefaultSelected = true
//            coin.isSelected = true
//            },
//        {
//            coin in
//            coin.identifier = "Identifier_ETH"
//            coin.fullname = "Ethereum"
//            coin.name = "ETH"
//            coin.isActive = true
//            coin.isDefaultSelected = true
//            coin.isSelected = true
//            }
//        ]
//        
//        let _ = db.batchCreate(type: Coin.self, setups: setups)
//        
//        let coins = db.get(type: Coin.self, predicate: nil, sorts: nil)
//        
//        if let _coins = coins {
//            let coin0 = _coins[0]
//            for coin in _coins {
//                print(coin.identifier!)
//                var newCoin = coin
//                for (n, a) in coin0.entity.attributesByName {
//                    let v = coin0.value(forKeyPath: n)
////                    print("Fetch value: \(v), from name: \(n)")
//                    newCoin.setValue(v, forKeyPath: n)
//                }
////                print("ID Update")
////                print(newCoin.identifier)
////                print("---")
//            }
//        }
//        
////        try! db.save()
//        let newCoins = db.get(type: Coin.self, predicate: nil, sorts: nil)
//        for newC in newCoins! {
//            print(newC.identifier!)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
