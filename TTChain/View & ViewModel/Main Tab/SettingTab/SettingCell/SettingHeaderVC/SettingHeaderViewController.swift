//
//  SettingHeaderViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class SettingHeaderViewController: KLModuleViewController,KLVMVC {

    var bag:DisposeBag = DisposeBag()
    typealias ViewModel = SettingHeaderViewModel
    var viewModel: SettingHeaderViewModel!
    func config(constructor: SettingHeaderViewController.Constructor) {
        self.view.layoutIfNeeded()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
        self.bindUI()
    }
    
    typealias Constructor = Void
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var userName:UILabel!{
        didSet {
            userName.isHidden = true
        }
    }
    @IBOutlet weak var accountNameLabel: UILabel!{
        didSet {
            accountNameLabel.isHidden = true
        }
    }
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func renderLang(_ lang: Lang) {
        
    }
    override func renderTheme(_ theme: Theme) {
        self.userName.set(textColor: theme.palette.label_main_2, font: .owMedium(size: 16))
        self.accountNameLabel.set(textColor: theme.palette.label_main_2, font: .owMedium(size: 16))

    }
    
    func bindUI() {
        IMUserManager.manager.userModel.asObservable().subscribe(onNext: { [unowned self] (user) in
            guard let user = user else {
                return
            }
            self.userName.text = user.nickName
            self.userName.isHidden = false
            self.userImageView.setProfileImage(image: user.headImgUrl, tempName: user.nickName)
        }).disposed(by: bag)

        self.accountNameLabel.text = Identity.singleton?.name
        accountNameLabel.isHidden = false
    }
    
}
