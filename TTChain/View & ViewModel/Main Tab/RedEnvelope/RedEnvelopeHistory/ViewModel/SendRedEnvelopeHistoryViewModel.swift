//
//  SendRedEnvelopeHistoryViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/26.
//  Copyright © 2019 GIB. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

final class SendRedEnvelopeHistoryViewModel: ViewModel {
    typealias Information = RedEvelopeInfoModel
    typealias CellModel = SendRedEnvelopeTableViewCellModel
    typealias SectionModel = SendRedEnvelopeHistoryViewSectionModel
    typealias DataSource = RxTableViewSectionedReloadDataSource<SendRedEnvelopeHistoryViewSectionModel>

    enum Action {
        case dismiss, send
    }

    struct Input {
        let informationRelay: BehaviorRelay<Information?>
        let identifier: String
        let closeTapSubject = PublishSubject<Void>()
        let enterPasswordSubject = PublishSubject<String>()
        let sendTapSubject = PublishSubject<Void>()
    }

    struct Output {
        let amountSubject = BehaviorSubject<String?>(value: nil)
        let coinDisplayNameSubject = BehaviorSubject<String?>(value: nil)
        let imageSubject = BehaviorSubject<UIImage?>(value: nil)
        let backgroundImageSubject = BehaviorSubject<UIImage>(value: #imageLiteral(resourceName: "bgRecordCardBlue.png"))
        let isDoneLabelHiddenSubject = BehaviorSubject<Bool>(value: true)
        let isWaitingLabelHiddenSubject = BehaviorSubject<Bool>(value: true)
        let actionSubject = PublishSubject<Action>()
        let amountContentSubject = BehaviorSubject<String>(value: "等待塞钱金额")
        let isSendButtonHiddenRelay = BehaviorRelay<Bool>(value: true)
        let createTimeSubject = BehaviorSubject<String?>(value: nil)
        let expiredTimeSubject = BehaviorSubject<String?>(value: nil)
        let addressSubject = BehaviorSubject<String?>(value: nil)
        let descriptionSubject = BehaviorSubject<String?>(value: nil)
        var height: CGFloat { return isSendButtonHiddenRelay.value ? 345 : 405 }
        let cellModelsRelay = BehaviorRelay<[SectionModel]>(value: [SectionModel]())
        let dataSource = DataSource(configureCell: { _, tableView, indexPath, cellModel -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(with: SendRedEnvelopeTableViewCell.self, for: indexPath)
            cell.viewModel = cellModel
            return cell
        }, titleForHeaderInSection: { _, _ -> String? in
            return nil
        }, titleForFooterInSection: { _, _ -> String? in
            return nil
        }, canEditRowAtIndexPath: { _, _ -> Bool in
            return false
        }, canMoveRowAtIndexPath: { _, _ -> Bool in
            return false
        }, sectionIndexTitles: { _ -> [String]? in
            return nil
        }, sectionForSectionIndexTitle: { _, _, _ -> Int in
            return 0
        })
        let hasCloseBarButton: Bool
        let enterPasswordAlertSubject = PublishSubject<String>()
        let continueAlertSubject = PublishSubject<String>()
        let messageSubject = PublishSubject<String>()
    }

    var input: Input
    var output: Output
    let disposeBag = DisposeBag()
    private var needsToEnterPassword = true
    private var lastMemberName: String?

    init(identifier: String, information: Information? = nil, hasCloseBarButton: Bool = true) {
        input = Input(informationRelay: BehaviorRelay<Information?>(value: information), identifier: identifier)
        output = Output(hasCloseBarButton: hasCloseBarButton)
        getRedEnvelope(identifier)
        input.informationRelay.subscribe(onNext: { [unowned self] information in
            guard let information = information else { return }
            self.setUpInformation(information)
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
        input.closeTapSubject.map { Action.dismiss }.bind(to: output.actionSubject).disposed(by: disposeBag)
        input.sendTapSubject.subscribe(onNext: { [unowned self] in
            self.send(identifier: identifier)
        }, onError: nil,
           onCompleted: nil,
           onDisposed: nil).disposed(by: disposeBag)
        input.enterPasswordSubject.subscribe(onNext: { [unowned self] password in
            guard let information = self.input.informationRelay.value else { return }
            
            guard let coin = Coin.getCoin(ofIdentifier: information.info.identifier),let wallet = Wallet.getWallets(ofMainCoinID: coin.walletMainCoinID!).first else {return}
            
            if wallet.isWalletPwd(rawPwd: password) {
                self.needsToEnterPassword = false
                self.input.sendTapSubject.onNext(())
            } else {
                self.output.messageSubject.onNext(LM.dls.withdrawalConfirm_pwdVerify_error_pwd_is_wrong)
            }
            }, onError: nil,
               onCompleted: nil,
               onDisposed: nil).disposed(by: disposeBag)
    }

    private func getRedEnvelope(_ identifier: String) {
        let parameter =  RedEnvelopeInfoAPI.Parameters.init(redEnvelopeId: identifier)
        Server.instance.getRedEnvelopeInfo(parameter: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .failed(error: _):
                DLogError("error")
            case .success(let model):
                self.input.informationRelay.accept(model.redEnvelopeInfo)
            }
        }).disposed(by: disposeBag)
    }

