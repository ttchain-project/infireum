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
    @IBOutlet weak var toImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var backImage: UIImageView {
        return idx.isEven ? fromImage : toImage
    }
    
    private var frontImage: UIImageView {
        return idx.isEven ? toImage : fromImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = titles[0]
        frontImage.image = adsSource[0]
        backImage.image = adsSource[1]
        backImage.alpha = 0
        titleLabel.font = UIFont.owDemiBold(size: 35.3)
        titleLabel.textColor = .owCharcoalGrey
        
        startPhotosSlideAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func startPhotosSlideAnimation() {
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.moveToNextPhoto()
            })
            .disposed(by: bag)
    }
    
    private func moveToNextPhoto() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backImage.alpha = 1
            self.frontImage.alpha = 0
            self.titleLabel.text = self.titles[(self.idx + 1) % self.maxIdx]
        }) { (_) in
            self.idx += 1
            let nextImg = self.adsSource[(self.idx + 1) % self.maxIdx]
            self.backImage.image = nextImg
        }
    }
    
    private var idx: Int = 0
    private var maxIdx: Int {
        return adsSource.count
    }
    
    private var adsSource: [UIImage] {
        return [#imageLiteral(resourceName: "imgTestPictureone"), #imageLiteral(resourceName: "imgTestPicturetwo"), #imageLiteral(resourceName: "imgTestPicturethree")]
    }
    
    private var titles: [String] {
        let dls = LM.dls
        return [
            dls.intro_title_page_one,
            dls.intro_title_page_two,
            dls.intro_title_page_three
        ]
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
