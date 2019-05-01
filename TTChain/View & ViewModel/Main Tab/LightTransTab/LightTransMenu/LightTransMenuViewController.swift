//
//  LightTransMenuViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightTransMenuViewController: KLModuleViewController,KLVMVC {
  
    var viewModel: LightTransViewModel!
    
    func config(constructor: LightTransMenuViewController.Config) {
        view.layoutIfNeeded()
        self.viewModel = LightTransViewModel.init(input: LightTransViewModel.Input(),output: LightTransViewModel.Output())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.bindUI()
    }
    
    typealias ViewModel = LightTransViewModel
    var bag: DisposeBag = DisposeBag.init()
    typealias Constructor = Config
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Config {
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.lightning_payment_title
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette

        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        self.view.backgroundColor = UIColor.init(hexString: "2C3C4E")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.refreshAllData()

    }
    func bindUI(){
        
        self.tableView.register(cellType: LightTransMenuTableViewCell.self)
        self.tableView.backgroundColor = .clear
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 40, 0)
        self.viewModel.assets.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: LightTransMenuTableViewCell.className, cellType: LightTransMenuTableViewCell.self)) {[weak self]
            row, asset, cell in
            guard let `self` = self else {
                return
            }
            let balance = self.viewModel.amt(ofAsset: asset).asObservable()
            cell.config(asset: asset,amtSource:balance,transferAction: { asset in self.showTransferAction(asset: asset)}, depositAction: {asset in self.showDepositAction(asset: asset)})
            
            switch row {
            case 1:
                cell.bgView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "FFA734")!.cgColor, UIColor.init(hexString: "FFDB24")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
            case 2:
                cell.bgView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "417C9E")!.cgColor,UIColor.init(hexString: "A6C1DC")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
            case 3:
                
                cell.bgView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "208588")!.cgColor,UIColor.init(hexString: "1CC491")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
            default:
                
                cell.bgView.setGradientColor(cgColors: [UIColor.clear.cgColor,UIColor.init(hexString: "098A95")!.cgColor,UIColor.init(hexString: "18ADD4")!.cgColor],startPoint:CGPoint.init(x:0.11,y:0.0),endPoint:CGPoint.init(x:1.0,y:0))
            }
            
            }.disposed(by:bag)
        
        self.tableView.rx.itemSelected.asDriver().drive(onNext: { (path) in
            if self.viewModel.assets.value.indices.contains(path.row) {
                self.showLightDetail(asset: self.viewModel.assets.value[path.row])
            }
        }).disposed(by: bag)
    }
    
    func showTransferAction(asset:Asset) {
        
    }
    func showDepositAction(asset:Asset) {
    }
    
    func showLightDetail(asset:Asset) {
        let viewModel = LightTransDetailViewModel.init(withAsset: asset)
        let vc = LightTransDetailViewController.init(withViewModel: viewModel)
        let navController = UINavigationController.init(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
}
