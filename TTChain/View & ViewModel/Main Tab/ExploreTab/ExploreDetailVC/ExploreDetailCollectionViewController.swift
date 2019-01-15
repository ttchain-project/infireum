//
//  ExploreDetailCollectionViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/15.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

final class ExploreDetailCollectionViewController: KLModuleViewController, KLVMVC {
   
    struct Config {
        var marketModel:MarketTestTabModel
    }
    
    func config(constructor: Config) {
        self.view.setNeedsLayout()
        self.viewModel = ExploreDetailCollectionViewModel.init(input: ExploreDetailCollectionViewModel.Input(marketModel:constructor.marketModel), output: ())
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        self.configCollectionView()
        self.bindCollectionView()
        
    }
    
    var viewModel: ExploreDetailCollectionViewModel!
    
    typealias ViewModel = ExploreDetailCollectionViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Config
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func configCollectionView() {
        collectionView.register(SettingMenuCollectionViewCell.nib,
                                      forCellWithReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier())
        collectionView.delegate = self
    }
    func bindCollectionView() {
        viewModel.dataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: indexPath) as! SettingMenuCollectionViewCell
            cell.setupCell(model:settingModel)
            return cell
        }
        
        viewModel.marketArray.bind(to: collectionView.rx.items(
            dataSource: viewModel.dataSource)
            )
            .disposed(by: bag)
        
    }
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        changeLeftBarButtonToDismissToRoot(tintColor: theme.palette.nav_item_2, image: #imageLiteral(resourceName: "navBarBackButton"), title: nil)

    }
    
    override func renderLang(_ lang: Lang) {
        
    }

    
}
extension ExploreDetailCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.width - 80)/4
        let height = width + 30
        let size = CGSize.init(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets.init(top: 5, left: 20, bottom: 5, right: 10)
    }
}
