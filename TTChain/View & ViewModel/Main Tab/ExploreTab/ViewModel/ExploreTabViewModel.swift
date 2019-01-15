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
    }
    
    var input: Input
    var output: Output
    func concatInput() {
        input.selectionIdxPath.drive(onNext: { [unowned self](indexpath) in
            _ = MarketTestHandler.shared.exploreOptionsObservable.map { sectionArray -> Void in
                self.output.selectedModel(sectionArray[indexpath.section].items[indexpath.row])
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
}
