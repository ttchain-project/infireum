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
        self.viewModel =
            ExploreTabViewModel.init(input: ExploreTabViewModel.InputSource(selectionIdxPath:self.exploreOptionsCollectionView.rx.itemSelected.asDriver()), output: ExploreTabViewModel.OutputSource(selectedModel: { model in
                if model is GroupShortcutModel {
                    self.showGroupChat(model:model as! GroupShortcutModel)
                }else {
                    self.handleShortcutNavigation(model: model as! MarketTestTabModel)
                }
            }, scrollToNextOptions: {
                self.scrollToNextCell()
            }))
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        self.configCollectionView()
        self.bindCollectionView()
        
        let superview = self.exploreShortcutsCollectionView.superview
        superview?.shadowColor = UIColor.gray
        superview?.shadowRadius = 5.0
        superview?.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
        superview?.shadowOpacity = 1.0
        
        exploreShortcutsCollectionView?.layer.cornerRadius = 5.0
        exploreShortcutsCollectionView?.layer.masksToBounds = true
    }

    typealias ViewModel = ExploreTabViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Void
    
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var exploreShortcutsCollectionView: UICollectionView!
    @IBOutlet weak var exploreOptionsCollectionView: UICollectionView!
    @IBOutlet weak var coinMarketCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var optionsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shortcutsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var coinMarketHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func configCollectionView() {
        bannerCollectionView.register(BannerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: BannerCollectionViewCell.cellIdentifier())
        exploreShortcutsCollectionView.register(SettingMenuCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier())
        exploreOptionsCollectionView.register(SettingMenuCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier())
        coinMarketCollectionView.register(CoinMarketCollectionViewCell.nib,
                                              forCellWithReuseIdentifier: CoinMarketCollectionViewCell.cellIdentifier())
        exploreOptionsCollectionView.register(SettingMenuHeaderCollectionReusableView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className)
        coinMarketCollectionView.register(SettingMenuHeaderCollectionReusableView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className)

    }
    
    func bindCollectionView() {
        viewModel.exploreOptionsDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in

                let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: indexPath) as! SettingMenuCollectionViewCell
                cell.setupCell(model:settingModel)
                return cell
        }
        
        viewModel.exploreOptionsDataSource.configureSupplementaryView = { (datasource, cv, kind, indexpath) in
            if (kind == UICollectionElementKindSectionHeader) {
                let headerView = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexpath) as!  SettingMenuHeaderCollectionReusableView
              
                var title :String {
                    switch indexpath.section {
                    case 0:
                    return LM.dls.hot_group
                    case 1:
                    return LM.dls.media
                    case 2:
                    return "dApp"
                    case 3:
                    return LM.dls.blockchain_explorer
                    default: return ""
                    }
                }
                
                headerView.setup(title:title)
                return headerView
            }
            return UICollectionReusableView()
        }
        
        MarketTestHandler.shared.exploreOptionsObservable
            .bind(to: exploreOptionsCollectionView.rx.items(
                dataSource: viewModel.exploreOptionsDataSource)
            )
            .disposed(by: bag)
            
        self.exploreOptionsCollectionView.rx.contentSize.asObservable().subscribe(onNext: { [unowned self](size) in
            let height = size.height
            self.optionsCollectionViewHeight.constant = height
            self.view.setNeedsLayout()
        }).disposed(by: bag)
        
        self.exploreShortcutsCollectionView.rx.contentSize.asObservable().subscribe(onNext: { [unowned self](size) in
            let height = size.height
            self.shortcutsViewHeight.constant = height
            self.view.setNeedsLayout()
        }).disposed(by: bag)
        
        self.coinMarketCollectionView.rx.contentSize.asObservable().subscribe(onNext: { [unowned self](size) in
            let height = size.height
            self.coinMarketHeight.constant = height
            self.view.setNeedsLayout()
        }).disposed(by: bag)
        
        viewModel.bannerDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.cellIdentifier(), for: indexPath) as! BannerCollectionViewCell
            cell.bannerImageView.af_setImage(withURL: URL.init(string:settingModel.img)!)
            return cell
        }
        
        MarketTestHandler.shared.bannerArray.map { array in
            guard array.count > 0, array[0].items.count > 0 else {
                return array
            }
            
            self.pageControl.numberOfPages = array[0].items.count
            return array
            }
            .bind(to: bannerCollectionView.rx.items(
                dataSource: viewModel.bannerDataSource)
            )
            .disposed(by: bag)
        
        bannerCollectionView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let settingModel: MarketTestTabModel = MarketTestHandler.shared.bannerArray.value[indexPath.section].items[indexPath.row] as! MarketTestTabModel
            if settingModel.isExternalLink , settingModel.url != nil{
                if UIApplication.shared.canOpenURL(settingModel.url!) {
                    UIApplication.shared.open(settingModel.url!, options: [:], completionHandler: nil)
                }
            }
        }).disposed(by: bag)
        
        viewModel.shortcutsDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: indexPath) as! SettingMenuCollectionViewCell
            cell.setupCell(model:settingModel)
            return cell
        }
        
        MarketTestHandler.shared.discoveryArray
            .bind(to: exploreShortcutsCollectionView.rx.items(
                dataSource: viewModel.shortcutsDataSource)
            )
            .disposed(by: bag)
        
        exploreShortcutsCollectionView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let settingModel: MarketTestTabModel = MarketTestHandler.shared.discoveryArray.value[indexPath.section].items[indexPath.row] as! MarketTestTabModel
            self.handleShortcutNavigation(model: settingModel)
        }).disposed(by: bag)
        
        viewModel.marketCoinDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: CoinMarketCollectionViewCell.cellIdentifier(), for: indexPath) as! CoinMarketCollectionViewCell
            cell.setup(model:settingModel as! CoinMarketModel)
            return cell
        }
        
        viewModel.marketCoinDataSource.configureSupplementaryView = { (datasource, cv, kind, indexpath) in
            if (kind == UICollectionElementKindSectionHeader) {
                let headerView = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexpath) as!  SettingMenuHeaderCollectionReusableView
                headerView.setup(title:LM.dls.trend)
                return headerView
            }
            return UICollectionReusableView()
        }
        
        MarketTestHandler.shared.coinMarketArray
            .bind(to: coinMarketCollectionView.rx.items(
                dataSource: viewModel.marketCoinDataSource)
            )
            .disposed(by: bag)
        
        bannerCollectionView.rx.didScroll.asObservable().subscribe(onNext: { () in
            
            let width = self.bannerCollectionView.frame.width
            let page = ((self.bannerCollectionView.contentOffset.x - width / 2.0) / width) + 1.0
            self.pageControl.currentPage = Int(page)
            
        }).disposed(by: bag)
    }
    

    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
    }
  
    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.tab_explorer
    }
    
    func handleShortcutNavigation(model:MarketTestTabModel) {
        if model.isExternalLink {
            let vc = ExploreDetailWebViewController.navInstance(from: ExploreDetailWebViewController.Config(model:model))
            self.present(vc, animated: true, completion: nil)
        }else {
            guard let url = model.url else {
                return
            }
            if url.scheme == "app" {
                let key = url.absoluteString.replacingOccurrences(of: "app://", with: "")
                if key == SettingKeyEnum.MarketTool.rawValue {
                    let vc = ExploreDetailWebViewController.navInstance(from: ExploreDetailWebViewController.Config(model:model))
                    self.present(vc, animated: true, completion: nil)
                }else {
                    let vc = ExploreDetailCollectionViewController.navInstance(from: ExploreDetailCollectionViewController.Config(marketModel:model))
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    func showGroupChat(model: GroupShortcutModel) {
       
        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: .channel, chatTitle: model.title, roomID: model.content, chatAvatar: model.img,uid:nil))
        show(vc, sender: self)
    }
    
    func scrollToNextCell() {
        let items = MarketTestHandler.shared.bannerArray.value.first?.items.count ?? 0
        guard let currentIndexPath = self.bannerCollectionView.indexPathsForVisibleItems.first else {
            return
        }
        let nextRow = currentIndexPath.row == (items - 1) ? 0 : currentIndexPath.row + 1
        let nextIndexPath = IndexPath.init(item: nextRow, section: 0)
        self.bannerCollectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
        
    }
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView == self.bannerCollectionView ? collectionView.width : ((collectionView.width - 80)/4)
        let height = collectionView == self.bannerCollectionView ? collectionView.height : width + 30
        let size = CGSize.init(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case self.bannerCollectionView:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)

        case self.exploreShortcutsCollectionView:
            return UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)

        case self.exploreOptionsCollectionView,coinMarketCollectionView:
            return UIEdgeInsets.init(top: 5, left: 20, bottom: 5, right: 10)
        default:
            return UIEdgeInsets.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch collectionView {
        case self.exploreOptionsCollectionView,coinMarketCollectionView:
            return CGSize.init(width: self.view.width, height: 40)
        default:
            return CGSize.zero
        }
       
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if (kind == UICollectionElementKindSectionHeader) {
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexPath) as!  SettingMenuHeaderCollectionReusableView
//            headerView.setup(title:"Title")
//            headerView.backgroundColor = UIColor.gray
//            headerView.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: 40)
//            return headerView
//        }else {
//            return UIView() as! UICollectionReusableView
//        }
//    }
    
}
