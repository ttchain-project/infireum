//
//  OWRxNotificationCenter.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWRxNotificationCenter {
    static let instance: OWRxNotificationCenter = OWRxNotificationCenter.init()
    
    //MARK: - Wallet Name Update
    private let _walletNameUpdate: PublishRelay<Wallet> = PublishRelay.init()
    public var walletNameUpdate: Observable<Wallet> {
        return _walletNameUpdate.asObservable()
    }
    public func notifyWalletNameUpdate(of wallet: Wallet) {
        _walletNameUpdate.accept(wallet)
    }
    
    //MARK: - Wallet Imported
    private let _walletImported: PublishRelay<Wallet> = PublishRelay.init()
    public var walletImported: Observable<Wallet> {
        return _walletImported.asObservable()
    }
    
    public func notifyWalletImported(of wallet: Wallet) {
        _walletImported.accept(wallet)
    }
    
    //MARK: - Unspecified Wallets Imported
    private let _walletsImported: PublishRelay<Void> = PublishRelay.init()
    public var walletsImported: Observable<Void> {
        return _walletsImported.asObservable()
    }
    
    public func notifyWalletsImported() {
        _walletsImported.accept(())
    }
    
    //MARK: - Wallet Delete
    private let _walletDeleted: PublishRelay<Wallet> = PublishRelay.init()
    public var walletDeleted: Observable<Wallet> {
        return _walletDeleted.asObservable()
    }
    
    public func notifyWalletDeleted(of wallet: Wallet) {
        _walletDeleted.accept(wallet)
    }
    
    
    //MARK: - Identity Clear
    private let _identityCleared: PublishRelay<Void> = PublishRelay.init()
    public var identityCleared: Observable<Void> {
        return _identityCleared.asObservable()
    }
    
    public func notifyIdentityCleared() {
        _identityCleared.accept(())
    }
    
    //MARK: - Pref Fiat Update
    private let _prefFiatUpdate: PublishRelay<Fiat> = PublishRelay.init()
    public var prefFiatUpdate: Observable<Fiat> {
        return _prefFiatUpdate.asObservable()
    }
    
    public func notifyPrefFiatUpdate(fiat: Fiat) {
        _prefFiatUpdate.accept(fiat)
    }
    
    //MARK: - AddressBook Alter (Delete/Insert/Update)
    //        for some subscriber to reload data from DB again
    private let _addressBookUpdate: PublishRelay<Void> = PublishRelay.init()
    public var addressBookUpdate: Observable<Void> {
        return _addressBookUpdate.asObservable()
    }
    
    public func notifyAddressBookUpdate() {
        _addressBookUpdate.accept(())
    }
    
    //MARK: - Lightning Trade Switch
    private var _onLightningTradeSwitchWithCoin: PublishRelay<Coin> = PublishRelay.init()
    
    public var onLightningTradeSwitchWithCoin: Observable<Coin> {
        return _onLightningTradeSwitchWithCoin.asObservable()
    }
    
    public func switchToLightningModeWithCoin(_ coin: Coin) {
        _onLightningTradeSwitchWithCoin.accept(coin)
    }
    
    //MARK: - TransRecord Update
    public var onTransferRecordCreate: Observable<TransRecord> {
        return _onTransferRecordCreate.asObservable()
    }
    
    private lazy var _onTransferRecordCreate: PublishRelay<TransRecord> = {
        return PublishRelay.init()
    }()
    
    public func transferRecordCreated(_ record: TransRecord) {
        _onTransferRecordCreate.accept(record)
    }
    
    //MARK: - LightningTransRecord Update
    public var onLightningTransferRecordCreate: Observable<LightningTransRecord> {
        return _onLightningTransferRecordCreate.asObservable()
    }
    
    private lazy var _onLightningTransferRecordCreate: PublishRelay<LightningTransRecord> = {
        return PublishRelay.init()
    }()
    
    public func lightningTransferRecordCreated(_ record: LightningTransRecord) {
        _onLightningTransferRecordCreate.accept(record)
    }
    
    //MARK: - Identity Update
    public var onUpdateIdentity: Observable<Identity> {
        return _onUpdateIdentity.asObservable()
    }
    
    private lazy var _onUpdateIdentity: PublishRelay<Identity> = {
        return PublishRelay.init()
    }()
    
    public func updateIdentity(_ identity: Identity) {
        _onUpdateIdentity.accept(identity)
    }
    
    //MARK: - Settings Manager (idAuth)
    public var onChangeIDAuthEnable: Observable<Bool> {
        return _onChangeIDAuthEnable.asObservable()
    }
    
    private lazy var _onChangeIDAuthEnable: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: SettingsManager.isIDAuthEnabled)
    }()
    
    public func changeIDAuthEnable(_ isEnabled: Bool) {
        _onChangeIDAuthEnable.accept(isEnabled)
    }
    
    //MARK: - Settings Manager (private model)
    public var onChangePrivateMode: Observable<Bool> {
        return _onChangePrivateMode.asObservable()
    }
    
    private lazy var _onChangePrivateMode: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: SettingsManager.isPrivateModeEnabled)
    }()
    
    public func changePrivateMode(_ isEnabled: Bool) {
        _onChangePrivateMode.accept(isEnabled)
    }
    
    
    //MARK: - Coin Selection Insert/Delete Notifier
    public var willDeleteCoinSelection: Observable<CoinSelection> {
        return _willDeleteCoinSelection.asObservable()
    }
    
    private lazy var _willDeleteCoinSelection: PublishRelay<CoinSelection> = {
        return PublishRelay.init()
    }()
    
    public func willDeleteCoinSelection(_ selection: CoinSelection) {
        _willDeleteCoinSelection.accept(selection)
    }
    
    public var didInsertCoinSelection: Observable<CoinSelection> {
        return _didInsertCoinSelection.asObservable()
    }
    
    private lazy var _didInsertCoinSelection: PublishRelay<CoinSelection> = {
        return PublishRelay.init()
    }()
    
    public func didInsertCoinSelection(_ selection: CoinSelection) {
        _didInsertCoinSelection.accept(selection)
    }
    
    //MARK: - Remote Main Coin Sync
    public var onSyncedRemoteMainCoinIDs: Observable<Void> {
        return _onSyncedRemoteMainCoinIDs.asObservable()
    }
    
    private lazy var _onSyncedRemoteMainCoinIDs: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    public func didSyncRemoteMainCoinIDs() {
        _onSyncedRemoteMainCoinIDs.accept(())
    }
    
    //MARK: - Finish Launch Sync
    public var onFinishLaunchSync: Observable<Void> {
        return _onFinishLaunchSync.asObservable()
    }
    
    private lazy var _onFinishLaunchSync: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    public func didFinishLaunchSync() {
        _onFinishLaunchSync.accept(())
    }
    
//    //MARK: - OnMessage Forward
//    public var onMessageForward: Observable<MessageModel> {
//
//    }
//
//    private lazy var _onMessageForward: PublishRelay<(MessageModel,ChatListPage)> = {
//        return PublishRelay.init()
//    }()
//
//    public func didForwardMessage(message:MessageModel, toChat:ChatListPage) {
//        _didInsertCoinSelection.accept(selection)
//    }
    
}
