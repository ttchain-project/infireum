//
//  ChatImageViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/2.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class ChatImageViewController: KLModuleViewController, KLVMVC {
    
    func config(constructor: ChatImageViewController.Config) {
        
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: (), output:())
        
        
        self.imageScrollView.setup()
        KLRxImageDownloader.instance.download(source: constructor.image) {
            result in
            switch result {
            case .failed:
                self.imageScrollView.display(image: #imageLiteral(resourceName: "no_image"))
            case .success(let img):
                self.imageScrollView.display(image: img)
            }
        }
//        self.imageView.af_setImage(withURL: constructor.image, placeholderImage: #imageLiteral(resourceName: "no_image"))
    }
    
    var viewModel: ChatImageViewModel!
    
    struct Config {
        let image:URL
    }
    typealias Constructor = Config
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias ViewModel = ChatImageViewModel
    
    @IBOutlet weak var imageScrollView: ImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
}
