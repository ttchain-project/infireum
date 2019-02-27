//
//  PrivateChatSettingViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/25.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PrivateChatSettingViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        var selectedDurationIfAny: PrivateChatDuration?
        var privateModeStatusIfAny: Bool?
        var roomId:String
        var roomType:RoomType
        var uId:String
    }
    
    typealias Constructor = Config
    var viewModel: PrivateChatSettingViewModel!
    var bag: DisposeBag = DisposeBag()

    
    @IBOutlet weak var privateModelLabel: UILabel!
    @IBOutlet weak var privateModeTitleLabel: UILabel!
    @IBOutlet weak var privateModeSwitch: UISwitch!
    @IBOutlet weak var privateModeDurationLabel: UILabel!
    @IBOutlet weak var privateModelDurationButton: UIButton!
    @IBOutlet weak var privateChatDurationContentView: UIView!
    @IBOutlet weak var titleContentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    let pickerView: UIPickerView = UIPickerView.init()
    private let pickerResponder = UITextField.init()
 
    private let chatSecretChoices : PublishRelay<(PrivateChatDuration?,Bool)> = PublishRelay.init()
    
    var onChatSecretChoicesComplete : Observable<(PrivateChatDuration?,Bool)> {
        return chatSecretChoices.asObservable()
    }
    
   
    
    func config(constructor: PrivateChatSettingViewController.Config) {
        self.view.layoutIfNeeded()
        
        self.viewModel =
            ViewModel.init(input: PrivateChatSettingViewModel.InputSource(
            selectedDuration:constructor.selectedDurationIfAny,
            selectedStatus:constructor.privateModeStatusIfAny,
            privateChatSwitch: self.privateModeSwitch.rx.isOn,
            pickerSelectedIndex: self.pickerView.rx.itemSelected.asDriver().map { $0.row },
            roomId: constructor.roomId,
            roomType:constructor.roomType,
            uId:constructor.uId
            ),output: ())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.bindViewModel()
        self.setupPickerView()
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(
            tint: palette.nav_item_1,
            barTint: palette.nav_bg_2
        )
        renderNavTitle(
            color: palette.nav_item_2,
            font: .owMedium(size: 18)
        )
        changeNavShadowVisibility(true)
        changeBackBarButton(toColor: palette.nav_item_2,
                            image: #imageLiteral(resourceName: "arrowNavBlack"),
                            title: nil)
        
        view.backgroundColor = palette.bgView_sub
//        self.titleContentView.backgroundColor
            self.stackView.backgroundColor = palette.bgView_main
        
//        self.privateChatDurationContentView.backgroundColor = palette.bgView_main
        privateModelLabel.set(
            textColor: palette.label_main_1,
            font: .owRegular(size: 17)
        )
        privateModeDurationLabel.set(
            textColor: palette.label_main_1,
            font: .owRegular(size: 17)
        )
        privateModeTitleLabel.set(
            textColor: palette.label_sub,
            font: .owRegular(size: 10)
        )
        
        privateModelDurationButton.set(color: palette.label_main_1, font: UIFont.owRegular(size: 12))
        privateModelDurationButton.setTitleColor(palette.label_sub, for: .disabled)
        
        self.privateModeSwitch.layer.anchorPoint = CGPoint.init(x: 1.0, y: 1.0)
        self.privateModeSwitch.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
        
        privateModelDurationButton.set(image: #imageLiteral(resourceName: "arrowNavBlue"),
                                       title: nil,
                                       titlePosition: .left,
                                       additionalSpacing: 8,
                                       state: .normal)
        
        self.createRightBarButton(target: self, selector: #selector(saveSetting), title: LM.dls.ab_update_btn_save, toColor: palette.label_main_2, shouldClear: true)
    }
    
    override func renderLang(_ lang: Lang) {
        self.privateModeTitleLabel.text = lang.dls.chat_secret_setting
        self.privateModelLabel.text = lang.dls.decentralize
        self.privateModeDurationLabel.text = lang.dls.time_limit
    }
    
    func bindViewModel() {
        self.viewModel.privateChatDurationObserver.subscribe(onNext: { (duration) in

            self.privateModelDurationButton.set(image: nil, title: duration.title, titlePosition: .left, additionalSpacing: 8, state: .normal)
        }).disposed(by: bag)
        
        Observable.just(self.viewModel.durationOptions).bind(to: self.pickerView.rx.itemTitles){ (row,element) in
            return element.title
        }.disposed(by: bag)
        self.privateModeSwitch.isOn = self.viewModel.isChatPrivate()
        
        self.privateModeSwitch.rx.isOn.map { $0 }.bind(to: self.privateModelDurationButton.rx.isEnabled).disposed(by: bag)
    }
    
    private func setupPickerView() {
        pickerResponder.inputView = pickerView
        privateChatDurationContentView.addSubview(pickerResponder)
        self.privateModelDurationButton.rx.tap.asDriver().drive(onNext: {
            [unowned self] in
            self.pickerResponder.becomeFirstResponder()
        }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @objc func saveSetting() {
        self.viewModel.setDestructMessageSetting().asObservable()
            .subscribe(onNext: { response in
                switch response {
                case .failed(error: let error):
                    print(error)
                case .success( _):
                    print("message")
                    if self.viewModel.isChatPrivate() {
                        self.chatSecretChoices.accept((self.viewModel.getPrivateChatDuration(), self.viewModel.isChatPrivate()))
                    } else {
                        self.chatSecretChoices.accept((nil, self.viewModel.isChatPrivate()))
                    }
                    self.navigationController?.popViewController()
                }
            }).disposed(by: bag)
    }
}

//extension PrivateChatSettingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return self.viewModel.durationOptions.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return self.viewModel.durationOptions[row].title
//    }
////    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        self.viewModel.input.selectedDuration. = durationOptions[row]
////    }
//
//}
