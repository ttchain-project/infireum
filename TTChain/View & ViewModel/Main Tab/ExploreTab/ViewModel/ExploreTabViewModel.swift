//
//  ExploreTabViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/11/5.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class ExploreTabViewModel: KLRxViewModel {

    struct Input {
        let selectionIdxPath: Driver<IndexPath>
    }

    struct Output {
        let selectedModel: (MarketTest) -> Void
        let scrollToNextOptions: () -> Void
    }
    required init(input: Input, output: Output) {
        self.input = input
        self.output = output
        self.concatInput()
    }

    var input: Input
    var output: Output
    func concatInput() {
        input.selectionIdxPath.drive(onNext: { [unowned self](indexpath) in
            switch indexpath.section {
            case 0:
                //ChatGroup
                self.joinPublicGroup(groupModel: MarketTestHandler.shared.chatGroupArray.value[indexpath.row])
            case 1:
                //FinNews
                self.output.selectedModel(MarketTestHandler.shared.finNewsArray.value[indexpath.row])
            case 2:
                //Daps
                self.output.selectedModel(MarketTestHandler.shared.dappArray.value[indexpath.row])
            case 3:
                //Explore
                self.output.selectedModel(MarketTestHandler.shared.explorerArray.value[indexpath.row])

            default:
                print("")
            }

        }).disposed(by: bag)

        self.timerSub = timer.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            self.output.scrollToNextOptions()
        })
    }

    func concatOutput() {

    }
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()

    lazy var timer: Observable<NSInteger> = { return Observable<NSInteger>.interval(3, scheduler: SerialDispatchQueueScheduler(qos: .background)) }()

    var timerSub: Disposable?

    struct shortcutsItem {
        var label: String
        var img: UIImage
    }

    lazy var shortcutsArray: [shortcutsItem] = {
        return [shortcutsItem(label: "意見回饋", img: #imageLiteral(resourceName: "iconReply")),
            shortcutsItem(label: "隱私政策", img: #imageLiteral(resourceName: "iconPolicy")),
            shortcutsItem(label: "幫助中心", img: #imageLiteral(resourceName: "iconHelp")),
            shortcutsItem(label: "關於我們", img: #imageLiteral(resourceName: "iconAbout"))]
    }()

    lazy var exploreOptionsDataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        }, configureSupplementaryView: { (source, cv, kind, indexPath) -> UICollectionReusableView in
                fatalError()
            })
        return source
    }()

    lazy var marketCoinDataSource: RxTableViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxTableViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UITableViewCell in
            let cell: CoinMarketTableViewCell = tv.dequeueReusableCell(withClass: CoinMarketTableViewCell.self, for: idxPath)
            cell.config(model: model as! CoinMarketModel)
            cell.srNoLabel.text = "\(idxPath.row + 1)"
            return cell
        })
        return source
    }()

    lazy var bannerDataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        })
        return source
    }()

    lazy var shortcutsDataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        })
        return source
    }()

    func joinPublicGroup(groupModel: GroupShortcutModel) {

        self.output.selectedModel(groupModel)
//
//        guard let memberId = IMUserManager.manager.userModel.value?.uID else {
//            return
//        }
//        let parameter = GroupMembersAPI.Parameters.init(groupID: groupModel.content, members: [memberId])
//        Server.instance.groupMembers(parameters:parameter).asObservable().subscribe(onNext: { (result) in
//            switch result {
//            case .failed(error: let error):
//                print(error)
//
//            case .success(_):
//                self.output.selectedModel(groupModel)
//            }
//        }).disposed(by: bag)

    }
}
