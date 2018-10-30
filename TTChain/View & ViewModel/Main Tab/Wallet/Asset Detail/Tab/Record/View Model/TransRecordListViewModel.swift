//
//  TransRecordListViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/6.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransRecordListViewModel: KLRxViewModel {
    struct Input {
        let records: [TransRecord]
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    
    var input: TransRecordListViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var transRecords: Observable<[TransRecord]> {
        return _transRecords.asObservable()
    }
    
    public func updateRecords(_ records: [TransRecord]) {
        self.fetchRemarksForRecords(records).asObservable().subscribe(onNext: { [weak self] records in
            self?._transRecords.accept(records)
        }).disposed(by: bag)
    }
    
    private func fetchRemarksForRecords(_ records: [TransRecord]) -> Single<[TransRecord]>{
        let transRecordsIDs = records.map {$0.txID}
        let req = Server.instance.fetchTransactionRemarks(for: transRecordsIDs)
        return req.map {
            result -> [TransRecord] in
            switch result {
            case .failed(error: _): return records
            case .success(let model):
                print(model)
                return records.map { record -> TransRecord in
                    if let remark = model.comments.first(where : {record.txID == $0.txID}) {
                        record.remarkComment = remark.comment
                    }else {
                        record.remarkComment = ""
                    }
                    return record
                }
            }
        }
    }


    
    //MARK: - Private
    private lazy var _transRecords: BehaviorRelay<[TransRecord]> = {
        return BehaviorRelay.init(value: input.records)
    }()
}
