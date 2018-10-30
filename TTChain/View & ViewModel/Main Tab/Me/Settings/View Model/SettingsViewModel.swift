//
//  SettingsViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit

class SettingsManager {
    private static let settingsOptionKey_idAuth = "settingsOptionKey_idAuth"
    private static let settingsOptionKey_privateMode = "settingsOptionKey_privateMode"
    
    public static var isIDAuthEnabled: Bool {
        return UserDefaults.standard.bool(forKey: settingsOptionKey_idAuth)
    }
    
    public static func changeIDAuthEnabled(isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: settingsOptionKey_idAuth)
        OWRxNotificationCenter.instance.changeIDAuthEnable(isEnabled)
    }
    
    public static var isPrivateModeEnabled: Bool {
        return UserDefaults.standard.bool(forKey: settingsOptionKey_privateMode)
    }
    
    public static func changeIsPrivateModeEnabled(isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: settingsOptionKey_privateMode)
        OWRxNotificationCenter.instance.changePrivateMode(isEnabled)
    }
}

import RxSwift
import RxCocoa

class SettingsViewModel: KLRxViewModel {
    struct Input {
        let identity: Identity
        let idAuthEnableInput: ControlProperty<Bool>
        let privateModeEnableInput: ControlProperty<Bool>
        let settingsInputChangeVerify: () -> (Observable<Bool>)
    }
    
    typealias InputSource = Input
    var input: SettingsViewModel.Input
    
    typealias OutputSource = Void
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        // This is the fancy part, when control property send a diff enable status,
        // view model will try to authorize this change with verifying logic from
        // input source, then, if the verify passed, new status will be passed,
        // otherwise, the origin status (!enable) will be passed.
        // And after that view model bind the relay objs to controlproperty to
        // reflect the final status to view.
        input.privateModeEnableInput
//            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest {
                [unowned self] enable -> Observable<Bool> in
                if !enable { return self.input.settingsInputChangeVerify().map { $0 ? enable : !enable } }
                else { return Observable<Bool>.just(true).concat(Observable.never()) }
            }
            .bind(to: _isPrivateModeEnabled)
            .disposed(by: bag)
        
        input.idAuthEnableInput
            .skip(1)
            .flatMapLatest {
                [unowned self] enable -> Observable<Bool> in
                if !enable { return self.input.settingsInputChangeVerify().map { $0 ? enable : !enable } }
                else { return Observable<Bool>.just(true).concat(Observable.never()) }
            }
            .bind(to: _isIDAuthEnabled)
            .disposed(by: bag)
        
        _isIDAuthEnabled.bind(to: input.idAuthEnableInput).disposed(by: bag)
        _isPrivateModeEnabled.bind(to: input.privateModeEnableInput).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        _isIDAuthEnabled.subscribe(onNext: {
            SettingsManager.changeIDAuthEnabled(isEnabled: $0)
        })
        .disposed(by: bag)
        
        _isPrivateModeEnabled.subscribe(onNext: {
            SettingsManager.changeIsPrivateModeEnabled(isEnabled: $0)
        })
        .disposed(by: bag)
        
        OWRxNotificationCenter.instance.prefFiatUpdate
            .subscribe(onNext: {
                [unowned self] fiat in
                self._fiat.accept(fiat)
            })
            .disposed(by: bag)
    }
    
    //MARK: - Public
    public var lang: Observable<Lang> {
        return _lang.asObservable()
    }
    
    public func getLang() -> Lang {
        return _lang.value
    }
    
    public func refreshLang() {
        _lang.accept(input.identity.owLang)
    }
    
    public var fiat: Observable<Fiat> {
        return _fiat.asObservable()
    }
    
    public func getFiat() -> Fiat {
        return _fiat.value
    }
    
    public func refreshFiat() {
        _fiat.accept(input.identity.fiat!)
    }
    
    //MARK: - Private
    private lazy var _isIDAuthEnabled: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: SettingsManager.isIDAuthEnabled)
    }()
    
    private lazy var _isPrivateModeEnabled: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: SettingsManager.isPrivateModeEnabled)
    }()
    
    private lazy var _lang: BehaviorRelay<Lang> = {
        return BehaviorRelay.init(value: input.identity.owLang)
    }()
    
    private lazy var _fiat: BehaviorRelay<Fiat> = {
        return BehaviorRelay.init(value: input.identity.fiat!)
    }()
}
