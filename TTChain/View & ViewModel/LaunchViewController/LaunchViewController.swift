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
import FLAnimatedImage

class LaunchViewController: UIViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()

    @IBOutlet weak var fromImage: FLAnimatedImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.owIceCold
        
        let path1 : String = Bundle.main.path(forResource: "tt_splash", ofType:"gif")!
        let url = URL(fileURLWithPath: path1)
        guard let gifData = try? Data(contentsOf: url) else {
            return
        }

        let splashGIF = FLAnimatedImage.init(animatedGIFData: gifData)
        self.fromImage.animatedImage = splashGIF
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
