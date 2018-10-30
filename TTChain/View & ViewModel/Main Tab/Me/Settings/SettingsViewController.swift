//
//  SettingsViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import LocalAuthentication

final class SettingsViewController: KLModuleViewController, KLVMVC, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var idAuthTitleLabel: UILabel!
    @IBOutlet weak var idAuthSwitch: UISwitch!
    
    @IBOutlet weak var privateModeTitleLabel: UILabel!
    @IBOutlet weak var privateModeSwitch: UISwitch!
    @IBOutlet weak var privateModelNoteLabel: UILabel!
    
    @IBOutlet weak var langTitleLabel: UILabel!
    @IBOutlet weak var langContentBase: UIView!
    @IBOutlet weak var langContentLabel: UILabel!
    
    @IBOutlet weak var fiatTitleLabel: UILabel!
    @IBOutlet weak var fiatContentBase: UIView!
    @IBOutlet weak var fiatContentLabel: UILabel!
    
    let pickerView: UIPickerView = UIPickerView.init()
    private let pickerResponder = UITextField.init()
    
    private var titleLabels: [UILabel] {
        return [idAuthTitleLabel, privateModeTitleLabel, langTitleLabel, fiatTitleLabel]
    }
    
    struct Config {
        let identity: Identity
    }
    
    typealias Constructor = Config
    typealias ViewModel = SettingsViewModel
    var viewModel: SettingsViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: SettingsViewController.Config) {
        view.layoutIfNeeded()
        self.setUpLangSelectView()
        viewModel = ViewModel.init(
            input: SettingsViewModel.InputSource(
                identity: constructor.identity,
                idAuthEnableInput: idAuthSwitch.rx.isOn,
                privateModeEnableInput: privateModeSwitch.rx.isOn,
                settingsInputChangeVerify: { [unowned self] in self.startIDAuthVerify()
                }
            ),
            output: ()
        )
        
        bindViewModel()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func setUpLangSelectView() {
        pickerResponder.inputView = pickerView
        langContentBase.addSubview(pickerResponder)
        langContentBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in
            self.pickerResponder.becomeFirstResponder()
        }).disposed(by: bag)
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    
    private func bindViewModel() {
        viewModel.fiat.map { $0.name! }.bind(to: fiatContentLabel.rx.text).disposed(by: bag)
        fiatContentBase.rx.klrx_tap.drive(onNext: {
            [unowned self] in self.toFiatSelectView()
        })
        .disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.settings_title
        idAuthTitleLabel.text = dls.settings_label_localAuth
        privateModeTitleLabel.text = dls.settings_label_privateMode
        privateModelNoteLabel.text = dls.settings_label_privateMode_note
        langTitleLabel.text = dls.settings_label_language
        fiatTitleLabel.text = dls.settings_label_currencyUnit
        
        /*
        Because each time the lang update, the display text would always be updated as well, so use a simple setter than the binding actions in the bindViewModel() will be fine in this case.
         */
        langContentLabel.text = lang.localizedName
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(
            tint: palette.nav_item_1,
            barTint: palette.nav_bg_1
        )
        
        renderNavTitle(
            color: palette.nav_item_1,
            font: .owMedium(size: 18)
        )
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_1,
            image: #imageLiteral(resourceName: "arrowNavBlack"),
            title: nil
        )
        
        view.backgroundColor = palette.bgView_sub
        titleLabels.forEach { (label) in
            label.set(
                textColor: palette.label_main_1,
                font: .owRegular(size: 17)
            )
        }
        
        privateModelNoteLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 10)
        )
        
        langContentLabel.set(
            textColor: palette.input_placeholder,
            font: .owRegular(size: 17)
        )
        
        fiatContentLabel.set(
            textColor: palette.input_placeholder,
            font: .owRegular(size: 17)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - ID Auth
    private func startIDAuthVerify() -> Observable<Bool> {
        let context = LAContext.init()
        
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            return Observable.create({ (observer) -> Disposable in
                context.evaluatePolicy(
                    LAPolicy.deviceOwnerAuthentication,
                    localizedReason: LM.dls.settings_alert_verify_to_turn_off_functionality
                ) { (isValid, error) in
                    observer.onNext(isValid)
                }
                
                return Disposables.create()
            })
            
        }else {
            return Observable.just(true).concat(Observable.never())
        }
    }

    private func toFiatSelectView() {
        let vc = ChangePrefFiatViewController.instance(from: ChangePrefFiatViewController.Config(identity: viewModel.input.identity))
        navigationController?.pushViewController(vc)
    }
    
    //MARK: - Picker Delegate and Datasource -
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Lang.supportLangs.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Lang.supportLangs[row].localizedName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLang = Lang.supportLangs[row]
        let selectedLanguage = Lang.init(rawValue: selectedLang.rawValue)
        LM.instance.lang.accept(selectedLanguage ?? Lang.default)
    }
}
