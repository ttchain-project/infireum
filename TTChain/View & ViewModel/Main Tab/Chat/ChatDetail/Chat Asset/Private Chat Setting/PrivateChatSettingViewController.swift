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


    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var privateModeButton: UIButton!
    
    @IBOutlet weak var deleteImmediatelyBtn: UIButton!
    @IBOutlet weak var deleteAfterFiveBtn: UIButton!
    @IBOutlet weak var deleteAfterTenBtn: UIButton!
    @IBOutlet weak var deleteAfterTwentyBtn: UIButton!
    @IBOutlet weak var deleteAfterThirtyBtn: UIButton! {
        didSet {
            deleteAfterThirtyBtn.isHidden = true
        }
    }
    @IBOutlet weak var deleteAfterSixtyBtn: UIButton!{
        didSet {
            deleteAfterSixtyBtn.isHidden = true
        }
    }
    
    lazy var buttons :[UIButton] = [deleteImmediatelyBtn,
                                    deleteAfterFiveBtn,
                                    deleteAfterTenBtn,
                                    deleteAfterTwentyBtn]
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
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
            roomId: constructor.roomId,
            roomType:constructor.roomType,
            uId:constructor.uId
            ),output: ())

        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.bindViewModel()
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
        
        for (btn, title) in zip(self.buttons,self.viewModel.durationOptions) {
            btn.setTitleForAllStates(title.title)
            btn.set( font: .owRegular(size:14))
            btn.setTitleColor(palette.label_main_1, for: .normal)
            btn.setTitleColor(palette.label_sub,for:.disabled)
        }
        
        privateModeButton.set( font: .owRegular(size:14))
        
//        self.createRightBarButton(target: self, selector: #selector(saveSetting), title: LM.dls.ab_update_btn_save, toColor: palette.label_main_2, shouldClear: true)
    }
    
    override func renderLang(_ lang: Lang) {

        self.privateModeButton.setTitleForAllStates(lang.dls.chat_secret_setting)
         nextButton.setTitleForAllStates(lang.dls.g_confirm)
        backButton.setTitleForAllStates(lang.dls.g_cancel)

    }
    
    func bindViewModel() {
        
        self.deleteImmediatelyBtn.rx.tap.bind { self.viewModel._privateChatDuration.accept(.singleConversation) }.disposed(by: bag)
        
        self.deleteAfterFiveBtn.rx.tap.bind { self.viewModel._privateChatDuration.accept(.pvt_5_minutes) }.disposed(by: bag)
        
        self.deleteAfterTenBtn.rx.tap.bind { self.viewModel._privateChatDuration.accept(.pvt_10_minutes) }.disposed(by: bag)
        
        self.deleteAfterTwentyBtn.rx.tap.bind { self.viewModel._privateChatDuration.accept(.pvt_20_minutes) }.disposed(by: bag)
        
        
        Observable.combineLatest(self.viewModel.privateChatDurationObserver,self.viewModel!._isPrivateChatEnabled).asObservable().subscribe(onNext: { (arg) in
            
            let (duration,status) = arg
            self.buttons.forEach { $0.isEnabled = status }
            
            self.buttons.forEach { $0.isSelected = false }
            if status {
                switch duration {
                case .singleConversation:
                    self.deleteImmediatelyBtn.isSelected = true
                case .pvt_10_minutes:
                    self.deleteAfterTenBtn.isSelected = true
                case .pvt_5_minutes:
                    self.deleteAfterFiveBtn.isSelected = true
                case .pvt_20_minutes:
                    self.deleteAfterTwentyBtn.isSelected = true
                }
            }
            
        }).disposed(by: bag)
        
//        self.viewModel.privateChatDurationObserver.subscribe(onNext: { (duration) in
//            self.buttons.forEach { $0.isSelected = false }
//            switch duration {
//            case .singleConversation:
//                self.deleteImmediatelyBtn.isSelected = true
//            case .pvt_10_minutes:
//                self.deleteAfterTenBtn.isSelected = true
//            case .pvt_5_minutes:
//                self.deleteAfterFiveBtn.isSelected = true
//            case .pvt_20_minutes:
//                self.deleteAfterTwentyBtn.isSelected = true
//            }
//        }).disposed(by: bag)
//
//        self.viewModel._isPrivateChatEnabled.subscribe(onNext: { (status) in
//            self.buttons.forEach { $0.isEnabled = status }
//        }).disposed(by: bag)
        
        self.privateModeButton.isSelected = self.viewModel.isChatPrivate()
        
        self.privateModeButton.rx.klrx_tap.drive(onNext:{ _ in
            self.privateModeButton.isSelected = !self.privateModeButton.isSelected
            self.viewModel._isPrivateChatEnabled.accept(self.privateModeButton.isSelected)
        }).disposed(by: bag)
        
        self.backButton.rx.klrx_tap.drive(onNext:{ _ in
            self.navigationController?.popViewController()
        }).disposed(by: bag)
        
        self.nextButton.rx.klrx_tap.drive(onNext:{ _ in
            self.saveSetting()
        }).disposed(by: bag)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func saveSetting() {
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

