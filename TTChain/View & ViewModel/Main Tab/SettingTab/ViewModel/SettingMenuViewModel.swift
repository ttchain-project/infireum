//
//  SettingMenuViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class SettingMenuViewModel: KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
    }
    var input: Void
    var output: Void
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    typealias InputSource = Void
    typealias OutputSource = Void
    var bag: DisposeBag = DisposeBag.init()
    
    
    lazy var datasource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        }, configureSupplementaryView: { (source, cv, kind, indexPath) -> UICollectionReusableView in
            fatalError()
        })
        return source
    }()
}
