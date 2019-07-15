//
//  PwdHintViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PwdHintViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var hintBase: UIView!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var visibleBtn: UIButton!
    
    typealias Constructor = Config
    struct Config {
        let wallet: Wallet
    }
    
    typealias ViewModel = PwdHintViewModel
    var viewModel: PwdHintViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: PwdHintViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: PwdHintViewModel.InputSource(
                wallet: constructor.wallet,
                pwdHintInout: hintTextField.rx.text,
                pwdVisibilityInput: visibleBtn.rx.tap.asDriver().map {
                    [unowned self] in !self.visibleBtn.isSelected
                }
            ),
            output: ()
        )
        
        bindViewModel()
    }
    
    private lazy var completeBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(complete), size: CGSize.init(width: 50, height: 30))
    }()
    
    lazy var hud: KLHUD = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: CGSize.init(width: 100, height: 100)
            ),
            descText: LM.dls.pwdHint_hud_updating,
            spinnerColor: TM.palette.hud_spinner,
            textColor: TM.palette.hud_text
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        visibleBtn.isSelected = false
        hintTextField.isSecureTextEntry = true
        
        visibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOff"), for: .normal)
        visibleBtn.setImage(#imageLiteral(resourceName: "iconTextfieldEyeOn"), for: .selected)
        visibleBtn.setTitleForAllStates("")
    }
    
    private func bindViewModel() {
        viewModel.hintVisibility.drive(visibleBtn.rx.isSelected).disposed(by: bag)
        
        viewModel.hintVisibility
            .map { !$0 }
            .drive(hintTextField.rx.isSecured)
            .disposed(by: bag)
        
        viewModel.isAbleToSave.bind(to: completeBtn.rx.isEnabled).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.pwdHint_title
        completeBtn.setTitleForAllStates(dls.g_done)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        changeNavShadowVisibility(true)
        
        view.backgroundColor = palette.bgView_sub
        hintTextField.set(
            textColor: palette.input_text,
            font: .owRegular(size: 17),
            placeHolderColor: palette.input_placeholder
        )
        
        completeBtn.set(color: palette.nav_item_1, font: UIFont.owRegular(size: 16))
    }
    
    @objc private func complete() {
        guard viewModel.saveNewHint() else {
            return errorDebug(response: ())
        }
        
        hud.startAnimating(inView: self.view)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            [unowned self] in
            self.hud.updateType(.img(#imageLiteral(resourceName: "iconSpinnerAlertOk")), text: LM.dls.pwdHint_hud_updated)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.hud.stopAnimating()
                self.pop(sender: nil)
            })
        }
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
