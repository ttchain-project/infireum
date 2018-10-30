//
//  TransferRecordStatusOptionViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferRecordStatusOptionViewModel: KLRxViewModel, TransferRecordsOptionsSingleCancellableSelectBase, RxTransReocrdStatusOptionsProvider {
    
    struct Input {
        let selectInput: Driver<Int>
    }
    
    typealias Source = TransRecordListsStatusOptions
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransferRecordStatusOptionViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    var sourceManager: SingleCancellableSelectRxDataSourceManager<TransRecordListsStatusOptions>
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.sourceManager = SingleCancellableSelectRxDataSourceManager.init(defaultSources: [.deposit, .withdrawal, .failed])
        
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        input.selectInput.drive(onNext: {
            [unowned self]
            idx in
            self.sourceManager.select(sourceIdx: idx)
        })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var statuses: Observable<[TransRecordListsStatusOptions]> {
        return sourceManager.sources
    }
    
    public var selectedStatus: Observable<TransRecordListsStatusOptions?> {
        return sourceManager.selectedSource
    }
    
    public func getStatus(ofIdx idx: Int) -> TransRecordListsStatusOptions {
        return sourceManager.getSources()[idx]
    }
    
    public func isStatusSelected(_ status: TransRecordListsStatusOptions) -> Bool{
        return sourceManager.isSelected(source: status)
    }
}

