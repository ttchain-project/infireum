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
import Photos

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
                self.createRightBarButton(target: self, selector: #selector(self.saveImage), title: LM.dls.ab_update_btn_save,toColor:.owWhite, shouldClear: true)
                self.image = img
                self.imageScrollView.display(image: img)
            }
        }
    }
    
    var viewModel: ChatImageViewModel!
    
    struct Config {
        let image:URL
    }
    var image: UIImage?
    
    typealias Constructor = Config
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias ViewModel = ChatImageViewModel
    
    @IBOutlet weak var imageScrollView: ImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func saveImage() {
        guard self.image != nil else {
            return
        }
        ImageSaver.saveImage(image: image!, onViewController: self).subscribe(onSuccess: { (_) in
            DLogInfo("Success")
        }) { (error) in
            DLogError(error)
        }.disposed(by: bag)
    }
}