    private func setUpInformation(_ information: Information) {
        let paidAmount = NSNumber(value: information.info.paidAmount).decimalValue
        switch information.info.status {
        case .done:
            output.amountSubject.onNext(NSDecimalNumber(decimal: paidAmount).stringValue)
            output.imageSubject.onNext(#imageLiteral(resourceName: "progressBarSendFinished.png"))
        case .waitSend:
            let decimal = NSNumber(value: information.info.waitPaidAmount).decimalValue
            output.amountSubject.onNext(NSDecimalNumber(decimal: decimal).stringValue)
            output.imageSubject.onNext(#imageLiteral(resourceName: "progressBarSendMoney.png"))
        case .waitReceive:
            output.amountSubject.onNext("0")
            output.imageSubject.onNext(#imageLiteral(resourceName: "progressBarSendPageWait.png"))
        }
        output.amountContentSubject.onNext(information.info.status == .done ? "塞钱金额" : "等待塞钱金额")
        output.coinDisplayNameSubject.onNext(information.info.displayName)
        output.isSendButtonHiddenRelay.accept(information.info.status != .waitSend)
        output.addressSubject.onNext(information.info.senderAddress)
        output.createTimeSubject.onNext(information.info.createTime.convertToDateString)
        output.backgroundImageSubject.onNext(information.info.status == .done ? #imageLiteral(resourceName: "bgRecordCardBlue.png") : #imageLiteral(resourceName: "bgRecordCard.png"))
        output.isDoneLabelHiddenSubject.onNext(information.info.status != .done)
        let type = information.info.type == .lucky ? "拼手氣紅包" : "普通紅包"
        let total = NSDecimalNumber(decimal: NSNumber(value: information.info.totalAmount).decimalValue).stringValue
        let description = type + " \(information.info.receiveCount) 个 总金额 \(total) \(information.info.displayName)"
        output.descriptionSubject.onNext(description)
        let hasExpiredTime = (information.info.expiredTime?.convertToDateString.hasPrefix("9999") ?? true) == false
        let expiredString = "领取时间至 " + (information.info.expiredTime?.convertToDateString ?? String())
        output.expiredTimeSubject.onNext(hasExpiredTime ? expiredString : nil)
        let totalAmount = "已塞钱 \(NSDecimalNumber(decimal: paidAmount).stringValue) \(information.info.displayName)"
        let headerString = "领取明细 \(information.info.receiveCount) / \(information.info.totalCount) \(totalAmount)"
        let items = information.members.map(CellModel.init)
        output.cellModelsRelay.accept([SendRedEnvelopeHistoryViewSectionModel(model: headerString,
                                                                              items: items)])
    }

    private func send(identifier: String) {
        guard let member = input.informationRelay.value!.members.first(where: { $0.isDone == false }) else { return }
        let information = input.informationRelay.value
        guard let coin = Coin.getCoin(ofIdentifier: information!.info.identifier), let wallet = Wallet.getWallet(ofAddress: information!.info.senderAddress, mainCoinID: coin.walletMainCoinID!) ,let asset = wallet.getAsset(of: coin) else {
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
        
        
        switch WithdrawalInfoValidator().validate(asset: asset,
                                                  transferAmt: NSNumber(value: member.receiveAmount).decimalValue,
                                                  toAddress: member.receiveAddress,
                                                  note: nil, feeInfo: feeInfo!) {
        case .success(let info):
            print("is valid")
            
            if self.needsToEnterPassword {
                self.output.enterPasswordAlertSubject.onNext(LM.dls.red_env_transfer_alert_message("\(member.receiveAmount)",coin.inAppName!))
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
                
                if model.redEnvelopeInfo.members.contains(where: { $0.isDone == false }) {
                    self.output.continueAlertSubject.onNext(LM.dls.red_env_money_sent_already_message(member.nickName))
                } else {
                    self.output.messageSubject.onNext(LM.dls.red_env_money_sent_to_user_message(member.nickName))
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

}

struct SendRedEnvelopeHistoryViewSectionModel: SectionModelType {
    typealias Item = SendRedEnvelopeTableViewCellModel

    var items: [Item]
    var model: String

    init(original: SendRedEnvelopeHistoryViewSectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }

    init(model: String, items: [Item]) {
        self.model = model
        self.items = items
    }
}
