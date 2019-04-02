//
//  PhotoCropperViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/2.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class PhotoCropperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    typealias CompletedImage = ((UIImage) -> Void)
    
    var completedImage:CompletedImage?
    
    var originalImage:UIImage?
    
    let bag = DisposeBag.init()
    init(withImage image:UIImage, completedImage:@escaping CompletedImage) {
        super.init(nibName: PhotoCropperViewController.nameOfClass, bundle: nil)
        self.completedImage = completedImage
        self.originalImage = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var useImageButton: UIButton! {
        didSet {
            useImageButton.setTitle(LM.dls.use_original_image_title, for: .normal)
            useImageButton.backgroundColor = UIColor.owIceCold
            useImageButton.rx.klrx_tap.asDriver().drive(onNext: {[weak self] (_) in
                guard let `self` = self else {
                    return
                }
                self.completedImage!(self.originalImage!)
                
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var useCroppedImageButton: UIButton! {
        didSet {
            useCroppedImageButton.setTitle(LM.dls.use_edited_image_title, for: .normal)
            useCroppedImageButton.backgroundColor = UIColor.owIceCold
            useCroppedImageButton.rx.klrx_tap.asDriver().drive(onNext: {[weak self] (_) in
                guard let `self` = self else {
                    return
                }
                self.getCroppedImage()
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var imageScrollView: ImageScrollView! {
        didSet {
            self.imageScrollView.setup()
            self.imageScrollView.display(image: self.originalImage!)
        }
    }
    @IBOutlet weak var containerView: UIView!
    
    
    func getCroppedImage() {
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        containerView.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        UIGraphicsEndImageContext()
        
        self.completedImage!(image)
    }
}


