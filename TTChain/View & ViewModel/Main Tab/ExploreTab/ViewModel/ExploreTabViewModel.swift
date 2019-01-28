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
        let selectedModel:(MarketTest) -> Void
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
            
        } ).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    typealias InputSource = Input
    typealias OutputSource = Output
    var bag: DisposeBag = DisposeBag.init()

    lazy var exploreOptionsDataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        }, configureSupplementaryView: { (source, cv, kind, indexPath) -> UICollectionReusableView in
            fatalError()
        })
        return source
    }()
    
    lazy var marketCoinDataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        }, configureSupplementaryView: { (source, cv, kind, indexPath) -> UICollectionReusableView in
            fatalError()
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
