//
//  ExploreDetailWebViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/15.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

final class ExploreDetailWebViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let model:MarketTest?
        let url:URL?
    }
    var viewModel: ExploreDetailWebViewModel!
    
    func config(constructor: ExploreDetailWebViewController.Constructor) {
        self.view.setNeedsLayout()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        self.title = constructor.model?.title ?? ""
        if let url = constructor.model?.url {
            if url.scheme == "app" {
                let key = url.absoluteString.replacingOccurrences(of: "app://", with: "")
                if key == SettingKeyEnum.MarketTool.rawValue {
                    self.handleMarketToolData()
                }
            }else {
                self.webview.load(URLRequest.init(url: url))
            }
        }else {
            guard let url = constructor.url else {
                return
            }
            self.webview.load(URLRequest.init(url:url))
            
        }
    }
    
    typealias ViewModel = ExploreDetailWebViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Config
    
    @IBOutlet weak var webview: WKWebView!
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        
        if self.navigationController?.viewControllers.count == 1 {
            changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        }
        
    }
    
    override func renderLang(_ lang: Lang) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func handleMarketToolData() {
        let marketTools = MarketTestHandler.shared.marketToolArray.value
        var htmlString =  "<!DOCTYPE html>\n" +
            "<html>\n" +
            "<head>\n" +
            "<title>行情數據</title>\n" +
            "</head>\n" +
        "<body>"
        
        for marketTool in marketTools {
            htmlString.append(marketTool.content)
        }
        
        htmlString.append("</body>\n </html>")
        
        self.webview.loadHTMLString(htmlString, baseURL: nil)
    }
}
