//
//  SystemMainWalletSyncHandler.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class SystemMainWalletSyncHandler: Rx {
    var bag: DisposeBag = DisposeBag.init()
    struct Config {
        let presentingVC: UIViewController
    }
    
    public var onFinish: Observable<Void> {
        return _onFinish.asObservable()
    }
    
    private var _onFinish: PublishRelay<Void> = PublishRelay.init()
    
    private(set) weak var presentingVC: UIViewController?
    private(set) weak var pwdTextField: UIViewController?
    
    /// identityPwdHint would be auto-set during the validation flow
    private(set) lazy var identityPwdHint: String = {
        return Identity.singleton!.pwdHint!
    }()
    
    
    private(set) var encryptedMnemonic: String!
    
    init(config: Config) {
        presentingVC = config.presentingVC
    }
    
    func startSyncMainWalletIfNeeded() {
        let syncNeededMainCoins = getSyncNeededMainCoinIDs()
        guard !syncNeededMainCoins.isEmpty else {
            _onFinish.accept(())
            return
        }
        
        presentPwdAlert(withSyncNeededCoinIDs: syncNeededMainCoins)
    }
    
    private func presentPwdAlert(withSyncNeededCoinIDs syncNeededCoinIDs: [String]) {
        let dls = LM.dls
        let alert = UIAlertController.init(
            title: dls.tab_alert_newSystemWallet_title,
            message: dls.tab_alert_newSystemWallet_content,
            preferredStyle: .alert
        )
        
        let confirm = UIAlertAction.init(
            title: LM.dls.g_confirm,
            style: .default) {
                [unowned self]
                (action) in
                guard let tf = alert.textFields?.first else { return }
                guard let pwd = tf.text else { return }
                
                self.attempSync(withPwd: pwd, syncNeededCoinIDs: syncNeededCoinIDs)
            }
        
        let cancel = UIAlertAction.init(
            title: LM.dls.g_cancel,
            style: .cancel,
            handler: {
                [unowned self]
                _ in
                self._onFinish.accept(())
            }
        )
        
        alert.addTextField { [unowned self] (tf) in
            tf.placeholder = LM.dls.tab_alert_placeholder_identityPwd
            tf.rx.text
                .map { $0?.count }
                .replaceNilWith(0)
                .map { $0 > 0 }
                .bind(to: confirm.rx.isEnabled)
                .disposed(by: self.bag)
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        presentingVC?.present(alert, animated: true, completion: nil)
    }
    
    private func getSyncNeededMainCoinIDs() -> [String] {
        let mainCoinIDs = MainCoinTypStorage.supportMainCoinIDs
        let systemWallets = DB.instance.get(type: Wallet.self, predicate: nil, sorts: nil)!.filter { $0.isFromSystem }
        
        //All the system wallet should from the same mnemonic
        if let firstSysWallet = systemWallets.first {
            encryptedMnemonic = firstSysWallet.eMnemonic!
        }
        
        let syncNeededMainCoinIDs = mainCoinIDs.filter { (mainCoinID) -> Bool in
            let hasSystemMainWallet = systemWallets.contains { $0.walletMainCoinID == mainCoinID }
            
            return !hasSystemMainWallet
        }

        return syncNeededMainCoinIDs
    }
    
    private func attempSync(
        withPwd pwd: String,
        syncNeededCoinIDs: [String]
        ) {
        
        validatePwd(pwd)
            .flatMap {
                [unowned self]
                mnemonic -> RxAPIVoidResponse in
                guard let mne = mnemonic else {
                    let msg = LM.dls.tab_alert_error_mnemonic_decrypt_failed
                    
                    let mneDecryptFailedError =
                        GTServerAPIError.incorrectResult(msg, msg)
                    
                    return RxAPIVoidResponse.just(.failed(error: mneDecryptFailedError))
                }

                self.presentingVC?.animateIndicatorImmediately()
                return self.syncDefaultWallets(
                    withRawMnemonic: mne,
                    pwd: pwd,
                    syncNeededCoinIDs: syncNeededCoinIDs
                )
            }
            .subscribe(onSuccess: {
                [unowned self]
                result in
                
                self.presentingVC?.hideIndicator()
                switch result {
                case .failed(error: let err):
                    self.presentingVC?.showAPIErrorResponsePopUp(from: err, cancelTitle: LM.dls.g_cancel) {
                       //Encounter error, restart the flow
                        self.presentPwdAlert(withSyncNeededCoinIDs: syncNeededCoinIDs)
//                        self._onFinish.accept(())
                    }
                case .success:
                    self._onFinish.accept(())
                    return
                }
            })
            .disposed(by: bag)
    }
    
    private func validatePwd(_ pwd: String) -> Single<String?> {
        guard
            let eMne = encryptedMnemonic,
            let mne = OWDatabaseEntityCrypter
                .decryptMnemonicWithRawPwd(eMne,
                                           pwd: pwd) else {
            return .just(nil)
        }
        
        return .just(mne)
    }
    
    private func syncDefaultWallets(
        withRawMnemonic mne: String,
        pwd: String,
        syncNeededCoinIDs: [String]
        ) -> RxAPIVoidResponse {
        guard !syncNeededCoinIDs.isEmpty else { return .just(.success(())) }
        return Server.instance.createAccount(defaultMnemonic: mne)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .map {
                [unowned self]
                result in
                switch result {
                case .failed(error: let err): return .failed(error: err)
                case .success(let model):
                    let walletsMap = model.walletsMap
                    let syncNeededWalletResources: [APIWalletCreateResult.WalletResource] =
                        walletsMap.compactMap({ (k, v) in
                            guard let coin = Coin.getCoin(ofIdentifier: k) else {
                                return nil
                            }
                            
                            guard syncNeededCoinIDs.contains(coin.identifier!) else {
                                return nil
                            }
                            
                            return APIWalletCreateResult.WalletResource(
                                pKey: v.pKey,
                                address: v.address,
                                mainCoin: coin
                            )
                        })
                    
                    guard !syncNeededWalletResources.isEmpty else {
                        return errorDebug(response: .success(()))
                    }
                    
                    let sources = syncNeededWalletResources.map {
                        res -> (address: String, pKey: String, mnenomic: String?, isFromSystem: Bool, name: String, pwd: String, pwdHint: String, chainType: ChainType, mainCoinID: String) in
                        return (address: res.address,
                                pKey: res.pKey,
                                mnenomic: mne,
                                isFromSystem: true,
                                name: Wallet.defaultName(ofMainCoin: res.mainCoin),
                                pwd: pwd,
                                pwdHint: self.identityPwdHint,
                                chainType: res.mainCoin.owChainType,
                                mainCoinID: res.mainCoin.walletMainCoinID!)
                    }
                    
                    guard let wallets = Wallet.create(identity: Identity.singleton!, sources: sources) else {
                        let msg = LM.dls.tab_alert_error_wallet_sync_failed
                        let gtErr = GTServerAPIError.incorrectResult(msg, msg)
                        return errorDebug(response: .failed(error: gtErr))
                    }
                    
                    print("Finish create sync wallets for mainCoinID \(wallets.map { $0.walletMainCoinID })")
                    return .success(())
                }
            }
    }
}
