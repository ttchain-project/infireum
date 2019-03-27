//
//  RedEnvelopeDetailViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class RedEnvelopeDetailViewModel: ViewModel {
    
    typealias Information = RedEvelopeInfoModel
    typealias CellModel = ReceiveRedEnvelopeTableViewCellModel

    
    enum Action {
        case dismiss, history
    }

    static let height: CGFloat = 440

    struct Input {
        let informationRelay: BehaviorRelay<Information>
        let sendTapSubject = PublishSubject<Void>()
        let closeTapSubject = PublishSubject<Void>()
        let historyTapSubject = PublishSubject<Void>()
        let enterPasswordSubject = PublishSubject<String>()
    }

    struct Output {
        let imageString: String?
        let title: String?
        let message: String
        let isReceiveButtonHiddenSubject = BehaviorSubject<Bool>(value: false)
        let contentSubject = BehaviorSubject<String?>(value: nil)
        let expiredString: String?
        let isLuckyHidden: Bool
        let messageSubject = PublishSubject<String>()
        let statusSubject = BehaviorSubject<String?>(value: nil)
        let actionSubject = PublishSubject<Action>()
        let amount: String
        let coinDisplayName: String?
        let isSendButtonHiddenSubject = BehaviorSubject<Bool>(value: true)
        let cellModelsSubject = BehaviorSubject<[CellModel]>(value: [CellModel]())
        let enterPasswordAlertSubject = PublishSubject<String>()
        let continueAlertSubject = PublishSubject<String>()
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()
    private var needsToEnterPassword = true
    private var lastMemberName: String?

    init(identifier: String, information: Information) {
        input = Input(informationRelay: BehaviorRelay<Information>(value: information))
        let isSender = information.info.uid == Tokens.getUID()
        let sender = isSender ? "我发送" : information.info.senderName
        let title = sender + "的红包"
        let displayName = Coin.getCoin(ofIdentifier: information.info.identifier)?.inAppName
        output = Output(imageString: information.info.headImg.medium,
                        title: title,
                        message: information.info.message,
                        expiredString: information.info.isExpired ? "可领取时间到期了" : nil,
                        isLuckyHidden: information.info.type != .lucky,
                        amount: NSNumber(value: information.info.totalAmount).decimalValue.description,
                        coinDisplayName: displayName)
        input.closeTapSubject.map { Action.dismiss }.bind(to: output.actionSubject).disposed(by: disposeBag)
        input.historyTapSubject.map { Action.history }.bind(to: output.actionSubject).disposed(by: disposeBag)
        input.sendTapSubject.subscribe(onNext: { [unowned self] in
            self.send(identifier: identifier)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
        setUpInformation()
        input.enterPasswordSubject.subscribe(onNext: { [unowned self] password in
            guard let coin = Coin.getCoin(ofIdentifier: information.info.identifier),
            let wallet = Wallet.getWallet(ofAddress: information.info.senderAddress, mainCoinID: coin.walletMainCoinID!) else {
                
                return
            }
            if wallet.isWalletPwd(rawPwd: password) {
                self.needsToEnterPassword = false
                self.input.sendTapSubject.onNext(())
            } else {
                self.output.messageSubject.onNext("wrongPassword".localized())
            }
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
    }

    private func setUpInformation() {
        input.informationRelay.map { "\($0.info.receiveCount) / \($0.info.totalCount) 已領取" }
            .bind(to: output.contentSubject).disposed(by: disposeBag)
        input.informationRelay.map { RedEnvelopeDetailViewModel.status(information: $0) }
            .bind(to: output.statusSubject).disposed(by: disposeBag)
        input.informationRelay.map { information -> [CellModel] in
            let displayName = Coin.getCoin(ofIdentifier: information.info.identifier)?.inAppName
            return information.members.map { member in
                CellModel(member: member, displayName: displayName)
            }
            }.bind(to: output.cellModelsSubject).disposed(by: disposeBag)
        input.informationRelay.map { RedEnvelopeDetailViewModel.isSendButtonHidden(information: $0) }
            .bind(to: output.isSendButtonHiddenSubject).disposed(by: disposeBag)
    }

    private func send(identifier: String) {
        guard let member = input.informationRelay.value.members.first(where: { $0.isDone == false }) else { return }
        var displayString: String = ""
        let information = input.informationRelay.value
        guard let coin = Coin.getCoin(ofIdentifier: information.info.identifier), let wallet = Wallet.getWallet(ofAddress: information.info.senderAddress, mainCoinID: coin.walletMainCoinID!) ,let asset = wallet.getAsset(of: coin) else {
            return
        }
        var feeInfo:WithdrawalFeeInfoProvider.FeeInfo?
        switch coin.owChainType {
        case .btc:
            print("BTC")
            feeInfo = (rate: 1, amt: 0, coin: coin, option: FeeManager.Option.btc(.regular), totalHardCodedFee:Decimal.init(3000).satoshiToBTC)
        case .eth:
            print("ETH")
            let g = FeeManager.getValue(fromOption: .eth(.gas))
            let gp = FeeManager.getValue(fromOption: .eth(.gasPrice(.suggest)))
            let option = FeeManager.Option.eth(.gasPrice(.suggest))
            feeInfo = (rate: gp.gweiToEther, amt: g, coin: Coin.eth, option: option,totalHardCodedFee:nil)
        default:
            print("None")
        }
        
        displayString = "(另外收取单笔矿工费\(member.receiveAmount) \(coin.inAppName!))"

        switch WithdrawalInfoValidator().validate(asset: asset,
                                                  transferAmt: NSNumber(value: member.receiveAmount).decimalValue,
                                                  toAddress: member.receiveAddress,
                                                  note: nil, feeInfo: feeInfo!) {
        case .success(let info):
            print("is valid")
            
                        if self.needsToEnterPassword {
                            self.output.enterPasswordAlertSubject.onNext("您将塞钱入红包，请输入钱包密码" + displayString)
                        } else {
                            self.transferAmount(forIdentifier:identifier, withWithdrawalInfo: info, andMember: member)
                        }

        case .failed(let error):
            output.messageSubject.onNext(error.localizedFailedDesciption)
        }
    }
    
    private func transferAmount(forIdentifier identifier:String,withWithdrawalInfo info:WithdrawalInfo, andMember member: Information.Member) {
        let chainType = info.wallet.owChainType
        Observable<BlockchainTransferFlowState>.create({  (observer) -> Disposable in
            observer.onNext(.signing)
            switch chainType {
            case .btc:
                TransferManager.manager.startBTCTransferFlow(with: info, progressObserver: observer, isCompressed: true)
            case .eth:
                TransferManager.manager.startETHTransferFlow(with: info, progressObserver: observer)
            default: break
            }
            return Disposables.create()
        }).subscribe(onNext: { (state) in
            switch state {
            case .finished(let result):
                switch result {
                case .failed(error: let err):
                    self.output.messageSubject.onNext(err.descString)
                case .success(let record):
                    OWRxNotificationCenter.instance.transferRecordCreated(record)
                    self.markTransactionAsSent(identifier: identifier, forMember: member)
                }
            default:
                DLogInfo(state)
            }
        }).disposed(by: disposeBag)
    }
    
    func markTransactionAsSent(identifier:String,forMember member:Information.Member){
        let parameter = PromiseRedEnvelopeSentAPI.Parameters.init(redEnvelopeId: identifier, members: [member.uid])
        Server.instance.promiseRedEvelopeSent(parameter: parameter).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .success(let model):
                if model.status {
                    self.sendCompleted(identifier: identifier, member: member)
                }
            case .failed(error: let error):
                self.output.messageSubject.onNext(error.descString)
            }
        }).disposed(by: disposeBag)
    }

    private func sendCompleted(identifier: String, member: Information.Member) {
        lastMemberName = member.nickName
        
        let parameter = RedEnvelopeInfoAPI.Parameters.init(redEnvelopeId: identifier)
        Server.instance.getRedEnvelopeInfo(parameter: parameter).asObservable().subscribe(onNext: { (response) in
            switch response {
            case .failed(error: let error):
                self.output.messageSubject.onNext(error.descString)
            case .success(let model):
                self.input.informationRelay.accept(model.redEnvelopeInfo)
                let text = "塞钱给 \(member.nickName) 已完成，是否继续塞钱？"
                if model.redEnvelopeInfo.members.contains(where: { $0.isDone == false }) {
                    self.output.continueAlertSubject.onNext(text)
                } else {
                    self.output.messageSubject.onNext("塞钱给 \(member.nickName) 已完成")
                }
            }
        }).disposed(by: disposeBag)
    }

    private func parse(error: Error) {
//        if let error = error as? NetworkError {
//            switch error {
//            case let .errorWithMessage(message):
//                output.messageSubject.onNext(message)
//                return
//            default: break
//            }
//        }
        output.messageSubject.onNext(error.localizedDescription)
    }

    private static func status(information: Information) -> String? {
        if information.info.uid == Tokens.getUID() {
            switch information.info.status {
            case .done: return "塞钱完成"
            case .waitReceive: return "等待領取紅包"
            case .waitSend: return nil
            }
        } else {
            if let member = information.members.first(where: { $0.uid == Tokens.getUID() }) {
                return member.isDone ? "恭喜，红包钱入帐了" : "等待 \(information.info.senderName) 塞钱进红包"
            } else {
                return nil
            }
        }
    }

    private static func isSendButtonHidden(information: Information) -> Bool {
        if information.info.uid == Tokens.getUID() {
            return information.info.status != .waitSend
        } else {
            return true
        }
    }
    
   
}
