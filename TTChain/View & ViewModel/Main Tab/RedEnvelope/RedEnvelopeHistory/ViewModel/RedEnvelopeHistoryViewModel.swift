//
//  RedEnvelopeHistoryViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/3/4.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class RedEnvelopeHistoryViewModel: ViewModel {

typealias CellModel = RedEnvelopeHistoryTableViewCellModel

    enum SortType: Int {
        case timeDescending = 0, timeAscending, letterDescending, letterAscending, amountDescending, amountAscending
    }

    struct Input {
        let refreshSubject = PublishSubject<Void>()
        let sendTapSubject = PublishSubject<Void>()
        let receiveTapSubject = PublishSubject<Void>()
        let selectedItemSubject = PublishSubject<IndexPath>()
        let sortTypeSubject = PublishSubject<SortType>()
    }

    struct Output {
        let isReceivedRelay = BehaviorRelay<Bool>(value: true)
        let cellModelsRelay = BehaviorRelay<[CellModel]>(value: [CellModel]())
        let endRefreshSubject = PublishSubject<Void>()
        let receiveButtonColorSubject = BehaviorSubject<UIColor>(value: UIColor.black)
        let sendButtonColorSubject = BehaviorSubject<UIColor>(value: UIColor.owWarmGrey)
        let identifierSubject = PublishSubject<String>()
        let sortTypeRelay = BehaviorRelay<SortType>(value: .timeDescending)
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init() {
        input = Input()
        output = Output()
        input.refreshSubject.subscribe(onNext: { [unowned self] in
            if self.output.isReceivedRelay.value {
                self.getReceiveHistory()
            } else {
                self.getSendHistory()
            }
        }, onError: nil,
           onCompleted: nil,
           onDisposed: nil).disposed(by: disposeBag)
        input.sendTapSubject.map { false }.bind(to: output.isReceivedRelay).disposed(by: disposeBag)
        input.receiveTapSubject.map { true }.bind(to: output.isReceivedRelay).disposed(by: disposeBag)
        output.isReceivedRelay.map { $0 ? UIColor.black : UIColor.owWarmGrey }.bind(to: output.receiveButtonColorSubject)
            .disposed(by: disposeBag)
        output.isReceivedRelay.map { $0 ? UIColor.owWarmGrey : UIColor.black }.bind(to: output.sendButtonColorSubject)
            .disposed(by: disposeBag)
        input.selectedItemSubject.map { [unowned self] indexPath -> String in
            return self.output.cellModelsRelay.value[indexPath.row].input.identifier
        }.bind(to: output.identifierSubject).disposed(by: disposeBag)
        output.isReceivedRelay.subscribe(onNext: { [unowned self] isReceived in
            if isReceived {
                self.getReceiveHistory()
            } else {
                self.getSendHistory()
            }
        }, onError: nil,
           onCompleted: nil,
           onDisposed: nil).disposed(by: disposeBag)
        input.sortTypeSubject.bind(to: output.sortTypeRelay).disposed(by: disposeBag)
        setUpSort()
    }

    private func setUpSort() {
        output.sortTypeRelay.map { [unowned self] _ in
            return self.sorted(self.output.cellModelsRelay.value)
            }.bind(to: output.cellModelsRelay).disposed(by: disposeBag)
    }

    private func sorted(_ cellModels: [CellModel]) -> [CellModel] {
        switch output.sortTypeRelay.value {
        case .amountAscending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.input.amount.decimalValue < rhs.input.amount.decimalValue
            })
        case .amountDescending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.input.amount.decimalValue > rhs.input.amount.decimalValue
            })
        case .letterAscending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.output.coinDisplayName > rhs.output.coinDisplayName
            })
        case .letterDescending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.output.coinDisplayName < rhs.output.coinDisplayName
            })
        case .timeAscending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.input.time < rhs.input.time
            })
        case .timeDescending:
            return cellModels.sorted(by: { lhs, rhs -> Bool in
                return lhs.input.time > rhs.input.time
            })
        }
    }

    private func getReceiveHistory() {
        let parameter : ReceiveRedEnvelopeHistoryAPI.Parameters =  ReceiveRedEnvelopeHistoryAPI.Parameters.init()
        Server.instance.receiveRedEnvelopeHistory(parameter: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(let model):                self.output.cellModelsRelay.accept(self.sorted(model.receiveHistoryArray.map(RedEnvelopeHistoryTableViewCellModel.init)))
            case .failed(error:_) :
                print("e")
            }
        }).disposed(by: disposeBag)
    }

    private func getSendHistory() {
        
        let parameter : SendRedEnvelopeHistoryAPI.Parameters =  SendRedEnvelopeHistoryAPI.Parameters.init()
        Server.instance.sendRedEnvelopeHistory(parameter: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(let model):
                print("s")
                self.output.cellModelsRelay.accept(self.sorted(model.sendHistoryArray.map(RedEnvelopeHistoryTableViewCellModel.init)))

            case .failed(error:_) :
                print("e")
            }
        }).disposed(by: disposeBag)
    }
}
