//
//  LaunchViewController.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/3/6.
//  Copyright © 2018年 GIT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//import RxOptional

class LaunchViewController: UIViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()

    @IBOutlet weak var fromImage: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.owIceCold
        let splashGIF = UIImage.gifImageWithName("tt_splash")
        self.fromImage.image = splashGIF
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
