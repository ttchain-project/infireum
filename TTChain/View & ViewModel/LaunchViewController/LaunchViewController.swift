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


    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        progressBar.setProgress(0.4, animated: false)
        let transform = CGAffineTransform.init(scaleX: 1.0, y:4.0)
        self.progressBar.transform = transform
        self.progressBar.layoutIfNeeded()
        UIView.animate(withDuration: 3.9) {
            self.progressBar.setProgress(1, animated: true)
        }
        self.loadingLabel.text = LM.dls.loading_please_wait_label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
