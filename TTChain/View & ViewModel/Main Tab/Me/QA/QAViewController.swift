//
//  QAViewController.swift
//  OfflineWallet
//
//  Created by Patato on 2018/10/3.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

final class QAViewController: KLModuleViewController, KLVMVC, UIWebViewDelegate {
    typealias ViewModel = QAViewModel
    var bag: DisposeBag = DisposeBag.init()
    typealias Constructor = Config
    struct Config {
        let identity: Identity
    }
    var viewModel: QAViewModel!
    
    func config(constructor: QAViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: QAViewModel.InputSource(identity: constructor.identity), output: ())
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    @IBOutlet weak var QAWebView: UIWebView!
    
   
    
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.me_label_qa
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        changeNavShadowVisibility(true)
        
        view.backgroundColor = palette.bgView_sub
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QAWebView.delegate = self
        
        let request = URLRequest.init(url: C.FAQ.FAQURL)
        QAWebView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
