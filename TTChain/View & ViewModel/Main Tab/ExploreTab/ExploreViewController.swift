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
import MessageUI
final class ExploreViewController: KLModuleViewController, KLVMVC, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    var viewModel: ExploreTabViewModel!

    func config(constructor: Void) {
        view.layoutIfNeeded()
        self.viewModel =
            ExploreTabViewModel.init(input: ExploreTabViewModel.InputSource(selectionIdxPath: self.exploreOptionsCollectionView.rx.itemSelected.asDriver()), output: ExploreTabViewModel.OutputSource(selectedModel: { model in
                        if model is GroupShortcutModel {
                            self.showGroupChat(model: model as! GroupShortcutModel)
                        } else {
                            self.handleShortcutNavigation(model: model as! MarketTestTabModel)
                        }
                }, scrollToNextOptions: {
                            self.scrollToNextCell()
                    }))
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        self.configCollectionView()
        self.bindCollectionView()

    }

    typealias ViewModel = ExploreTabViewModel

    var bag: DisposeBag = DisposeBag.init()

    typealias Constructor = Void

    @IBOutlet weak var bannerCollectionView: UICollectionView!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var exploreShortcutsCollectionView: UICollectionView!
    @IBOutlet weak var exploreOptionsCollectionView: UICollectionView!
    @IBOutlet weak var coinMarketTableView: UITableView!
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
        exploreShortcutsCollectionView.register(ExploreShortcutCollectionViewCell.nib,
            forCellWithReuseIdentifier: ExploreShortcutCollectionViewCell.cellIdentifier())
        exploreOptionsCollectionView.register(SettingMenuCollectionViewCell.nib,
            forCellWithReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier())
        coinMarketTableView.register(nib: CoinMarketTableViewCell.nib, withCellClass: CoinMarketTableViewCell.self)

        exploreOptionsCollectionView.register(SettingMenuHeaderCollectionReusableView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className)
    }

    func bindCollectionView() {
        viewModel.exploreOptionsDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in

            let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: indexPath) as! SettingMenuCollectionViewCell
            cell.setupCell(model: settingModel)
            return cell
        }

        viewModel.exploreOptionsDataSource.configureSupplementaryView = { (datasource, cv, kind, indexpath) in
            if (kind == UICollectionElementKindSectionHeader) {
                let headerView = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexpath) as! SettingMenuHeaderCollectionReusableView

                switch indexpath.section {
                case 0:
                    headerView.setup(title: LM.dls.hot_group, subTitle: LM.dls.hot_group_sub)
                case 1:
                    headerView.setup(title: LM.dls.media, subTitle: LM.dls.media_sub)
                case 2:
                    headerView.setup(title: LM.dls.dapp, subTitle: LM.dls.dapp_sub)
                case 3:
                    headerView.setup(title: LM.dls.blockchain_explorer, subTitle: LM.dls.blockchain_explorer_sub)
                default: break
                }
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

        //        self.exploreShortcutsCollectionView.rx.contentSize.asObservable().subscribe(onNext: { [unowned self](size) in
        //            let height = size.height
        //            self.shortcutsViewHeight.constant = height
        //            self.view.setNeedsLayout()
        //        }).disposed(by: bag)

        self.coinMarketTableView.rx.contentSize.asObservable().subscribe(onNext: { [unowned self](size) in
            let height = size.height
            self.coinMarketHeight.constant = height
            self.view.setNeedsLayout()
        }).disposed(by: bag)

        viewModel.bannerDataSource.configureCell = {
            (datasource, cv, indexPath, settingModel) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.cellIdentifier(), for: indexPath) as! BannerCollectionViewCell
            cell.bannerImageView.af_setImage(withURL: URL.init(string: settingModel.img)!)
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
            if settingModel.isExternalLink, settingModel.url != nil {
                NSLog("url: " + settingModel.url!.absoluteString)
                if settingModel.url!.absoluteString == "internal://wallet" {
                    (self.view.window?.rootViewController as! MainTabBarViewController).selectedIndex = 0
                } else if settingModel.url!.absoluteString == "internal://chat" {
                    self.view.window?.rootViewController?.tabBarController?.selectedIndex = 1
                } else if settingModel.url!.absoluteString == "internal://trade" {
                    self.view.window?.rootViewController?.tabBarController?.selectedIndex = 2
                } else if settingModel.url!.absoluteString == "internal://explorer" {
                    self.view.window?.rootViewController?.tabBarController?.selectedIndex = 3
                } else if settingModel.url!.absoluteString == "internal://setting" {
                    self.view.window?.rootViewController?.tabBarController?.selectedIndex = 4
                } else if UIApplication.shared.canOpenURL(settingModel.url!) {
                    UIApplication.shared.open(settingModel.url!, options: [:], completionHandler: nil)
                }
            }
        }).disposed(by: bag)


        Observable.of(self.viewModel.shortcutsArray)
            .bind(to: self.exploreShortcutsCollectionView.rx.items) { cv, row, element in
                let cell = cv.dequeueReusableCell(withClass: ExploreShortcutCollectionViewCell.self, for: IndexPath.init(row: row, section: 0))
                cell.titleLabel.text = element
                return cell
            }.disposed(by: bag)

        exploreShortcutsCollectionView.rx.itemSelected.subscribe(onNext: { [unowned self] (indexPath) in
            if indexPath.row == 0 {
                self.sendMail()
            }
        }).disposed(by: bag)

        MarketTestHandler.shared.coinMarketArray
            .bind(to: coinMarketTableView.rx.items(
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
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
    }

    override func renderLang(_ lang: Lang) {
        self.navigationItem.title = lang.dls.tab_explorer
        self.exploreOptionsCollectionView.reloadData()
    }

    func handleShortcutNavigation(model: MarketTestTabModel) {
        if model.isExternalLink {
            let vc = ExploreDetailWebViewController.navInstance(from: ExploreDetailWebViewController.Config(model: model, url: nil))
            self.present(vc, animated: true, completion: nil)
        } else {
            guard let url = model.url else {
                return
            }
            if url.scheme == "app" {
                let key = url.absoluteString.replacingOccurrences(of: "app://", with: "")
                if key == SettingKeyEnum.MarketTool.rawValue {
                    let vc = ExploreDetailWebViewController.navInstance(from: ExploreDetailWebViewController.Config(model: model, url: nil))
                    self.present(vc, animated: true, completion: nil)
                } else {
                    let vc = ExploreDetailCollectionViewController.navInstance(from: ExploreDetailCollectionViewController.Config(marketModel: model))
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    func showGroupChat(model: GroupShortcutModel) {

        let vc = ChatViewController.instance(from: ChatViewController.Config(roomType: .channel, chatTitle: model.title, roomID: model.content, chatAvatar: model.img, uid: nil, entryPoint: .chatList))
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

    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let message: String = ""
            let composePicker = MFMailComposeViewController()
            composePicker.mailComposeDelegate = self
            composePicker.delegate = self
            composePicker.setToRecipients(["service@ttchainplus.io"])
            composePicker.setSubject("")
            composePicker.setMessageBody(message, isHTML: false)
            self.present(composePicker, animated: true, completion: nil)
        } else {
            self .showErrorMessage()
        }
    }
    func showErrorMessage() {
        let alertMessage = UIAlertController(title: "Could not sent email", message: "Check if your device has email support!", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alertMessage.addAction(action)
        self.present(alertMessage, animated: true, completion: nil)
    }


    //MARK: - Mail Composer Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView == self.bannerCollectionView ? collectionView.width : ((collectionView.width - 80) / 4)
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

        case self.exploreOptionsCollectionView:
            return UIEdgeInsets.init(top: 5, left: 20, bottom: 5, right: 10)
        default:
            return UIEdgeInsets.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        switch collectionView {
        case self.exploreOptionsCollectionView:
            return CGSize.init(width: self.view.width, height: 62)
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
