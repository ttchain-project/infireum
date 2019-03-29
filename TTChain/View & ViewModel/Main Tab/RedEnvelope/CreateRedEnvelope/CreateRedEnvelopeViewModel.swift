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
        let walletRelay = BehaviorRelay<Wallet?>(value: nil)
        let walletCoinRelay = BehaviorRelay<Coin?>(value: nil)
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
        let walletCoinTitleSubject = BehaviorSubject<String?>(value: LM.dls.red_env_send_please_select)
        let balanceSubject = BehaviorSubject<String?>(value: nil)
        let feeSubject = BehaviorSubject<String?>(value: nil)
        let membersCountSubject = BehaviorSubject<NSAttributedString?>(value: nil)
        let messageSubject = PublishSubject<String>()
        let dismissSubject = PublishSubject<Void>()
        let isTypeButtonHiddenSubject = BehaviorSubject<Bool>(value: false)
        let typeAttributeTitleSubject = BehaviorSubject<NSAttributedString?>(value: nil)
        let countSubject = BehaviorSubject<String>(value: "0 / 30")
        let countColorSubject = BehaviorSubject<UIColor>(value: UIColor.gray)
        let isCountViewHiddenSubject = BehaviorSubject<Bool>(value: false)
        let expiredMinutesRelay = BehaviorRelay<Int>(value: 0)
        let expiredSubject = BehaviorSubject<String>(value: LM.dls.red_env_send_infinite)
        let isSendButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()

    var wallets = [Wallet]()
    
    lazy var coins : BehaviorRelay<[Coin]?> = {
        let coins = Coin.getAllCoins(of: ChainType(rawValue: wallets[0].chainType)!)
        return BehaviorRelay.init(value: coins)
    }()
    
    init(type: CreateType, roomIdentifier: String, memberCount: Int) {
        input = Input()
        output = Output()
        output.isTypeButtonHiddenSubject.onNext(type == .normal)
        output.isCountViewHiddenSubject.onNext(type == .normal)
        input.typeRelay.accept(type == .normal ? nil : .group)
        self.wallets = DB.instance.get(type: Wallet.self, predicate: nil, sorts: nil) ?? []
        self.input.walletRelay.accept(wallets.count > 0 ? wallets[0] : nil)
        setUpMemberCount(memberCount)
        setUpMessage()
        setUpMinutes()
        setUpWalletCoin()
        input.closeTapSubject.bind(to: output.dismissSubject).disposed(by: disposeBag)
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
        
        self.input.walletRelay.asObservable().filter { $0 != nil }.map { wallet in
            return Coin.getAllCoins(of: ChainType(rawValue: wallet!.chainType)!)
            }.bind(to: self.coins).disposed(by: disposeBag)
    }
    
    private func setUpFee() {
        input.walletCoinRelay.subscribe(onNext: { [unowned self] assetCoin in
            let fee =  { () -> Decimal? in
                switch assetCoin?.owChainType {
                case .btc?:
                    return FeeManager.getValue(fromOption: .btc(.regular))
                case .eth?:
                    
                    if assetCoin?.identifier == Coin.eth_identifier {
                        return FeeManager.getValue(fromOption: .eth(.gasPrice(.suggest)))
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
            if let coin = asset,
                let name = coin.inAppName {
                return "\(name)"
            } else {
                return LM.dls.red_env_send_please_select
            }
            }.bind(to: output.walletCoinTitleSubject).disposed(by: disposeBag)
        
        input.walletCoinRelay.map { coin in
            guard let coin = coin,let wallet = self.input.walletRelay.value, let asset = wallet.getAsset(of: coin) else {
                return ""
            }
            return LM.dls.withdrawal_label_assetAmt(asset.amount!.decimalValue.asString(digits:8),"")
            }.bind(to: output.balanceSubject).disposed(by: disposeBag)
    }

    private func setUpMinutes() {
        Observable.combineLatest(input.expiredDaySubject, input.expiredHourSubject, input.expiredMinuteSubject)
            .map { day, hour, minute -> Int in
                return day * 60 * 24 + hour * 60 + minute
            }.bind(to: output.expiredMinutesRelay).disposed(by: disposeBag)
        Observable.combineLatest(input.expiredDaySubject, input.expiredHourSubject, input.expiredMinuteSubject)
            .map { day, hour, minute -> String in
                if day == 0, hour == 0, minute == 0 {
                    return LM.dls.red_env_send_infinite
                } else {
                    return "\(day) \(LM.dls.red_env_send_day) \(hour) \(LM.dls.red_env_send_hour) \(minute) \(LM.dls.red_env_send_minute)"
                }
            }.bind(to: output.expiredSubject).disposed(by: disposeBag)
    }

    private func setUpMessage() {
        input.messageRelay.map { "\($0?.count ?? 0) / 30" }.bind(to: output.countSubject)
            .disposed(by: disposeBag)
        input.messageRelay.map { ($0?.count ?? 0) > 30 ? UIColor.red : UIColor.gray }
            .bind(to: output.countColorSubject).disposed(by: disposeBag)
    }

    private func setUpMemberCount(_ count:Int) {
        let numberOfMembersString = LM.dls.red_env_send_number_title
        let memberCountString = LM.dls.red_env_send_number_of_members("\(count)")
        let finalString = numberOfMembersString + " " + memberCountString
        let substringRange = finalString.range(of: memberCountString)
        let range = NSRange(substringRange!,in:finalString)
        let attribute = NSMutableAttributedString.init(string: finalString)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray , range: range)
        output.membersCountSubject.onNext(attribute)
    }

    private func create(roomIdentifier: String) {
        self.output.isSendButtonEnabledSubject.onNext(false)
        guard let address = input.walletRelay.value?.address,
            let identifier = input.walletCoinRelay.value?.identifier,
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
            self?.output.isSendButtonEnabledSubject.onNext(true)
            guard self != nil else {
                return
            }
            switch response {
            case .success(let model):
                if model.status {
                    self?.output.dismissSubject.onNext(())
                }
            case .failed(let error):
                self?.output.messageSubject.onNext(error.descString)
                self?.output.dismissSubject.onNext(())
            }
        }).disposed(by: disposeBag)
        
    }
}
