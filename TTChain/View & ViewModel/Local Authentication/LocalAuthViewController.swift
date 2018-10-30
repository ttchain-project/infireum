//
//  LocalAuthViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/22.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication

final class LocalAuthViewController: KLModuleViewController, KLVMVC {
    
//    @IBOutlet weak var pwdButton: UIButton!
//    @IBOutlet weak var localAuthButton: UIButton!
    @IBOutlet weak var authView: UIStackView!
    @IBOutlet weak var authLabel: UILabel!
    
    var bag: DisposeBag = DisposeBag.init()
    
    typealias Constructor = Void
    typealias ViewModel = LocalAuthViewModel
    var viewModel: ViewModel!
    func config(constructor: Constructor) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: LocalAuthViewModel.InputSource(),
            output: ()
        )
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        
        bindAction()
    }
    
    private func bindAction() {
//        let pwdAuth = pwdButton.rx.tap.asDriver()
//            .flatMapLatest {
//                [unowned self] in self.startIdentityPwdCheck().asDriver(onErrorJustReturn: false)
//            }
        
        let localAuth = authView.rx.klrx_tap
            .flatMapLatest {
                [unowned self] in self.startLocalAuth().asDriver(onErrorJustReturn: false)
            }
        
        
        
        Driver<Bool>.merge(localAuth)
            .drive(onNext: {
                [unowned self] isPassed in
                if isPassed {
                    self._onSuccess.accept(())
                }
            })
            .disposed(by: bag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: view) else { return }
        if authView.frame.contains(touch) {
            self.authView.alpha = 0.6
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: view) else { return }
        if authView.frame.contains(touch) {
            self.authView.alpha = 1
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: view) else { return }
        if authView.frame.contains(touch) {
            self.authView.alpha = 1
        }
    }
    
    public var onSuccess: Observable<Void> {
        return _onSuccess.asObservable()
    }
    
    private lazy var _onSuccess: PublishRelay<Void> = {
        return PublishRelay.init()
    }()
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        authLabel.text = dls.localAuth_btn_tapToStartVerify
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        authLabel.set(textColor: palette.application_main,
                      font: .owRegular(size: 16))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private var onLaunchAuthFlag: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        if !onLaunchAuthFlag {
            startLocalAuth()
                .subscribe(onNext: {
                    [unowned self] in
                    if $0 { self._onSuccess.accept(()) }
                })
                .disposed(by: bag)
            
            onLaunchAuthFlag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Helper
    private func startLocalAuth() -> Observable<Bool> {
        let context = LAContext.init()
        
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            return Observable.create({ (observer) -> Disposable in
                context.evaluatePolicy(
                LAPolicy.deviceOwnerAuthentication,
                localizedReason: LM.dls.localAuth_alert_verifyToBrowse_title) { (isValid, error) in
                    observer.onNext(isValid)
                }
                
                return Disposables.create()
            })
            
        }else {
            return Observable.just(true).concat(Observable.never())
        }
    }
    
    private func startIdentityPwdCheck() -> Observable<Bool> {
        return Observable.create({ [unowned self] (observer) -> Disposable in
            let alert = UIAlertController.init(
                title: LM.dls.localAuth_alert_inputIdentiyPwd_title,
                message: nil,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: LM.dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(
                title: LM.dls.g_confirm,
                style: .default,
                handler: { [unowned self]  (_) in
                    if let text = textField.text, text.count > 0 {
                    observer.onNext(self.viewModel.validatePwd(input: text))
                }
            })
            
            alert.addTextField(configurationHandler: { [unowned self] (tf) in
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            })
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
