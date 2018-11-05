//
//  ExploreViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/11/5.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ExploreViewController: KLModuleViewController, KLVMVC {
    
    var viewModel: ExploreTabViewModel!
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }

    typealias ViewModel = ExploreTabViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Void
    
    @IBOutlet weak var friendsTitleLabel: UILabel!
    @IBOutlet weak var friendsSepLine: UIImageView!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var newsSepLine: UIImageView!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet weak var videosSepLine: UIImageView!
    @IBOutlet weak var dappLabel: UILabel!
    @IBOutlet weak var dappSepLine: UIImageView!
    @IBOutlet weak var dappButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        let separators = [newsSepLine, dappSepLine, videosSepLine, friendsSepLine]
        for sepLine in separators {
            sepLine?.backgroundColor = palette.sepline
        }
        let labels = [newsLabel,dappLabel,videosLabel,friendsTitleLabel]
        for label in labels {
            label?.set(textColor: palette.label_main_1, font: .owMedium(size: 20))
        }
        dappButton.setTitleColorForAllStates(palette.label_main_1)
    }
  
    override func renderLang(_ lang: Lang) {
        self.title = "Explore"
        self.newsLabel.text = "News"
        self.videosLabel.text = "Videos"
        self.friendsTitleLabel.text = "Friend"
        self.dappLabel.text = "DApps"
        dappButton.set(image: #imageLiteral(resourceName: "arrowButtonPinkSolid"),
                       title: "See all",
                       titlePosition: .left,
                       additionalSpacing: 8,
                       state: .normal)
        
    }
    
}
