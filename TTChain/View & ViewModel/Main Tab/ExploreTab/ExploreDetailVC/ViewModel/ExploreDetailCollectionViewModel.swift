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

class ExploreDetailCollectionViewModel: KLRxViewModel {
    
    struct  Input {
        var marketModel:MarketTestTabModel
    }
    required init(input: Input, output: Void) {
        self.input = input
        self.output = output
        fetchArrayContent()
    }
    
    var input: Input
    var output: Void
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var marketArray: BehaviorRelay<[MarketTestSectionModel]> = {
        BehaviorRelay.init(value: [])
    }()
    
    func fetchArrayContent() {
        
        guard let url = self.input.marketModel.url else {
            return
        }
        if url.scheme == "app" {
            let key = url.absoluteString.replacingOccurrences(of: "app://", with: "")
            let settingKey = SettingKeyEnum.init(rawValue: key)
            switch settingKey {
            case SettingKeyEnum.ChatGroup?:
                self.marketArray.accept([MarketTestSectionModel.init(title: "", items: MarketTestHandler.shared.chatGroupArray.value)])
            case SettingKeyEnum.FinanceNews?:
                self.marketArray.accept([MarketTestSectionModel.init(title: "", items:MarketTestHandler.shared.finNewsArray.value)])
            case SettingKeyEnum.DApp?:
                self.marketArray.accept([MarketTestSectionModel.init(title: "", items:MarketTestHandler.shared.dappArray.value)])
            case SettingKeyEnum.Explorer?:
                self.marketArray.accept([MarketTestSectionModel.init(title: "", items:MarketTestHandler.shared.explorerArray.value)])
            case SettingKeyEnum.MarketMsg?:
                self.marketArray.accept([MarketTestSectionModel.init(title: "", items:MarketTestHandler.shared.marketMsgArray.value)])
            default:
                print("asdf")
            }
        }
    }
    var bag: DisposeBag = DisposeBag.init()
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, tv, idxPath, model) -> UICollectionViewCell in
            fatalError()
        })
        return source
    }()
}
