//
//  CreateRedEnvelopeViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CreateRedEnvelopeViewModel: ViewModel {
    enum CreateType {
        case normal, group
    }

    struct Input {
        let walletCoinRelay = BehaviorRelay<Asset?>(value: nil)
        let amountRelay = BehaviorRelay<String?>(value: nil)
        let messageRelay = BehaviorRelay<String?>(value: nil)
        let typeRelay = BehaviorRelay<RedEnvelopeType?>(value: nil)
        let typeTapSubject = PublishSubject<Void>()
        let expiredDaySubject = BehaviorSubject<Int>(value: 0)
        let expiredHourSubject = BehaviorSubject<Int>(value: 0)
        let expiredMinuteSubject = BehaviorSubject<Int>(value: 0)
        let closeTapSubject = PublishSubject<Void>()
        let limitCountRelay = BehaviorRelay<Int?>(value: nil)
        let sendTapSubject = PublishSubject<Void>()
    }

    struct Output {
        let walletCoinTitleSubject = BehaviorSubject<String?>(value: "Please select")
        let balanceSubject = BehaviorSubject<String?>(value: nil)
        let feeSubject = BehaviorSubject<String?>(value: nil)
        let membersCountSubject = BehaviorSubject<String?>(value: nil)
        let messageSubject = PublishSubject<String>()
        let dismissSubject = PublishSubject<Void>()
        let isTypeButtonHiddenSubject = BehaviorSubject<Bool>(value: false)
        let typeAttributeTitleSubject = BehaviorSubject<NSAttributedString?>(value: nil)
        let countSubject = BehaviorSubject<String>(value: "0 / 30")
        let countColorSubject = BehaviorSubject<UIColor>(value: UIColor.gray)
        let isCountViewHiddenSubject = BehaviorSubject<Bool>(value: false)
        let expiredMinutesRelay = BehaviorRelay<Int>(value: 0)
        let expiredSubject = BehaviorSubject<String>(value: "Infinite")
        let isSendButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    init(type: CreateType, roomIdentifier: String, memberCount: Int) {
        input = Input()
        output = Output()
        output.isTypeButtonHiddenSubject.onNext(type == .normal)
        output.isCountViewHiddenSubject.onNext(type == .normal)
        input.typeRelay.accept(type == .normal ? nil : .group)
        setUpType()
        setUpMessage()
        setUpMinutes()
        setUpWalletCoin()
        input.closeTapSubject.bind(to: output.dismissSubject).disposed(by: disposeBag)
        output.membersCountSubject.onNext("This group has \(memberCount) members")
        Observable.combineLatest(input.walletCoinRelay, input.amountRelay, input.limitCountRelay, input.messageRelay)
            .map { walletCoin, amount, limitCount, message -> Bool in
                guard walletCoin != nil else { return false }
                guard let amount = amount, Decimal(string: amount) != nil else { return false }
                guard (message?.count ?? 0) <= 30 else { return false }
                switch type {
                case .normal: return true
                case .group: return (limitCount ?? 0) > 0
                }
            }.bind(to: output.isSendButtonEnabledSubject).disposed(by: disposeBag)
        input.sendTapSubject.subscribe(onNext: { [unowned self] in
            self.create(roomIdentifier: roomIdentifier)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
        setUpFee()
    }
    
    private func setUpFee() {
        input.walletCoinRelay.subscribe(onNext: { [unowned self] assetCoin in
            let fee =  { () -> Decimal? in
                switch assetCoin!.wallet!.owChainType {
                case .btc:
                    return FeeManager.getValue(fromOption: .btc(.priority))
                case .eth:
                    
                    if assetCoin!.coinID == Coin.eth_identifier {
                        return FeeManager.getValue(fromOption: .eth(.gasPrice(.systemMax)))
                    } else {
                        return 0
                    }
                default:
                    return 0
                }
            }()
            self.output.feeSubject.onNext(fee?.asString(digits: 8))
            
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
    }
    
    private func setUpWalletCoin() {
        input.walletCoinRelay.map { asset -> String? in
            if let asset = asset,
                let walletName = asset.wallet?.name,
                let name = asset.coin?.inAppName {
                return "\(walletName) \(name)"
            } else {
                return "Please select"
            }
            }.bind(to: output.walletCoinTitleSubject).disposed(by: disposeBag)
        input.walletCoinRelay.map { $0?.amount?.decimalValue.asString(digits: 4) }.bind(to: output.balanceSubject).disposed(by: disposeBag)
    }

    private func setUpMinutes() {
        Observable.combineLatest(input.expiredDaySubject, input.expiredHourSubject, input.expiredMinuteSubject)
            .map { day, hour, minute -> Int in
                return day * 60 * 24 + hour * 60 + minute
            }.bind(to: output.expiredMinutesRelay).disposed(by: disposeBag)
        Observable.combineLatest(input.expiredDaySubject, input.expiredHourSubject, input.expiredMinuteSubject)
            .map { day, hour, minute -> String in
                if day == 0, hour == 0, minute == 0 {
                    return "Infinite"
                } else {
                    return "\(day) 天 \(hour) 小時 \(minute) 分鐘"
                }
            }.bind(to: output.expiredSubject).disposed(by: disposeBag)
    }

    private func setUpMessage() {
        input.messageRelay.map { "\($0?.count ?? 0) / 30" }.bind(to: output.countSubject)
            .disposed(by: disposeBag)
        input.messageRelay.map { ($0?.count ?? 0) > 30 ? UIColor.red : UIColor.gray }
            .bind(to: output.countColorSubject).disposed(by: disposeBag)
    }

    private func setUpType() {
        input.typeTapSubject.subscribe(onNext: { [unowned self] in
            self.input.typeRelay.accept(self.input.typeRelay.value == .group ? .lucky : .group)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
        input.typeRelay.map { [unowned self] type -> NSAttributedString? in
            if let type = type {
                return self.attributeString(type: type)
            } else {
                return nil
            }
            }.bind(to: output.typeAttributeTitleSubject).disposed(by: disposeBag)
    }

    private func attributeString(type: RedEnvelopeType) -> NSMutableAttributedString? {
        var attributedString: NSMutableAttributedString
//        switch type {
//        case .lucky:
//            attributedString = NSMutableAttributedString(string: "目前为普通红包，改为拼手气红包", attributes: [
//                .font: UIFont.systemFont(ofSize: 9),
//                .foregroundColor: UIColor.brown])
//            attributedString.addAttribute(.foregroundColor,
//                                          value: UIColor.azure,
//                                          range: NSRange(location: 10, length: 5))
//        case .group:
//            attributedString = NSMutableAttributedString(string: "目前为拼手气红包，改为普通红包", attributes: [
//                .font: UIFont.systemFont(ofSize: 9),
//                .foregroundColor: UIColor.brownGrey])
//            attributedString.addAttribute(.foregroundColor,
//                                          value: UIColor.azure,
//                                          range: NSRange(location: 11, length: 4))
//        case .normal: return nil
//        }
        return attributedString
    }

    private func create(roomIdentifier: String) {
        guard let address = input.walletCoinRelay.value?.wallet?.address,
            let identifier = input.walletCoinRelay.value?.coinID,
            let amount = Decimal(string: input.amountRelay.value ?? String()) else { return }
        let minutes = output.expiredMinutesRelay.value
        let parameters = CreateRedEnvelopeAPI.Parameters(senderAddress: address,
                                                                            identifier: identifier,
                                                                            amount: amount,
                                                                            message: input.messageRelay.value,
                                                                            roomId: roomIdentifier,
                                                                            expireMinute: minutes,
                                                                            limitCount: input.limitCountRelay.value,
                                                                            type: input.typeRelay.value)
        
        Server.instance.createRedEnvelope(parameter:parameters).asObservable().subscribe(onNext: { [weak self] response in
            guard self != nil else {
                return
            }
            switch response {
            case .success(let model):
                if model.status {
                    self?.output.dismissSubject.onNext(())
                }
            case .failed(let error):
                self?.output.messageSubject.onNext(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
        
    }
}
